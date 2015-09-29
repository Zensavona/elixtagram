defmodule Elixtagram.API.Tags do
  import Elixtagram.API.Base

  def tag(tag_name) do
    tag = request(:get, "/tags/#{tag_name}")
    struct Elixtagram.Model.Tag, tag
  end

  def search(query) do
    tags = request :get, "/tags/search", [["q", query]]
    Enum.map(tags, fn tag -> struct(Elixtagram.Model.Tag, tag) end)
  end
end
