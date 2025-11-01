defmodule Brainstrap.LearningFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Brainstrap.Learning` context.
  """

  @doc """
  Generate a trail.
  """
  def trail_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        name: "some name"
      })

    {:ok, trail} = Brainstrap.Learning.create_trail(scope, attrs)
    trail
  end
end
