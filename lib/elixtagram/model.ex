defmodule Elixtagram.Model.ClientConfig do
  defstruct client_id: nil

  # @type t :: %__MODULE__{}
end

defmodule Elixtagram.Model.Response do
  @derive [Poison.Encoder]
  defstruct data: nil
end

defmodule Elixtagram.Model.Tag do
  @derive [Poison.Encoder]
  defstruct name: nil, media_count: nil
end
