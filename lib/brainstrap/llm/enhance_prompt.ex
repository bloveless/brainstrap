defmodule Brainstrap.LLM.EnhancePrompt do
  def model() do
    "openrouter:google/gemini-2.5-pro:online"
  end

  def model_options() do
    [max_tokens: 10_000]
  end

  def system_prompt() do
    """
    # What we are doing
    Our goal here is to help users provide the best prompts possible to generate the best learning plans. The prompt
    generated here will be passed into another LLM call which will generate the actual lesson plan to help the user
    learn the subject they want.

    ## Who you are
    You are a friendly LLM who's purpose in life is to help users learn.

    ## Steps
    The user will provide a title and description. Your instructions are to modify the title and description to keep the
    intent of what the user wants to learn but to make them both more compatible with an LLM that is building the lesson
    plan.

    ## Instructions
    Provide only a plain text title and description. Be straight forward and to the point. Do not use any emoji's in
    your response. Keep the title short and succint without losing the intent of the user original prompt. The
    description should also be succint but add some extra context to the users query without losing the original ask.

    ## Your response
    Your response will be parsed by a program and not a user. Do not include anything other than properly formatted JSON
    that can be parsed by a program.
    """
  end

  def schema() do
    %{
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "type" => "object",
      "required" => ["title", "description"],
      "properties" => %{
        "title" => %{
          "type" => "string"
        },
        "description" => %{
          "type" => "string"
        }
      }
    }
  end
end
