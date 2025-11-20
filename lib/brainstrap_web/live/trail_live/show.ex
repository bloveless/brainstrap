defmodule BrainstrapWeb.TrailLive.Show do
  use BrainstrapWeb, :live_view

  alias Brainstrap.Learning

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
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Learning.subscribe_trails(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Trail")
     |> assign(:trail, Learning.get_trail!(socket.assigns.current_scope, id))}
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
