defmodule Brainstrap.LLM.SimpleTest do
  use ExUnit.Case, async: true

  # Simple tests that don't require database or API calls

  test "OpenRouter module exists" do
    assert Code.ensure_loaded?(Brainstrap.LLM.OpenRouter) == {:module, Brainstrap.LLM.OpenRouter}
  end

  test "OpenRouter has generate_object function" do
    assert function_exported?(Brainstrap.LLM.OpenRouter, :generate_object, 4)
  end

  test "schemas are valid maps" do
    lesson_schema = Brainstrap.LLM.LessonPlan.schema()
    enhance_schema = Brainstrap.LLM.EnhancePrompt.schema()

    assert is_map(lesson_schema)
    assert is_map(enhance_schema)
  end

  test "schemas have required structure" do
    lesson_schema = Brainstrap.LLM.LessonPlan.schema()
    enhance_schema = Brainstrap.LLM.EnhancePrompt.schema()

    assert Map.get(lesson_schema, "type") == "object"
    assert Map.get(enhance_schema, "type") == "object"

    assert is_list(Map.get(lesson_schema, "required", []))
    assert is_list(Map.get(enhance_schema, "required", []))
  end
end
