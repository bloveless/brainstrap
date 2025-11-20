defmodule BrainstrapWeb.TrailLive.Index do
  use BrainstrapWeb, :live_view

  alias Brainstrap.Learning

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Trails
        <:actions>
          <.button variant="primary" navigate={~p"/trails/new"}>
            <.icon name="hero-plus" /> New Trail
          </.button>
        </:actions>
      </.header>

      <.table
        id="trails"
        rows={@streams.trails}
        row_click={fn {_id, trail} -> JS.navigate(~p"/trails/#{trail}") end}
      >
        <:col :let={{_id, trail}} label="Name">{trail.name}</:col>
        <:col :let={{_id, trail}} label="Description">{trail.description}</:col>
        <:action :let={{_id, trail}}>
          <div class="sr-only">
            <.link navigate={~p"/trails/#{trail}"}>Show</.link>
          </div>
          <.link navigate={~p"/trails/#{trail}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, trail}}>
          <.link
            phx-click={JS.push("delete", value: %{id: trail.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Learning.subscribe_trails(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Trails")
     |> stream(:trails, list_trails(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    trail = Learning.get_trail!(socket.assigns.current_scope, id)
    {:ok, _} = Learning.delete_trail(socket.assigns.current_scope, trail)

    {:noreply, stream_delete(socket, :trails, trail)}
  end

  @impl true
  def handle_info({type, %Brainstrap.Learning.Trail{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :trails, list_trails(socket.assigns.current_scope), reset: true)}
  end

  defp list_trails(current_scope) do
    Learning.list_trails(current_scope)
  end
end
