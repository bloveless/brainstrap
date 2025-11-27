defmodule BrainstrapWeb.InteractionLive.Show do
  use BrainstrapWeb, :live_view

  alias Brainstrap.LLM

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Interaction Details
        <:subtitle>
          {@interaction.model} - {Calendar.strftime(@interaction.inserted_at, "%Y-%m-%d %H:%M:%S")}
        </:subtitle>
        <:actions>
          <.button navigate={~p"/dev/interactions"}>
            <.icon name="hero-arrow-left" /> Back
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Model">{@interaction.model}</:item>
        <:item title="Lesson Plan Id">{@interaction.lesson_plan.id}</:item>
        <:item title="Status Code">{@interaction.status_code}</:item>
        <:item title="Duration">{@interaction.duration_ms}ms</:item>
        <:item title="Prompt Tokens">{@interaction.prompt_tokens}</:item>
        <:item title="Completion Tokens">{@interaction.completion_tokens}</:item>
        <:item title="Total Tokens">{@interaction.total_tokens}</:item>
        <:item title="Cost">
          {if @interaction.cost_usd, do: "$#{@interaction.cost_usd}", else: "-"}
        </:item>
        <:item :if={@interaction.error} title="Error">
          <span class="text-red-600">{@interaction.error}</span>
        </:item>
        <:item title="Request Body">
          <span>
            <pre>{inspect(@interaction.request_body, pretty: true, limit: :infinity, printable_limit: :infinity)}</pre>
          </span>
        </:item>
        <:item title="Response Body">
          <span>
            <pre>{inspect(@interaction.response_body, pretty: true, limit: :infinity, printable_limit: :infinity)}</pre>
          </span>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    interaction = LLM.get_interaction!(id)

    {:ok,
     socket
     |> assign(:page_title, "Interaction #{String.slice(id, 0, 8)}")
     |> assign(:interaction, interaction)}
  end
end
