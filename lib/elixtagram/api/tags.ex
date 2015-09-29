defmodule Elixtagram.API.Tags do
  import Elixtagram.API.Base

  @doc """
  Fetch a `Elixtagram.Model.Tag` representing a single tag from the API,
  optionally take an access token.
  """
  def tag(tag_name, token \\ :global) do
    request(:get, "/tags/#{tag_name}", token) |> to_tag
  end

  @doc """
  Fetch a list of tags from the API who match a query. Optionally take
  an access token.
  """
  def search(query, token \\ :global) do
    tags = request(:get, "/tags/search", token, [["q", query]])
    Enum.map(tags, fn tag -> to_tag tag end)
  end

  def recent_media([tag: tag_name, count: count], token \\ :global) do
    medias = request(:get, "/tags/#{tag_name}/media/recent", token, [["count", count]])
    Enum.map(medias, fn media -> to_media media end)
  end

  # def recent_media([tag: tag_name, count: count, max_tag_id: max_tag_id], token \\ :global) do
  # end
  # def recent_media([tag: tag_name, count: count], token \\ :global) do
  # end

  defp to_tag(tag), do: struct(Elixtagram.Model.Tag, tag)
  defp to_media(media), do: struct(Elixtragram.Model.Media, media)
end
