defmodule Brainstrap.LLM.EnhancePrompt do
  def model() do
    "google/gemini-2.5-flash-lite"
    # "x-ai/grok-4.1-fast"
    # "openai/gpt-5-nano"
    # "minimax/minimax-m2"
  end

  def model_options(), do: [max_output_tokens: 5000]

  def system_prompt() do
    """
    # What we are doing
    Our goal here is to help users provide the best prompts possible to generate the best learning plans. The prompt
    generated here will be passed into another LLM call which will generate the actual lesson plan to help the user
    learn the subject they want.

    ## Who you are
    You are a friendly LLM who's purpose in life is to help users learn.

    ## Steps
    The user will provide a name and description for the lesson. Your instructions are to modify the name and
    description to keep the intent of what the user wants to learn but to make them both more compatible with an LLM
    that is building the lesson plan.

    ## Instructions
    Provide only a plain text name and description. Be straight forward and to the point. Do not use any emoji's in
    your response. Keep the name short and succinct without losing the intent of the user original prompt. The
    description should also be succinct but add some extra context to the users query without losing the original ask.
    Do not format the name or the description as markdown. Do not include any links in either the name or the
    description. Attempt to make the response at least four sentences. Remember that your output will be input to
    another LLM call. So if adding some extra context would make the content more valuable to a later LLM call then do
    so.
    """
  end

  def schema() do
    %{
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "type" => "object",
      "required" => ["name", "description"],
      "properties" => %{
        "name" => %{
          "type" => "string",
          "maxLength" => 255
        },
        "description" => %{
          "type" => "string",
          "maxLength" => 1000
        }
      }
    }
  end
end
