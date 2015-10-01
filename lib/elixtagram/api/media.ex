defmodule Elixtagram.API.Media do
  @moduledoc """
  Provides access to the `/media/` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetches a media item from the Instagram API by id.
  """
  def media(media_id, token \\ :global) do
    get("/media/#{media_id}", token).data |> parse_media
  end

  @doc """
  Fetches a media item from the Instagram API by shortcode.
  """
  def shortcode(shortcode, token \\ :global) do
    get("/media/shortcode/#{shortcode}", token).data |> parse_media
  end

  @doc """
  Searches media items based on some passed params.
  """
  def search(params, token \\ :global) do
    accepted_params = [:distance, :count, :min_timestamp, :max_timestamp, :lat, :lng]
    params = parse_request_params(params, accepted_params)
    get("/media/search", token, params).data |> Enum.map(&parse_media/1)
  end

  @doc """
  Fetches popular media
  """
  def popular(count, token \\ :global) do
    get("/media/popular", token, [["count", count]]).data |> Enum.map(&parse_media/1)
  end
end
