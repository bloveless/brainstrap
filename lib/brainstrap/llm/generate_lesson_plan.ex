defmodule Brainstrap.LLM.GenerateLessonPlan do
  def model() do
    # "openai/gpt-5.1"
    "google/gemini-2.5-pro"
    # "google/gemini-3-pro-preview"
    # "x-ai/grok-4.1-fast"
  end

  def model_options() do
    [
      max_output_tokens: 50_000,
      tools: [Brainstrap.LLM.YouTubeSearch.tool_definition()],
      reasoning: true,
      max_web_results: 10
    ]
  end

  def system_prompt() do
    """
    # What we are doing
    Our main goal is to suggest a learning plan for people who are trying to learn something. The plan should include
    a few lessons followed by a checkpoint where the user can practice what they have learned so far. Each plan and
    checkout should be incremental and build upon the previous lesson or checkpoint.

    ## Who you are
    You are a friendly LLM who's purpose in life is to help users learn. You favorite thing is scouring the internet
    looking for articles, blog posts, videos on YouTube, and books trying to put together the best learning plans for
    those who have come to you for help. Your goal is to target at least 4 sections with 4 lessons and one checkpoint
    per section.

    ## Steps
    Search google and YouTube specifically looking for any resources that might help the user learn the subject they
    are looking to learn.

    Feel free to use your internal knowledge to prioritize the resources you find from most simple to most complicated
    and put together a learning plan for your student. DO NOT UNDER ANY CIRCUMSTANCE USE YOUR INTERNAL KNOWLEDGE TO
    SUGGEST LEARNING MATERIALS. Only use real resources that you found online and only suggest real websites and videos.
    """
  end

  def schema() do
    %{
      "$schema" => "https://json-schema.org/draft/2020-12/schema",
      "type" => "object",
      "required" => ["description", "prerequisites", "sections"],
      "properties" => %{
        "description" => %{
          "type" => "string"
        },
        "prerequisites" => %{
          "type" => "array",
          "items" => %{
            "type" => "string"
          }
        },
        "sections" => %{
          "type" => "array",
          "items" => %{
            "type" => "object",
            "required" => ["description", "lessons", "checkpoint"],
            "properties" => %{
              "description" => %{
                "type" => "string"
              },
              "lessons" => %{
                "type" => "array",
                "items" => %{
                  "type" => "object",
                  "required" => ["title", "description", "resources"],
                  "properties" => %{
                    "title" => %{
                      "type" => "string"
                    },
                    "description" => %{
                      "type" => "string"
                    },
                    "resources" => %{
                      "type" => "array",
                      "items" => %{
                        "type" => "object",
                        "required" => ["title", "description", "type", "url"],
                        "properties" => %{
                          "title" => %{
                            "type" => "string"
                          },
                          "description" => %{
                            "type" => "string"
                          },
                          "type" => %{
                            "type" => "string",
                            "enum" => ["course", "video", "blog", "book", "article"]
                          },
                          "url" => %{
                            "type" => "string",
                            "format" => "uri"
                          }
                        }
                      }
                    }
                  }
                }
              },
              "checkpoint" => %{
                "type" => "object",
                "required" => ["title", "description", "tasks"],
                "properties" => %{
                  "title" => %{
                    "type" => "string"
                  },
                  "description" => %{
                    "type" => "string"
                  },
                  "tasks" => %{
                    "type" => "array",
                    "items" => %{
                      "type" => "string"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  end
end
