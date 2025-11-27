defmodule Brainstrap.LLM.InteractionTest do
  use Brainstrap.DataCase, async: true

  alias Brainstrap.LLM
  alias Brainstrap.LLM.Interaction

  describe "create_interaction/1" do
    test "creates an interaction with valid attrs" do
      attrs = %{
        model: "openai/gpt-4",
        request_body: %{"messages" => [%{"role" => "user", "content" => "hello"}]},
        response_body: %{"choices" => []},
        status_code: 200,
        duration_ms: 1500,
        prompt_tokens: 10,
        completion_tokens: 20,
        total_tokens: 30,
        cost_usd: Decimal.new("0.001")
      }

      assert {:ok, %Interaction{} = interaction} = LLM.create_interaction(attrs)
      assert interaction.model == "openai/gpt-4"
      assert interaction.status_code == 200
      assert interaction.duration_ms == 1500
      assert interaction.prompt_tokens == 10
      assert interaction.completion_tokens == 20
      assert interaction.total_tokens == 30
    end

    test "requires model and request_body" do
      assert {:error, changeset} = LLM.create_interaction(%{})
      assert %{model: ["can't be blank"], request_body: ["can't be blank"]} = errors_on(changeset)
    end

    test "creates interaction with error field" do
      attrs = %{
        model: "openai/gpt-4",
        request_body: %{"messages" => []},
        error: "Connection timeout",
        duration_ms: 5000
      }

      assert {:ok, %Interaction{} = interaction} = LLM.create_interaction(attrs)
      assert interaction.error == "Connection timeout"
      assert is_nil(interaction.response_body)
    end
  end

  describe "list_interactions/1" do
    test "lists interactions" do
      {:ok, _first} =
        LLM.create_interaction(%{
          model: "model-1",
          request_body: %{}
        })

      {:ok, _second} =
        LLM.create_interaction(%{
          model: "model-2",
          request_body: %{}
        })

      interactions = LLM.list_interactions()
      assert length(interactions) == 2
      models = Enum.map(interactions, & &1.model)
      assert "model-1" in models
      assert "model-2" in models
    end

    test "respects limit option" do
      for i <- 1..5 do
        LLM.create_interaction(%{model: "model-#{i}", request_body: %{}})
      end

      assert length(LLM.list_interactions(limit: 3)) == 3
    end
  end

  describe "get_interaction!/1" do
    test "gets an interaction by id" do
      {:ok, interaction} =
        LLM.create_interaction(%{
          model: "test-model",
          request_body: %{"test" => true}
        })

      fetched = LLM.get_interaction!(interaction.id)
      assert fetched.id == interaction.id
      assert fetched.model == "test-model"
    end

    test "raises for non-existent id" do
      assert_raise Ecto.NoResultsError, fn ->
        LLM.get_interaction!(Ecto.UUID.generate())
      end
    end
  end
end
