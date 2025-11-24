defmodule Brainstrap.Learning.LessonPlan do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.Trail
  alias Brainstrap.Learning.LessonPlan.Section

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_plans" do
    field :description, :string
    field :prerequisites, {:array, :string}, default: []

    belongs_to :trail, Trail

    has_many :sections, Section, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson_plan, attrs) do
    lesson_plan
    |> cast(attrs, [:trail_id, :description, :prerequisites])
    |> validate_required([:trail_id, :description])
    |> foreign_key_constraint(:trail_id)
    |> cast_assoc(:sections, required: true)
  end
end

defmodule Brainstrap.Learning.LessonPlan.Section do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.LessonPlan
  alias Brainstrap.Learning.LessonPlan.{Lesson, Checkpoint}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_plan_sections" do
    field :description, :string
    field :order, :integer

    belongs_to :lesson_plan, LessonPlan

    has_many :lessons, Lesson, on_replace: :delete
    has_one :checkpoint, Checkpoint, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:lesson_plan_id, :description, :order])
    |> validate_required([:description])
    |> cast_assoc(:lessons, required: true)
    |> cast_assoc(:checkpoint, required: true)
  end
end

defmodule Brainstrap.Learning.LessonPlan.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.LessonPlan.{Section, Resource}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_plan_lessons" do
    field :title, :string
    field :description, :string
    field :order, :integer

    belongs_to :section, Section

    has_many :resources, Resource, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [:section_id, :title, :description, :order])
    |> validate_required([:title, :description, :order])
    |> cast_assoc(:resources, required: true)
  end
end

defmodule Brainstrap.Learning.LessonPlan.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.LessonPlan.Lesson

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_plan_resources" do
    field :title, :string
    field :description, :string
    field :type, :string
    field :url, :string

    belongs_to :lesson, Lesson

    timestamps(type: :utc_datetime)
  end

  @valid_types ~w(course video blog book article)

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:lesson_id, :title, :description, :type, :url])
    |> validate_required([:title, :description, :type, :url])
    |> validate_inclusion(:type, @valid_types)
  end
end

defmodule Brainstrap.Learning.LessonPlan.Checkpoint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Brainstrap.Learning.LessonPlan.Section

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_plan_checkpoints" do
    field :title, :string
    field :description, :string
    field :tasks, {:array, :string}, default: []

    belongs_to :section, Section

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(checkpoint, attrs) do
    checkpoint
    |> cast(attrs, [:section_id, :title, :description, :tasks])
    |> validate_required([:title, :description])
  end
end
