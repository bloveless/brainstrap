defmodule BrainstrapWeb.TrailLiveTest do
  use BrainstrapWeb.ConnCase

  import Phoenix.LiveViewTest
  import Brainstrap.TrailsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup :register_and_log_in_user

  defp create_trail(%{scope: scope}) do
    trail = trail_fixture(scope)

    %{trail: trail}
  end

  describe "Index" do
    setup [:create_trail]

    test "lists all trails", %{conn: conn, trail: trail} do
      {:ok, _index_live, html} = live(conn, ~p"/trails")

      assert html =~ "Listing Trails"
      assert html =~ trail.name
    end

    test "saves new trail", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/trails")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Trail")
               |> render_click()
               |> follow_redirect(conn, ~p"/trails/new")

      assert render(form_live) =~ "New Trail"

      assert form_live
             |> form("#trail-form", trail: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#trail-form", trail: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trails")

      html = render(index_live)
      assert html =~ "Trail created successfully"
      assert html =~ "some name"
    end

    test "updates trail in listing", %{conn: conn, trail: trail} do
      {:ok, index_live, _html} = live(conn, ~p"/trails")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#trails-#{trail.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/trails/#{trail}/edit")

      assert render(form_live) =~ "Edit Trail"

      assert form_live
             |> form("#trail-form", trail: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#trail-form", trail: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trails")

      html = render(index_live)
      assert html =~ "Trail updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes trail in listing", %{conn: conn, trail: trail} do
      {:ok, index_live, _html} = live(conn, ~p"/trails")

      assert index_live |> element("#trails-#{trail.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#trails-#{trail.id}")
    end
  end

  describe "Show" do
    setup [:create_trail]

    test "displays trail", %{conn: conn, trail: trail} do
      {:ok, _show_live, html} = live(conn, ~p"/trails/#{trail}")

      assert html =~ "Show Trail"
      assert html =~ trail.name
    end

    test "updates trail and returns to show", %{conn: conn, trail: trail} do
      {:ok, show_live, _html} = live(conn, ~p"/trails/#{trail}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/trails/#{trail}/edit?return_to=show")

      assert render(form_live) =~ "Edit Trail"

      assert form_live
             |> form("#trail-form", trail: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#trail-form", trail: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/trails/#{trail}")

      html = render(show_live)
      assert html =~ "Trail updated successfully"
      assert html =~ "some updated name"
    end
  end
end
