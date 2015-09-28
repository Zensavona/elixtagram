defmodule Elixtagram.API.Tags do
  import Elixtagram.API.Base

  def tag(tag_name) do
    tag = Elixtagram.API.Base.request(:get, "/tags/#{tag_name}")
    %Elixtagram.Model.Tag{name: tag[:name], media_count: tag[:media_count]}
  end
end
