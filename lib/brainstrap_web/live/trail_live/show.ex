defmodule BrainstrapWeb.TrailLive.Show do
  use BrainstrapWeb, :live_view

  alias Brainstrap.Learning
  alias Brainstrap.Workers.GenerateLessonPlan

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Trail "{@trail.name}"
        <:subtitle>This is a trail record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/trails"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/trails/#{@trail}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit trail
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@trail.name}</:item>
        <:item title="Description">{@trail.description}</:item>
      </.list>

      <section class="mt-8">
        <.button
          :if={is_nil(@trail.generation_requested_at)}
          phx-click="generate_lesson_plan"
          phx-disable-with="Generating..."
          variant="primary"
        >
          <.icon name="hero-sparkles" /> Generate Lesson Plan
        </.button>
        <div :if={@trail.generation_requested_at}>
          <.button :if={@lesson_plan} navigate={~p"/trails/#{@trail}/lesson-plan"} variant="primary">
            <.icon name="hero-map" /> View Lesson Plan
          </.button>
          <p :if={is_nil(@lesson_plan)} class="text-sm text-zinc-500">
            Lesson plan generation has been requested. This may take a few minutes.
          </p>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Learning.subscribe_trails(socket.assigns.current_scope)
    end

    trail = Learning.get_trail!(socket.assigns.current_scope, id)
    lesson_plan = Learning.get_lesson_plan_by_trail(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Trail")
     |> assign(:trail, trail)
     |> assign(:lesson_plan, lesson_plan)}
  end

  @impl true
  def handle_event("generate_lesson_plan", _params, socket) do
    trail = socket.assigns.trail

    case Learning.request_generation(socket.assigns.current_scope, trail) do
      {:ok, updated_trail} ->
        %{trail_id: trail.id}
        |> GenerateLessonPlan.new()
        |> Oban.insert()

        {:noreply,
         socket
         |> assign(:trail, updated_trail)
         |> put_flash(:info, "Lesson plan generation started")}

      {:error, :already_requested} ->
        {:noreply, put_flash(socket, :error, "Lesson plan generation was already requested")}
    end
  end

  @impl true
  def handle_info(
        {:updated, %Brainstrap.Learning.Trail{id: id} = trail},
        %{assigns: %{trail: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :trail, trail)}
  end

  def handle_info(
        {:deleted, %Brainstrap.Learning.Trail{id: id}},
        %{assigns: %{trail: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current trail was deleted.")
     |> push_navigate(to: ~p"/trails")}
  end

  def handle_info({type, %Brainstrap.Learning.Trail{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
