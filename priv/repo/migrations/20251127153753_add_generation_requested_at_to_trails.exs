defmodule Brainstrap.Repo.Migrations.AddGenerationRequestedAtToTrails do
  use Ecto.Migration

  def change do
    alter table(:trails) do
      add :generation_requested_at, :utc_datetime
    end
  end
end
