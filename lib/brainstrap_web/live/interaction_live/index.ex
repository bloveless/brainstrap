defmodule BrainstrapWeb.InteractionLive.Index do
  use BrainstrapWeb, :live_view

  alias Brainstrap.LLM

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        LLM Interactions Log
        <:subtitle>Browse recent LLM API calls</:subtitle>
      </.header>

      <.table id="interactions" rows={@streams.interactions}>
        <:col :let={{_id, interaction}} label="Model">{interaction.model}</:col>
        <:col :let={{_id, interaction}} label="Status">{interaction.status_code}</:col>
        <:col :let={{_id, interaction}} label="Tokens">{interaction.total_tokens}</:col>
        <:col :let={{_id, interaction}} label="Duration">{interaction.duration_ms}ms</:col>
        <:col :let={{_id, interaction}} label="Cost">
          {if interaction.cost_usd, do: "$#{interaction.cost_usd}", else: "-"}
        </:col>
        <:col :let={{_id, interaction}} label="Time">
          {Calendar.strftime(interaction.inserted_at, "%Y-%m-%d %H:%M:%S")}
        </:col>
        <:action :let={{_id, interaction}}>
          <.link navigate={~p"/dev/interactions/#{interaction}"}>View</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "LLM Interactions")
     |> stream(:interactions, LLM.list_interactions(limit: 100))}
  end
end
