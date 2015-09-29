defmodule Elixtagram.API.Tags do
  import Elixtagram.API.Base

  def tag(tag_name) do
    structure = Elixtagram.API.Base.get("/tags/#{tag_name}")
      |> Poison.decode! as: %{"data" => Elixtagram.Model.Tag}
    structure["data"]
  end
end
