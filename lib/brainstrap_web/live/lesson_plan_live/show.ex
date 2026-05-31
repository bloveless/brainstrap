defmodule BrainstrapWeb.LessonPlanLive.Show do
  use BrainstrapWeb, :live_view

  alias Brainstrap.Learning

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="blueprint">
        <div class="blueprint-header">
          <.button navigate={~p"/trails/#{@lesson_plan.trail_id}"} class="btn btn-ghost btn-sm">
            <.icon name="hero-arrow-left" class="size-4" /> Back to Trail
          </.button>
          <h1 class="blueprint-title">{@lesson_plan.trail.name}</h1>
          <p class="blueprint-subtitle">Learning Blueprint</p>
        </div>

        <div class="blueprint-description">
          <div class="blueprint-card">
            <div class="blueprint-card-header">
              <svg
                class="blueprint-icon"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <path d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25" />
              </svg>
              <span>Overview</span>
            </div>
            <p class="blueprint-card-content">{@lesson_plan.description}</p>
          </div>

          <div :if={@lesson_plan.prerequisites != []} class="blueprint-card">
            <div class="blueprint-card-header">
              <svg
                class="blueprint-icon"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <path d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span>Prerequisites</span>
            </div>
            <ul class="blueprint-prerequisites">
              <li :for={prereq <- @lesson_plan.prerequisites}>{prereq}</li>
            </ul>
          </div>
        </div>

        <div class="blueprint-timeline">
          <div class="blueprint-timeline-line"></div>

          <div
            :for={{section, section_idx} <- Enum.with_index(@lesson_plan.sections)}
            class="blueprint-section"
          >
            <div class="blueprint-section-connector">
              <div class="blueprint-node blueprint-node-section">
                <span class="blueprint-node-number">{section_idx + 1}</span>
              </div>
            </div>

            <div class="blueprint-section-content">
              <div class="blueprint-section-header">
                <h2 class="blueprint-section-title">Section {section_idx + 1}</h2>
                <p class="blueprint-section-description">{section.description}</p>
              </div>

              <div class="blueprint-lessons">
                <div
                  :for={{lesson, lesson_idx} <- Enum.with_index(section.lessons)}
                  class="blueprint-lesson"
                >
                  <div class="blueprint-lesson-connector">
                    <div class="blueprint-node blueprint-node-lesson">
                      <span>{section_idx + 1}.{lesson_idx + 1}</span>
                    </div>
                    <div class="blueprint-lesson-line"></div>
                  </div>

                  <div class="blueprint-lesson-card">
                    <h3 class="blueprint-lesson-title">{lesson.title}</h3>
                    <p class="blueprint-lesson-description">{lesson.description}</p>

                    <div :if={lesson.resources != []} class="blueprint-resources">
                      <div class="blueprint-resources-header">
                        <svg
                          class="blueprint-icon-sm"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="1.5"
                        >
                          <path d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m13.35-.622l1.757-1.757a4.5 4.5 0 00-6.364-6.364l-4.5 4.5a4.5 4.5 0 001.242 7.244" />
                        </svg>
                        <span>Resources</span>
                      </div>
                      <div class="blueprint-resource-list">
                        <.resource_item :for={resource <- lesson.resources} resource={resource} />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div :if={section.checkpoint} class="blueprint-checkpoint">
                <div class="blueprint-checkpoint-connector">
                  <div class="blueprint-node blueprint-node-checkpoint">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6h-8.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9" />
                    </svg>
                  </div>
                </div>

                <div class="blueprint-checkpoint-card">
                  <h3 class="blueprint-checkpoint-title">{section.checkpoint.title}</h3>
                  <p class="blueprint-checkpoint-description">{section.checkpoint.description}</p>

                  <div :if={section.checkpoint.tasks != []} class="blueprint-tasks">
                    <div class="blueprint-tasks-header">
                      <svg
                        class="blueprint-icon-sm"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.5"
                      >
                        <path d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <span>Tasks to Complete</span>
                    </div>
                    <ul class="blueprint-task-list">
                      <li :for={task <- section.checkpoint.tasks} class="blueprint-task-item">
                        <div class="blueprint-task-checkbox"></div>
                        <span>{task}</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="blueprint-finish">
            <div class="blueprint-node blueprint-node-finish">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
              </svg>
            </div>
            <span class="blueprint-finish-label">Complete!</span>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :resource, :map, required: true

  defp resource_item(assigns) do
    ~H"""
    <a href={@resource.url} target="_blank" rel="noopener noreferrer" class="blueprint-resource-item">
      <div class="blueprint-resource-icon">
        <.resource_type_icon type={@resource.type} />
      </div>
      <div class="blueprint-resource-info">
        <span class="blueprint-resource-title">{@resource.title}</span>
        <span class="blueprint-resource-type">{@resource.type}</span>
      </div>
      <svg
        class="blueprint-resource-arrow"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
      >
        <path d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
      </svg>
    </a>
    """
  end

  attr :type, :string, required: true

  defp resource_type_icon(%{type: "video"} = assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      <path d="M15.91 11.672a.375.375 0 010 .656l-5.603 3.113a.375.375 0 01-.557-.328V8.887c0-.286.307-.466.557-.327l5.603 3.112z" />
    </svg>
    """
  end

  defp resource_type_icon(%{type: "course"} = assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M4.26 10.147a60.436 60.436 0 00-.491 6.347A48.627 48.627 0 0112 20.904a48.627 48.627 0 018.232-4.41 60.46 60.46 0 00-.491-6.347m-15.482 0a50.57 50.57 0 00-2.658-.813A59.905 59.905 0 0112 3.493a59.902 59.902 0 0110.399 5.84c-.896.248-1.783.52-2.658.814m-15.482 0A50.697 50.697 0 0112 13.489a50.702 50.702 0 017.74-3.342M6.75 15a.75.75 0 100-1.5.75.75 0 000 1.5zm0 0v-3.675A55.378 55.378 0 0112 8.443m-7.007 11.55A5.981 5.981 0 006.75 15.75v-1.5" />
    </svg>
    """
  end

  defp resource_type_icon(%{type: "book"} = assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25" />
    </svg>
    """
  end

  defp resource_type_icon(%{type: "blog"} = assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M12 7.5h1.5m-1.5 3h1.5m-7.5 3h7.5m-7.5 3h7.5m3-9h3.375c.621 0 1.125.504 1.125 1.125V18a2.25 2.25 0 01-2.25 2.25M16.5 7.5V18a2.25 2.25 0 002.25 2.25M16.5 7.5V4.875c0-.621-.504-1.125-1.125-1.125H4.125C3.504 3.75 3 4.254 3 4.875V18a2.25 2.25 0 002.25 2.25h13.5M6 7.5h3v3H6v-3z" />
    </svg>
    """
  end

  defp resource_type_icon(%{type: "article"} = assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
    </svg>
    """
  end

  defp resource_type_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
      <path d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m13.35-.622l1.757-1.757a4.5 4.5 0 00-6.364-6.364l-4.5 4.5a4.5 4.5 0 001.242 7.244" />
    </svg>
    """
  end

  @impl true
  def mount(%{"id" => trail_id}, _session, socket) do
    lesson_plan = Learning.get_lesson_plan_by_trail(socket.assigns.current_scope, trail_id)

    if is_nil(lesson_plan) do
      {:ok,
       socket
       |> put_flash(:error, "Lesson plan not found or not yet generated")
       |> push_navigate(to: ~p"/trails/#{trail_id}")}
    else
      sorted_lesson_plan = sort_lesson_plan(lesson_plan)

      {:ok,
       socket
       |> assign(:page_title, "Lesson Plan")
       |> assign(:lesson_plan, sorted_lesson_plan)}
    end
  end

  defp sort_lesson_plan(lesson_plan) do
    sorted_sections =
      lesson_plan.sections
      |> Enum.sort_by(& &1.order)
      |> Enum.map(fn section ->
        sorted_lessons =
          section.lessons
          |> Enum.sort_by(& &1.order)

        %{section | lessons: sorted_lessons}
      end)

    %{lesson_plan | sections: sorted_sections}
  end
end
