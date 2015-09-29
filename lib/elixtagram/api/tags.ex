defmodule Elixtagram.API.Tags do
  import Elixtagram.API.Base

  def tag(tag_name) do
    request(:get, "/tags/#{tag_name}", :global) |> to_tag
  end
  def tag(tag_name, token) do
    request(:get, "/tags/#{tag_name}", token) |> to_tag
  end

  def search(query) do
    tags = request(:get, "/tags/search", :global, [["q", query]])
    Enum.map(tags, fn tag -> to_tag tag end)
  end

  defp to_tag(tag), do: struct(Elixtagram.Model.Tag, tag)
end
