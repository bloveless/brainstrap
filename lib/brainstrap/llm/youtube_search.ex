defmodule Brainstrap.LLM.YouTubeSearch do
  @moduledoc """
  Implements YouTube search functionality as an LLM tool.
  """

  @doc """
  Returns the tool definition for the LLM to understand how to call YouTube search.
  """
  def tool_definition do
    %{
      type: "function",
      function: %{
        name: "youtube_search",
        description:
          "Search YouTube for educational videos on a specific topic. Returns video titles, URLs, channel names, and descriptions.",
        parameters: %{
          type: "object",
          properties: %{
            query: %{
              type: "string",
              description: "The search query for finding relevant educational videos"
            },
            max_results: %{
              type: "integer",
              description: "Maximum number of results to return (default: 5, max: 10)",
              default: 5
            }
          },
          required: ["query"]
        }
      }
    }
  end

  @doc """
  Executes the YouTube search using the YouTube Data API v3.
  Requires YOUTUBE_API_KEY environment variable to be set.
  """
  def execute(query, max_results \\ 10) do
    api_key = Application.fetch_env!(:brainstrap, :youtube_api_key)

    search_youtube(query, min(max_results, 10), api_key)
  end

  defp search_youtube(query, max_results, api_key) do
    url = "https://www.googleapis.com/youtube/v3/search"

    params = [
      part: "snippet",
      q: query,
      type: "video",
      maxResults: max_results,
      key: api_key,
      order: "relevance",
      videoDefinition: "any",
      safeSearch: "moderate"
    ]

    case Req.get(url, params: params) do
      {:ok, %{status: 200, body: body}} ->
        videos = parse_youtube_response(body)
        {:ok, videos}

      {:ok, %{status: status, body: body}} ->
        {:error, "YouTube API error: #{status} - #{inspect(body)}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp parse_youtube_response(%{"items" => items}) do
    Enum.map(items, fn item ->
      snippet = item["snippet"]
      video_id = item["id"]["videoId"]

      %{
        title: snippet["title"],
        description: snippet["description"],
        channel: snippet["channelTitle"],
        url: "https://www.youtube.com/watch?v=#{video_id}",
        thumbnail: snippet["thumbnails"]["default"]["url"],
        published_at: snippet["publishedAt"]
      }
    end)
  end

  defp parse_youtube_response(_), do: []
end
