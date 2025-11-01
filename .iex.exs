defmodule Scripts do
  def enhance_prompt_test() do
    {:ok, resp} =
      Brainstrap.LLM.enhance_prompt(
        "Elixir and the phoenix framework",
        "I'm a beginner to both phoenix framework and elixir but I'd like to learn how to build a basic CRUD website using
      phoenix framework"
      )

    IO.inspect(ReqLLM.Response.text(resp))
    resp
  end

  def enhanced_lesson_plan_test() do
    {:ok, resp} =
      Brainstrap.LLM.generate_lesson_plan(
        "Building CRUD Applications with Elixir and Phoenix Framework",
        "Create a comprehensive beginner-friendly learning plan for Elixir programming language and Phoenix web framework.
      The plan should start with Elixir fundamentals including functional programming concepts, data types, pattern
      matching, and modules. Progress to Phoenix framework basics covering setup, routing, controllers, and views.
      Culminate in building a complete CRUD application demonstrating create, read, update, and delete operations with
      database integration using Ecto. Include practical examples and hands-on exercises suitable for someone with no
      prior experience in Elixir or Phoenix."
      )

    IO.inspect(ReqLLM.Response.usage(resp))
    IO.inspect(ReqLLM.Response.thinking(resp))
    IO.inspect(ReqLLM.Response.text(resp))
    resp
  end

  def lesson_plan_test() do
    {:ok, resp} =
      Brainstrap.LLM.generate_lesson_plan(
        "Elixir and the phoenix framework",
        "I'm a beginner to both phoenix framework and elixir but I'd like to learn how to build a basic CRUD website using
      phoenix framework"
      )

    IO.inspect(ReqLLM.Response.thinking(resp))
    IO.inspect(ReqLLM.Response.text(resp))
    resp
  end
end
