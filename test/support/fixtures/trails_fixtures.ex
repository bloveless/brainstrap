defmodule Brainstrap.TrailsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Brainstrap.Trails` context.
  """

  @doc """
  Generate a trail.
  """
  def trail_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, trail} = Brainstrap.Trails.create_trail(scope, attrs)
    trail
  end
end
