defmodule Elixtagram do

  defdelegate configure(:client_id, client_id), to: Elixtagram.Config, as: :configure

end
