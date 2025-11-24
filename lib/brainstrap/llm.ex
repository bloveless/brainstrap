defmodule Brainstrap.LLM do
  def enhance_prompt(name, description) do
    messages = [
      %{
        role: "system",
        content: Brainstrap.LLM.EnhancePrompt.system_prompt()
      },
      %{
        role: "user",
        content:
          "The user has requested to learn \"#{name}\" they provided the additional description \"#{description}\""
      }
    ]

    Brainstrap.LLM.OpenRouter.generate_object(
      Brainstrap.LLM.EnhancePrompt.model(),
      messages,
      Brainstrap.LLM.EnhancePrompt.schema(),
      Brainstrap.LLM.EnhancePrompt.model_options()
    )
  end

  def generate_lesson_plan(title, description) do
    messages = [
      %{
        role: "system",
        content: Brainstrap.LLM.GenerateLessonPlan.system_prompt()
      },
      %{
        role: "user",
        content:
          "The user has requested to learn \"#{title}\" they provided the additional description \"#{description}\""
      }
    ]

    Brainstrap.LLM.OpenRouter.generate_object(
      Brainstrap.LLM.GenerateLessonPlan.model(),
      messages,
      Brainstrap.LLM.GenerateLessonPlan.schema(),
      Brainstrap.LLM.GenerateLessonPlan.model_options()
    )
  end
end
