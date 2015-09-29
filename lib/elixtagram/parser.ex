defmodule Elixtagram.Parser do

  def parse_tag(object) do
    struct(Elixtagram.Model.Tag, object)
  end

  def parse_media(object) do
    struct(Elixtagram.Model.Media, object)
  end
end
