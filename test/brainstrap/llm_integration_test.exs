defmodule Brainstrap.LLMIntegrationTest do
  use ExUnit.Case, async: false

  # These tests demonstrate that LLM module integration works
  # They don't make actual API calls but verify structure

  describe "LLM module integration" do
    test "lesson plan schema is valid" do
      schema = Brainstrap.LLM.LessonPlan.schema()

      assert is_map(schema)
      assert Map.get(schema, "type") == "object"
      assert is_list(Map.get(schema, "required", []))
      assert is_map(Map.get(schema, "properties", %{}))
    end

    test "enhance prompt schema is valid" do
      schema = Brainstrap.LLM.EnhancePrompt.schema()

      assert is_map(schema)
      assert Map.get(schema, "type") == "object"
      assert is_list(Map.get(schema, "required", []))
      assert is_map(Map.get(schema, "properties", %{}))
    end

    test "OpenRouter client can be imported" do
      # Verify the OpenRouter module exists and has the expected function
      assert {:module, Brainstrap.LLM.OpenRouter} = Code.ensure_loaded?(Brainstrap.LLM.OpenRouter)
      assert function_exported?(Brainstrap.LLM.OpenRouter, :generate_object, 4)
    end
  end
end
