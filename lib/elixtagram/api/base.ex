defmodule Elixtagram.API.Base do
  @base_url "https://api.instagram.com/v1"

  def request(:get, url_part, token \\ :global, params \\ []) do
    [url_part, params]
      |> build_url(token)
      |> HTTPoison.get!
      |> process_response
  end

  defp process_response(data) do
    data.body
    |> Poison.decode!(keys: :atoms)
    |> Map.fetch!(:data)
  end

  defp build_url([part, []], :global) do
    config = Elixtagram.Config.get
    string = if config.access_token, do: "access_token=#{config.access_token}", else:  "client_id=#{config.client_id}"

    "#{@base_url}#{part}?#{string}"
  end
  defp build_url([part, []], token) do
    "#{@base_url}#{part}?access_token=#{token}"
  end

  defp build_url([part, params], :global) do
    config = Elixtagram.Config.get
    auth_param = if config.access_token, do: ["access_token", config.access_token], else:  ["client_id", config.client_id]
    params_with_auth = [auth_param|params]
    "#{@base_url}#{part}?#{params_join(params_with_auth)}"
  end
  defp build_url([part, params], token) do
    params_with_auth = [["access_token", token]|params]
    "#{@base_url}#{part}?#{params_join(params_with_auth)}"
  end

  defp params_join(params) do
    params_join(params, "")
  end
  defp params_join([h | []], string) do
    [param, value] = h
    string <> "&#{param}=#{value}"
  end
  defp params_join([h | t], "") do
    [param | value] = h
    params_join(t, "#{param}=#{value}")
  end
  defp params_join([h | t], string) do
    [param | value] = h
    params_join(t, string<>"&#{param}=#{value}")
  end
end
