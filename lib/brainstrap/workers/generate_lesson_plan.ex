defmodule Brainstrap.Workers.GenerateLessonPlan do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Brainstrap.Repo
  alias Brainstrap.Learning
  alias Brainstrap.Learning.LessonPlan

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"trail_id" => trail_id}}) do
    # Fetch the trail
    trail = Repo.get!(Learning.Trail, trail_id)

    # Generate the lesson plan using LLM
    case Brainstrap.LLM.generate_lesson_plan(trail.name, trail.description) do
      {:ok, response} ->
        # Parse the LLM response
        lesson_plan_data = ReqLLM.Response.object(response)

        # Create the lesson plan with all nested data
        case create_lesson_plan(trail, lesson_plan_data) do
          {:ok, _lesson_plan} ->
            :ok

          {:error, changeset} ->
            {:error, changeset}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_lesson_plan(trail, data) do
    # Build the lesson plan attrs with all nested associations
    attrs = %{
      trail_id: trail.id,
      description: data["description"],
      prerequisites: data["prerequisites"] || [],
      sections: build_sections(data["sections"] || [])
    }

    %LessonPlan{}
    |> LessonPlan.changeset(attrs)
    |> Repo.insert()
  end

  defp build_sections(sections_data) do
    Enum.with_index(sections_data, 1)
    |> Enum.map(fn {section, index} ->
      %{
        description: section["description"],
        position: index,
        lessons: build_lessons(section["lessons"] || []),
        checkpoint: build_checkpoint(section["checkpoint"])
      }
    end)
  end

  defp build_lessons(lessons_data) do
    Enum.with_index(lessons_data, 1)
    |> Enum.map(fn {lesson, index} ->
      %{
        title: lesson["title"],
        description: lesson["description"],
        number: index,
        resources: build_resources(lesson["resources"] || [])
      }
    end)
  end

  defp build_resources(resources_data) do
    Enum.map(resources_data, fn resource ->
      %{
        title: resource["title"],
        description: resource["description"],
        type: resource["type"],
        url: resource["url"]
      }
    end)
  end

  defp build_checkpoint(nil), do: nil

  defp build_checkpoint(checkpoint_data) do
    %{
      title: checkpoint_data["title"],
      description: checkpoint_data["description"],
      tasks: checkpoint_data["tasks"] || []
    }
  end
end
