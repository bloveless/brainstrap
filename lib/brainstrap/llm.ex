defmodule Brainstrap.LLM do
  import Ecto.Query, warn: false
  alias Brainstrap.Repo
  alias Brainstrap.LLM.Interaction

  def list_interactions(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    Interaction
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def get_interaction!(id), do: Repo.get!(Interaction, id) |> Repo.preload(:lesson_plan)

  def create_interaction(attrs) do
    %Interaction{}
    |> Interaction.changeset(attrs)
    |> Repo.insert()
  end

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
