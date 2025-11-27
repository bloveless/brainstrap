defmodule Brainstrap.LLM.Interaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.LessonPlan

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "llm_interactions" do
    field :model, :string
    field :request_body, :map
    field :response_body, :map
    field :status_code, :integer
    field :error, :string
    field :duration_ms, :integer
    field :prompt_tokens, :integer
    field :completion_tokens, :integer
    field :total_tokens, :integer
    field :cost_usd, :decimal

    belongs_to :lesson_plan, LessonPlan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(interaction, attrs) do
    interaction
    |> cast(attrs, [
      :model,
      :request_body,
      :response_body,
      :status_code,
      :error,
      :duration_ms,
      :prompt_tokens,
      :completion_tokens,
      :total_tokens,
      :cost_usd,
      :lesson_plan_id
    ])
    |> validate_required([:model, :request_body])
    |> foreign_key_constraint(:lesson_plan_id)
  end
end
