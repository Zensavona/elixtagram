defmodule Elixtagram.Config do
  def configure(client_id, client_secret, redirect_uri) do
    start_link(%Elixtagram.Model.ClientConfig{client_id: client_id, client_secret: client_secret, redirect_uri: redirect_uri})
  end

  def configure do
    start_link(%Elixtagram.Model.ClientConfig{
      client_id: System.get_env("INSTAGRAM_CLIENT_ID"),
      client_secret: System.get_env("INSTAGRAM_CLIENT_SECRET"),
      redirect_uri: System.get_env("INSTAGRAM_REDIRECT_URI")
      })
  end

  def configure(:global, token) do
    set_val(:access_token, token)
  end

  def get do
    Agent.get(__MODULE__, fn config -> config end)
  end

  defp set_val(key, value) do
    Agent.update(__MODULE__, fn config ->
      Map.update!(config, key, fn _ -> value end)
    end)
  end

  defp start_link(value) do
    Agent.start_link(fn -> value end, name: __MODULE__)
  end
end
