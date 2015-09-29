defmodule Elixtagram.API.Base do
  @base_url "https://api.instagram.com/v1"

  def request(:get, url_part, params \\ []) do
    [url_part, params]
      |> build_url
      |> HTTPoison.get!
      |> process_response
  end

  defp build_url([part, []]) do
    client_id = Elixtagram.Config.get(:client_id)
    "#{@base_url}#{part}?client_id=#{client_id}"
  end
  defp build_url([part, params]) do
    client_id = Elixtagram.Config.get(:client_id)
    params_with_auth = [["client_id", client_id]|params]
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

  def process_url(meat) do
    client_id = Elixtagram.Config.get(:client_id)
    "#{@base_url}#{meat}?client_id=#{client_id}"
  end

  defp process_response(data) do
    data.body
    |> Poison.decode!
    |> Dict.fetch!("data")
    |> format_response
  end

  defp format_response(records) when is_list(records) do
    Enum.map(records, fn record -> format_response(record) end)
  end

  defp format_response(record) do
    Enum.map(record, fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
