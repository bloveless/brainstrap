defmodule Brainstrap.TrailsTest do
  use Brainstrap.DataCase

  alias Brainstrap.Trails

  describe "trails" do
    alias Brainstrap.Trails.Trail

    import Brainstrap.AccountsFixtures, only: [user_scope_fixture: 0]
    import Brainstrap.TrailsFixtures

    @invalid_attrs %{name: nil}

    test "list_trails/1 returns all scoped trails" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      trail = trail_fixture(scope)
      other_trail = trail_fixture(other_scope)
      assert Trails.list_trails(scope) == [trail]
      assert Trails.list_trails(other_scope) == [other_trail]
    end

    test "get_trail!/2 returns the trail with given id" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      other_scope = user_scope_fixture()
      assert Trails.get_trail!(scope, trail.id) == trail
      assert_raise Ecto.NoResultsError, fn -> Trails.get_trail!(other_scope, trail.id) end
    end

    test "create_trail/2 with valid data creates a trail" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Trail{} = trail} = Trails.create_trail(scope, valid_attrs)
      assert trail.name == "some name"
      assert trail.user_id == scope.user.id
    end

    test "create_trail/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Trails.create_trail(scope, @invalid_attrs)
    end

    test "update_trail/3 with valid data updates the trail" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Trail{} = trail} = Trails.update_trail(scope, trail, update_attrs)
      assert trail.name == "some updated name"
    end

    test "update_trail/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      trail = trail_fixture(scope)

      assert_raise MatchError, fn ->
        Trails.update_trail(other_scope, trail, %{})
      end
    end

    test "update_trail/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Trails.update_trail(scope, trail, @invalid_attrs)
      assert trail == Trails.get_trail!(scope, trail.id)
    end

    test "delete_trail/2 deletes the trail" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert {:ok, %Trail{}} = Trails.delete_trail(scope, trail)
      assert_raise Ecto.NoResultsError, fn -> Trails.get_trail!(scope, trail.id) end
    end

    test "delete_trail/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert_raise MatchError, fn -> Trails.delete_trail(other_scope, trail) end
    end

    test "change_trail/2 returns a trail changeset" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert %Ecto.Changeset{} = Trails.change_trail(scope, trail)
    end
  end
end
