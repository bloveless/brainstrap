defmodule Brainstrap.Learning.Trail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.LessonPlan

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "trails" do
    field :name, :string
    field :description, :string
    field :user_id, :binary_id

    has_one :lesson_plan, LessonPlan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trail, attrs, user_scope) do
    trail
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_change(:user_id, user_scope.user.id)
  end
end
