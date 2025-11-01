defmodule BrainstrapWeb.TrailController do
  use BrainstrapWeb, :controller

  alias Brainstrap.Learning
  alias Brainstrap.Learning.Trail

  def index(conn, _params) do
    trails = Learning.list_trails(conn.assigns.current_scope)
    render(conn, :index, trails: trails)
  end

  def new(conn, _params) do
    changeset =
      Learning.change_trail(conn.assigns.current_scope, %Trail{
        user_id: conn.assigns.current_scope.user.id
      })

    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"trail" => trail_params}) do
    case Learning.create_trail(conn.assigns.current_scope, trail_params) do
      {:ok, trail} ->
        conn
        |> put_flash(:info, "Trail created successfully.")
        |> redirect(to: ~p"/trails/#{trail}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    trail = Learning.get_trail!(conn.assigns.current_scope, id)
    render(conn, :show, trail: trail)
  end

  def edit(conn, %{"id" => id}) do
    trail = Learning.get_trail!(conn.assigns.current_scope, id)
    changeset = Learning.change_trail(conn.assigns.current_scope, trail)
    render(conn, :edit, trail: trail, changeset: changeset)
  end

  def update(conn, %{"id" => id, "trail" => trail_params}) do
    trail = Learning.get_trail!(conn.assigns.current_scope, id)

    case Learning.update_trail(conn.assigns.current_scope, trail, trail_params) do
      {:ok, trail} ->
        conn
        |> put_flash(:info, "Trail updated successfully.")
        |> redirect(to: ~p"/trails/#{trail}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, trail: trail, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    trail = Learning.get_trail!(conn.assigns.current_scope, id)
    {:ok, _trail} = Learning.delete_trail(conn.assigns.current_scope, trail)

    conn
    |> put_flash(:info, "Trail deleted successfully.")
    |> redirect(to: ~p"/trails")
  end
end
