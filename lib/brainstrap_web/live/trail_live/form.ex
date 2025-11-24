defmodule BrainstrapWeb.TrailLive.Form do
  use BrainstrapWeb, :live_view

  alias Brainstrap.Learning
  alias Brainstrap.Learning.Trail
  alias Brainstrap.Workers.GenerateLessonPlan

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage trail records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="trail-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <footer class="flex">
          <div class="flex-1">
            <.button phx-disable-with="Saving..." variant="primary">Save Trail</.button>
            <.button navigate={return_path(@current_scope, @return_to, @trail)}>Cancel</.button>
          </div>
          <div class="flex-none">
            <.button phx-disable-with="Enhancing..." phx-click="enhance" variant="secondary">
              Enhance
            </.button>
          </div>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    trail = Learning.get_trail!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Trail \"#{trail.name}\"")
    |> assign(:trail, trail)
    |> assign(:form, to_form(Learning.change_trail(socket.assigns.current_scope, trail)))
  end

  defp apply_action(socket, :new, _params) do
    trail = %Trail{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Trail")
    |> assign(:trail, trail)
    |> assign(:form, to_form(Learning.change_trail(socket.assigns.current_scope, trail)))
  end

  @impl true
  def handle_event("validate", %{"trail" => trail_params}, socket) do
    changeset =
      Learning.change_trail(socket.assigns.current_scope, socket.assigns.trail, trail_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"trail" => trail_params}, socket) do
    save_trail(socket, socket.assigns.live_action, trail_params)
  end

  def handle_event("enhance", _params, socket) do
    changeset = socket.assigns.form.source
    current_name = Ecto.Changeset.get_field(changeset, :name)
    current_description = Ecto.Changeset.get_field(changeset, :description)

    {:ok, resp} =
      Brainstrap.LLM.enhance_prompt(current_name, current_description)

    enhanced_changeset =
      Learning.change_trail(
        socket.assigns.current_scope,
        socket.assigns.trail,
        %{"name" => resp["name"], "description" => resp["description"]}
      )

    {:noreply, assign(socket, form: to_form(enhanced_changeset))}
  end

  defp save_trail(socket, :edit, trail_params) do
    case Learning.update_trail(socket.assigns.current_scope, socket.assigns.trail, trail_params) do
      {:ok, trail} ->
        %{trail_id: trail.id}
        |> GenerateLessonPlan.new()
        |> Oban.insert()

        {:noreply,
         socket
         |> put_flash(:info, "Trail updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, trail)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_trail(socket, :new, trail_params) do
    case Learning.create_trail(socket.assigns.current_scope, trail_params) do
      {:ok, trail} ->
        %{trail_id: trail.id}
        |> GenerateLessonPlan.new()
        |> Oban.insert()

        {:noreply,
         socket
         |> put_flash(:info, "Trail created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, trail)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _trail), do: ~p"/trails"
  defp return_path(_scope, "show", trail), do: ~p"/trails/#{trail}"
end
