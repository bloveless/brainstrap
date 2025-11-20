defmodule Brainstrap.Repo.Migrations.CreateLessonPlans do
  use Ecto.Migration

  def change do
    create table(:lesson_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: false
      add :prerequisites, {:array, :text}, default: []
      add :trail_id, references(:trails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_plans, [:trail_id])

    create table(:lesson_plan_sections, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: false
      add :order, :integer

      add :lesson_plan_id, references(:lesson_plans, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_plan_sections, [:lesson_plan_id])

    create table(:lesson_plan_lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text, null: false
      add :order, :integer, null: false

      add :section_id,
          references(:lesson_plan_sections, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_plan_lessons, [:section_id])

    create table(:lesson_plan_resources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text, null: false
      add :type, :string, null: false
      add :url, :text, null: false

      add :lesson_id, references(:lesson_plan_lessons, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_plan_resources, [:lesson_id])

    create table(:lesson_plan_checkpoints, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text, null: false
      add :tasks, {:array, :text}, default: []

      add :section_id,
          references(:lesson_plan_sections, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_plan_checkpoints, [:section_id])
  end
end
