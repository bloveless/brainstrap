defmodule Brainstrap.LLM.OpenRouter do
  @moduledoc """
  OpenRouter API client using Req for structured outputs with usage accounting.
  """

  @openrouter_api_url "https://openrouter.ai/api/v1/chat/completions"
  @max_iterations 10

  def generate_object(model, messages, schema, options \\ []) do
    tools = Keyword.get(options, :tools, [])
    lesson_plan_id = Keyword.get(options, :lesson_plan_id)

    case call_llm_with_tools(messages, tools, schema, model, lesson_plan_id) do
      {:ok, content} -> {:ok, Jason.decode!(content)}
      {:error, error} -> {:error, error}
    end
  end

  defp call_llm_with_tools(messages, tools, schema, model, lesson_plan_id, iteration \\ 0)

  defp call_llm_with_tools(_messages, _tools, _schema, _model, _lesson_plan_id, iteration)
       when iteration > @max_iterations,
       do: {:error, "Maximum tool call iterations reached"}

  defp call_llm_with_tools(messages, tools, schema, model, lesson_plan_id, iteration) do
    api_key = Application.fetch_env!(:brainstrap, :openrouter_api_key)
    app_url = Application.fetch_env!(:brainstrap, :app_url)
    app_name = Application.fetch_env!(:brainstrap, :app_name)

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"},
      {"HTTP-Referer", app_url},
      {"X-Title", app_name}
    ]

    body = %{
      model: model,
      messages: messages,
      tools: tools,
      response_format: %{
        type: "json_schema",
        json_schema: %{
          name: "response",
          strict: true,
          schema: schema
        }
      },
      usage: %{include: true}
    }

    req =
      Req.new(headers: headers)
      |> attach_tracking(model, lesson_plan_id)

    case Req.post(req, url: @openrouter_api_url, json: body) do
      {:ok, %{status: 200, body: response}} ->
        handle_llm_response(response, messages, tools, schema, model, lesson_plan_id, iteration)

      {:ok, %{status: status, body: body}} ->
        {:error, "OpenRouter API error: #{status} - #{inspect(body)}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp attach_tracking(req, model, lesson_plan_id) do
    Req.Request.register_options(req, [:llm_model, :llm_lesson_plan_id])
    |> Req.Request.merge_options(llm_model: model, llm_lesson_plan_id: lesson_plan_id)
    |> Req.Request.append_request_steps(llm_tracking_start: &tracking_start/1)
    |> Req.Request.append_response_steps(llm_tracking_complete: &tracking_complete/1)
    |> Req.Request.append_error_steps(llm_tracking_error: &tracking_error/1)
  end

  defp tracking_start(request) do
    start_time = System.monotonic_time(:millisecond)
    request_body = request.body

    request
    |> Req.Request.put_private(:llm_start_time, start_time)
    |> Req.Request.put_private(:llm_request_body, request_body)
  end

  defp tracking_complete({request, response}) do
    start_time = Req.Request.get_private(request, :llm_start_time)
    request_body = Req.Request.get_private(request, :llm_request_body)
    model = request.options[:llm_model]
    lesson_plan_id = request.options[:llm_lesson_plan_id]
    duration_ms = System.monotonic_time(:millisecond) - start_time

    {prompt_tokens, completion_tokens, total_tokens, cost_usd} =
      extract_usage(response.body)

    decoded_request = Jason.decode!(request_body)

    Brainstrap.LLM.create_interaction(%{
      model: model,
      request_body: decoded_request,
      response_body: response.body,
      status_code: response.status,
      duration_ms: duration_ms,
      prompt_tokens: prompt_tokens,
      completion_tokens: completion_tokens,
      total_tokens: total_tokens,
      cost_usd: cost_usd,
      lesson_plan_id: lesson_plan_id
    })

    {request, response}
  end

  defp tracking_error({request, exception}) do
    start_time = Req.Request.get_private(request, :llm_start_time)
    request_body = Req.Request.get_private(request, :llm_request_body)
    model = request.options[:llm_model]
    lesson_plan_id = request.options[:llm_lesson_plan_id]
    duration_ms = System.monotonic_time(:millisecond) - start_time

    decoded_request = Jason.decode!(request_body)

    Brainstrap.LLM.create_interaction(%{
      model: model,
      request_body: decoded_request,
      error: Exception.message(exception),
      duration_ms: duration_ms,
      lesson_plan_id: lesson_plan_id
    })

    {request, exception}
  end

  defp extract_usage(body) when is_map(body) do
    usage = Map.get(body, "usage", %{})

    prompt_tokens = Map.get(usage, "prompt_tokens")
    completion_tokens = Map.get(usage, "completion_tokens")
    total_tokens = Map.get(usage, "total_tokens")
    cost_usd = extract_cost(usage)

    {prompt_tokens, completion_tokens, total_tokens, cost_usd}
  end

  defp extract_usage(_), do: {nil, nil, nil, nil}

  defp extract_cost(%{"cost" => cost}) when is_number(cost), do: Decimal.from_float(cost)
  defp extract_cost(_), do: nil

  defp handle_llm_response(response, messages, tools, schema, model, lesson_plan_id, iteration) do
    assistant_message = List.first(response["choices"])["message"]

    case assistant_message do
      %{"tool_calls" => tool_calls} when is_list(tool_calls) ->
        updated_messages = messages ++ [assistant_message]
        tool_results = Enum.map(tool_calls, &execute_tool_call/1)
        messages_with_results = updated_messages ++ tool_results

        call_llm_with_tools(
          messages_with_results,
          tools,
          schema,
          model,
          lesson_plan_id,
          iteration + 1
        )

      %{"content" => content} ->
        {:ok, content}

      _ ->
        {:error, "Unexpected response format"}
    end
  end

  defp execute_tool_call(%{"id" => tool_call_id, "function" => function_info}) do
    function_name = function_info["name"]
    arguments = Jason.decode!(function_info["arguments"])

    result =
      case function_name do
        "youtube_search" ->
          query = arguments["query"]
          max_results = arguments["max_results"] || 5

          case Brainstrap.LLM.YouTubeSearch.execute(query, max_results) do
            {:ok, videos} -> Jason.encode!(%{success: true, videos: videos})
            {:error, error} -> Jason.encode!(%{success: false, error: error})
          end

        _ ->
          Jason.encode!(%{success: false, error: "Unknown function: #{function_name}"})
      end

    %{
      role: "tool",
      tool_call_id: tool_call_id,
      content: result
    }
  end
end
