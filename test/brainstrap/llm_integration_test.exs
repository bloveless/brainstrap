defmodule Brainstrap.LLMIntegrationTest do
  use ExUnit.Case, async: false

  describe "LLM module integration" do
    test "lesson plan schema is valid" do
      schema = Brainstrap.LLM.GenerateLessonPlan.schema()

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
      assert Code.ensure_loaded?(Brainstrap.LLM.OpenRouter)
      assert function_exported?(Brainstrap.LLM.OpenRouter, :generate_object, 4)
    end
  end
end
