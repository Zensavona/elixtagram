defmodule Elixtagram.API.Tags do
  @moduledoc """
  Provides access to the `/tags/` area of the Instagram API.
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetch a `%Elixtagram.Model.Tag` representing a single tag from the API,
  optionally take an access token.
  """
  def tag(tag_name, token \\ :global) do
    request(:get, "/tags/#{tag_name}", token).data |> parse_tag
  end

  @doc """
  Fetch a list of tags as `%Elixtagram.Model.Tag` from the API who match a query.
  Optionally take an access token.
  """
  def search(query, token \\ :global) do
    request(:get, "/tags/search", token, [["q", query]]).data |> Enum.map(&parse_tag/1)
  end

  @doc """
  Fetch a list of n recent medias as `%Elixtagram.Model.Media` for a given tag.
  Optionally takes an access token.
  """
  def recent_media([tag: tag_name, count: count], token \\ :global) do
    request(:get, "/tags/#{tag_name}/media/recent", token, [["count", count]]).data |> Enum.map(&parse_media(&1))
  end
end
