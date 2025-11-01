defmodule Brainstrap.LearningTest do
  use Brainstrap.DataCase

  alias Brainstrap.Learning

  describe "trails" do
    alias Brainstrap.Learning.Trail

    import Brainstrap.AccountsFixtures, only: [user_scope_fixture: 0]
    import Brainstrap.LearningFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_trails/1 returns all scoped trails" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      trail = trail_fixture(scope)
      other_trail = trail_fixture(other_scope)
      assert Learning.list_trails(scope) == [trail]
      assert Learning.list_trails(other_scope) == [other_trail]
    end

    test "get_trail!/2 returns the trail with given id" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      other_scope = user_scope_fixture()
      assert Learning.get_trail!(scope, trail.id) == trail
      assert_raise Ecto.NoResultsError, fn -> Learning.get_trail!(other_scope, trail.id) end
    end

    test "create_trail/2 with valid data creates a trail" do
      valid_attrs = %{name: "some name", description: "some description"}
      scope = user_scope_fixture()

      assert {:ok, %Trail{} = trail} = Learning.create_trail(scope, valid_attrs)
      assert trail.name == "some name"
      assert trail.description == "some description"
      assert trail.user_id == scope.user.id
    end

    test "create_trail/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Learning.create_trail(scope, @invalid_attrs)
    end

    test "update_trail/3 with valid data updates the trail" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Trail{} = trail} = Learning.update_trail(scope, trail, update_attrs)
      assert trail.name == "some updated name"
      assert trail.description == "some updated description"
    end

    test "update_trail/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      trail = trail_fixture(scope)

      assert_raise MatchError, fn ->
        Learning.update_trail(other_scope, trail, %{})
      end
    end

    test "update_trail/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Learning.update_trail(scope, trail, @invalid_attrs)
      assert trail == Learning.get_trail!(scope, trail.id)
    end

    test "delete_trail/2 deletes the trail" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert {:ok, %Trail{}} = Learning.delete_trail(scope, trail)
      assert_raise Ecto.NoResultsError, fn -> Learning.get_trail!(scope, trail.id) end
    end

    test "delete_trail/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert_raise MatchError, fn -> Learning.delete_trail(other_scope, trail) end
    end

    test "change_trail/2 returns a trail changeset" do
      scope = user_scope_fixture()
      trail = trail_fixture(scope)
      assert %Ecto.Changeset{} = Learning.change_trail(scope, trail)
    end
  end
end
