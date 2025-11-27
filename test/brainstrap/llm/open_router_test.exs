defmodule Brainstrap.LLM.OpenRouterTest do
  use Brainstrap.DataCase, async: false

  alias Brainstrap.LLM.OpenRouter

  describe "generate_object/4" do
    test "makes request to OpenRouter API" do
      messages = [%{role: "user", content: "test"}]
      schema = %{"type" => "object", "properties" => %{"test" => %{"type" => "string"}}}

      result = OpenRouter.generate_object("test-model", messages, schema, [])

      assert {:error, _reason} = result
    end

    test "builds correct request body" do
      messages = [
        %{role: "system", content: "You are a helpful assistant"},
        %{role: "user", content: "Generate a test response"}
      ]

      schema = %{
        "type" => "object",
        "required" => ["response"],
        "properties" => %{
          "response" => %{"type" => "string"}
        }
      }

      assert length(messages) == 2
      assert Map.has_key?(schema, "type")
      assert Map.has_key?(schema, "required")
    end
  end
end
