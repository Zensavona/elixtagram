defmodule Elixtagram.Config do
  def configure(:client_id, client_id) do
    start_link(%Elixtagram.Model.ClientConfig{client_id: client_id})
  end

  def get(:client_id) do
    Agent.get(__MODULE__, fn config -> config.client_id end)
  end

  defp start_link(value) do
    Agent.start_link(fn -> value end, name: __MODULE__)
  end
end
