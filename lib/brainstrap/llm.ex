defmodule Brainstrap.LLM do
  def enhance_prompt(name, description) do
    ReqLLM.generate_object(
      Brainstrap.LLM.EnhancePrompt.model(),
      ReqLLM.Context.new([
        ReqLLM.Context.system(Brainstrap.LLM.EnhancePrompt.system_prompt()),
        ReqLLM.Context.user(
          "The user has requested to learn \"#{name}\" they provided the additional description \"#{description}\""
        )
      ]),
      Brainstrap.LLM.EnhancePrompt.schema(),
      Brainstrap.LLM.EnhancePrompt.model_options()
    )
  end

  def generate_lesson_plan(title, description) do
    ReqLLM.generate_object(
      Brainstrap.LLM.LessonPlan.model(),
      ReqLLM.Context.new([
        ReqLLM.Context.system(Brainstrap.LLM.LessonPlan.system_prompt()),
        ReqLLM.Context.user(
          "The user has requested to learn \"#{title}\" they provided the additional description \"#{description}\""
        )
      ]),
      Brainstrap.LLM.LessonPlan.schema(),
      Brainstrap.LLM.LessonPlan.model_options()
    )
  end
end
