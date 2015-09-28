defmodule Elixtagram.API.Base do
  use HTTPoison.Base

  @base_url "https://api.instagram.com/v1"

  def process_url(meat) do
    client_id = Elixtagram.Config.get(:client_id)
    "#{@base_url}#{meat}?client_id=#{client_id}"
  end

  def process_response_body(body) do
    # res = Poison.decode! body, as: Elixtagram.Model.Response
    # res.data
    body
      |> Poison.decode!
      |> Dict.take(["data"])
      |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  def request(:get, url_part) do
    get!(url_part).body[:data]
      |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
