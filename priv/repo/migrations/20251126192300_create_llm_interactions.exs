defmodule Brainstrap.Repo.Migrations.CreateLlmInteractions do
  use Ecto.Migration

  def change do
    create table(:llm_interactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lesson_plan_id, references(:lesson_plans, type: :binary_id, on_delete: :nilify_all)
      add :model, :string, null: false
      add :request_body, :map, null: false
      add :response_body, :map
      add :status_code, :integer
      add :error, :text
      add :duration_ms, :integer
      add :prompt_tokens, :integer
      add :completion_tokens, :integer
      add :total_tokens, :integer
      add :cost_usd, :decimal, precision: 12, scale: 8

      timestamps(type: :utc_datetime)
    end

    create index(:llm_interactions, [:model])
    create index(:llm_interactions, [:inserted_at])
    create index(:llm_interactions, [:lesson_plan_id])
  end
end
