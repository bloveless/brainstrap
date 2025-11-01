defmodule BrainstrapWeb.TrailControllerTest do
  use BrainstrapWeb.ConnCase

  import Brainstrap.LearningFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  setup :register_and_log_in_user

  describe "index" do
    test "lists all trails", %{conn: conn} do
      conn = get(conn, ~p"/trails")
      assert html_response(conn, 200) =~ "Listing Trails"
    end
  end

  describe "new trail" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/trails/new")
      assert html_response(conn, 200) =~ "New Trail"
    end
  end

  describe "create trail" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/trails", trail: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/trails/#{id}"

      conn = get(conn, ~p"/trails/#{id}")
      assert html_response(conn, 200) =~ "Trail #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/trails", trail: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Trail"
    end
  end

  describe "edit trail" do
    setup [:create_trail]

    test "renders form for editing chosen trail", %{conn: conn, trail: trail} do
      conn = get(conn, ~p"/trails/#{trail}/edit")
      assert html_response(conn, 200) =~ "Edit Trail"
    end
  end

  describe "update trail" do
    setup [:create_trail]

    test "redirects when data is valid", %{conn: conn, trail: trail} do
      conn = put(conn, ~p"/trails/#{trail}", trail: @update_attrs)
      assert redirected_to(conn) == ~p"/trails/#{trail}"

      conn = get(conn, ~p"/trails/#{trail}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, trail: trail} do
      conn = put(conn, ~p"/trails/#{trail}", trail: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Trail"
    end
  end

  describe "delete trail" do
    setup [:create_trail]

    test "deletes chosen trail", %{conn: conn, trail: trail} do
      conn = delete(conn, ~p"/trails/#{trail}")
      assert redirected_to(conn) == ~p"/trails"

      assert_error_sent 404, fn ->
        get(conn, ~p"/trails/#{trail}")
      end
    end
  end

  defp create_trail(%{scope: scope}) do
    trail = trail_fixture(scope)

    %{trail: trail}
  end
end
