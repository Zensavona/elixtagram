defmodule Elixtagram.API.Base do
  use HTTPoison.Base

  @base_url "https://api.instagram.com/v1"

  def process_url(meat) do
    client_id = Elixtagram.Config.get(:client_id)
    "#{@base_url}#{meat}?client_id=#{client_id}"
  end

  def get(url_part) do
    data = get!(url_part).body
  end

  def extract_data(struct) do
    struct["data"]
  end
end
