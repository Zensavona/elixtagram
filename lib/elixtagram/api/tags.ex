defmodule Elixtagram.API.Tags do
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetch a `Elixtagram.Model.Tag` representing a single tag from the API,
  optionally take an access token.
  """
  def tag(tag_name, token \\ :global) do
    request(:get, "/tags/#{tag_name}", token) |> parse_tag
  end

  @doc """
  Fetch a list of tags from the API who match a query. Optionally take
  an access token.
  """
  def search(query, token \\ :global) do
    request(:get, "/tags/search", token, [["q", query]]) |> Enum.map(&parse_tag/1)
  end

  def recent_media([tag: tag_name, count: count], token \\ :global) do
    request(:get, "/tags/#{tag_name}/media/recent", token, [["count", count]])
      |> Enum.map(&parse_media(&1))
  end
end
