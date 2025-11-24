defmodule Brainstrap.LLM.OpenRouter do
  @moduledoc """
  OpenRouter API client using Req for structured outputs with usage accounting.
  """

  @openrouter_api_url "https://openrouter.ai/api/v1/chat/completions"
  @max_iterations 5

  # @doc """
  # Generate a structured object using OpenRouter's API with JSON Schema validation.

  # ## Parameters
  # - `model` - OpenRouter model identifier (e.g., "openrouter:google/gemini-2.5-pro:online")
  # - `messages` - List of message maps with `:role` and `:content` keys
  # - `schema` - JSON Schema for structured output validation
  # - `options` - Keyword list for additional parameters

  # ## Options
  # - `:max_tokens` - Maximum tokens to generate (default: 4000)
  # - `:temperature` - Sampling temperature (default: 0.7)
  # - `:stream` - Enable streaming (default: false)

  # ## Returns
  # - `{:ok, %{object: parsed_object, usage: usage_info}}` on success
  # - `{:error, reason}` on failure
  # """
  def generate_object(model, messages, schema, options \\ []) do
    # max_output_tokens = Keyword.get(options, :max_output_tokens, 4000)
    # temperature = Keyword.get(options, :temperature, 0.7)
    # stream = Keyword.get(options, :stream, false)
    tools = Keyword.get(options, :tools, [])
    # max_web_results = Keyword.get(options, :max_web_results, 0)
    # reasoning = Keyword.get(options, :reasoning, false)

    case call_llm_with_tools(messages, tools, schema, model) do
      {:ok, content} -> {:ok, Jason.decode!(content)}
      {:error, error} -> {:error, error}
    end
  end

  defp call_llm_with_tools(messages, tools, schema, model, iteration \\ 0)

  defp call_llm_with_tools(_messages, _tools, _schema, _model, iteration)
       when iteration > @max_iterations,
       do: {:error, "Maximum tool call iterations reached"}

  defp call_llm_with_tools(messages, tools, schema, model, iteration) do
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
      usage: %{include: false}
    }

    case Req.post(@openrouter_api_url, json: body, headers: headers) do
      {:ok, %{status: 200, body: response}} ->
        handle_llm_response(response, messages, tools, schema, model, iteration)

      {:ok, %{status: status, body: body}} ->
        {:error, "OpenRouter API error: #{status} - #{inspect(body)}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp handle_llm_response(response, messages, tools, schema, model, iteration) do
    assistant_message = List.first(response["choices"])["message"]

    case assistant_message do
      %{"tool_calls" => tool_calls} when is_list(tool_calls) ->
        # LLM wants to call tools
        updated_messages = messages ++ [assistant_message]

        # Execute all tool calls
        tool_results = Enum.map(tool_calls, &execute_tool_call/1)

        # Add tool results to messages
        messages_with_results = updated_messages ++ tool_results

        # Call LLM again with tool results
        call_llm_with_tools(messages_with_results, tools, schema, model, iteration + 1)

      %{"content" => content} ->
        # Final response from LLM
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
