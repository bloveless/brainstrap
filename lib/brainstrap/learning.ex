defmodule Brainstrap.Learning do
  @moduledoc """
  The Learning context.
  """

  import Ecto.Query, warn: false
  alias Brainstrap.Repo

  alias Brainstrap.Learning.Trail
  alias Brainstrap.Learning.LessonPlan
  alias Brainstrap.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any trail changes.

  The broadcasted messages match the pattern:

    * {:created, %Trail{}}
    * {:updated, %Trail{}}
    * {:deleted, %Trail{}}

  """
  def subscribe_trails(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Brainstrap.PubSub, "user:#{key}:trails")
  end

  defp broadcast_trail(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Brainstrap.PubSub, "user:#{key}:trails", message)
  end

  @doc """
  Returns the list of trails.

  ## Examples

      iex> list_trails(scope)
      [%Trail{}, ...]

  """
  def list_trails(%Scope{} = scope) do
    Repo.all_by(Trail, user_id: scope.user.id)
  end

  @doc """
  Gets a single trail.

  Raises `Ecto.NoResultsError` if the Trail does not exist.

  ## Examples

      iex> get_trail!(scope, 123)
      %Trail{}

      iex> get_trail!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_trail!(%Scope{} = scope, id) do
    Repo.get_by!(Trail, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a trail.

  ## Examples

      iex> create_trail(scope, %{field: value})
      {:ok, %Trail{}}

      iex> create_trail(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trail(%Scope{} = scope, attrs) do
    with {:ok, trail = %Trail{}} <-
           %Trail{}
           |> Trail.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_trail(scope, {:created, trail})
      {:ok, trail}
    end
  end

  @doc """
  Updates a trail.

  ## Examples

      iex> update_trail(scope, trail, %{field: new_value})
      {:ok, %Trail{}}

      iex> update_trail(scope, trail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trail(%Scope{} = scope, %Trail{} = trail, attrs) do
    true = trail.user_id == scope.user.id

    with {:ok, trail = %Trail{}} <-
           trail
           |> Trail.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_trail(scope, {:updated, trail})
      {:ok, trail}
    end
  end

  @doc """
  Deletes a trail.

  ## Examples

      iex> delete_trail(scope, trail)
      {:ok, %Trail{}}

      iex> delete_trail(scope, trail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trail(%Scope{} = scope, %Trail{} = trail) do
    true = trail.user_id == scope.user.id

    with {:ok, trail = %Trail{}} <-
           Repo.delete(trail) do
      broadcast_trail(scope, {:deleted, trail})
      {:ok, trail}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trail changes.

  ## Examples

      iex> change_trail(scope, trail)
      %Ecto.Changeset{data: %Trail{}}

  """
  def change_trail(%Scope{} = scope, %Trail{} = trail, attrs \\ %{}) do
    true = trail.user_id == scope.user.id

    Trail.changeset(trail, attrs, scope)
  end

  @doc """
  Gets the lesson plan for a trail.

  Returns `nil` if the lesson plan does not exist yet.

  ## Examples

      iex> get_lesson_plan_by_trail(scope, trail_id)
      %LessonPlan{}

      iex> get_lesson_plan_by_trail(scope, trail_id)
      nil

  """
  def get_lesson_plan_by_trail(%Scope{} = scope, trail_id) do
    # Verify the trail belongs to the user
    trail = get_trail!(scope, trail_id)

    Repo.one(
      from lp in LessonPlan,
        where: lp.trail_id == ^trail.id,
        preload: [
          sections: [
            :checkpoint,
            lessons: :resources
          ]
        ]
    )
  end

  @doc """
  Gets a lesson plan by ID with all nested associations preloaded.

  Raises `Ecto.NoResultsError` if the lesson plan does not exist or doesn't belong to the user.

  ## Examples

      iex> get_lesson_plan!(scope, lesson_plan_id)
      %LessonPlan{}

  """
  def get_lesson_plan!(%Scope{} = scope, lesson_plan_id) do
    lesson_plan =
      Repo.one!(
        from lp in LessonPlan,
          where: lp.id == ^lesson_plan_id,
          preload: [
            :trail,
            sections: [
              :checkpoint,
              lessons: :resources
            ]
          ]
      )

    # Verify the trail belongs to the user
    true = lesson_plan.trail.user_id == scope.user.id

    lesson_plan
  end
end
