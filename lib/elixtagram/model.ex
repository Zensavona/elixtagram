defmodule Elixtagram.Model.ClientConfig do
  defstruct client_id: nil, client_secret: nil, redirect_uri: nil, access_token: nil

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
