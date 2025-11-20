defmodule Brainstrap.Repo.Migrations.CreateTrails do
  use Ecto.Migration

  def change do
    create table(:trails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string, size: 1000
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:trails, [:user_id])
  end
end
