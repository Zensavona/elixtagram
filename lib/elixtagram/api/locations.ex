defmodule Elixtagram.API.Locations do
  @moduledoc """
  Provides access to the `/locations/` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetch a `%Elixtagram.Model.Location` from the server by `id`.
  Optionally take an access token.
  """
  def location(location_id, token \\ :global) do
    request(:get, "/locations/#{location_id}", token).data |> parse_location
  end

  @doc """
  Fetch recent media from a location (by id)
  pass a list of params to limit your query by any combination of:
    - count
    - min_timestamp
    - max_timestamp
    - min_id
    - max_id
  """
  def recent_media(location_id, params \\ %{}, token \\ :global) do
    accepted = [:count, :min_timestamp, :max_timestamp, :min_id, :max_id]
    request_params = parse_request_params(params, accepted)
    request(:get, "/locations/#{location_id}/media/recent", token, request_params).data |> Enum.map(&parse_media/1)
  end

  @doc """
  Search for locations which match some parameters, passed as a list:
    - distance (meters, default is 1000)
    - lat
    - lng
    - facebook_places_id
    - foursquare_v2_id
    - foursquare_id (for Foursquare V1 API, deprecated)
  Must pass either some kind of id, or a lat/lng pair.
  """
  def search(params, token \\ :global) do
    universally_accepted = [:distance, :count]
    accepted = case params do
      %{facebook_places_id: _} ->
        [:facebook_places_id] ++ universally_accepted
      %{foursquare_v2_id: _} ->
        [:foursquare_v2_id] ++ universally_accepted
      %{foursquare_id: _} ->
        [:foursquare_id] ++ universally_accepted
      %{lat: _, lng: _} ->
        [:lat, :lng] ++ universally_accepted
    end
    params = parse_request_params(params, accepted)
    request(:get, "/locations/search", token, params).data |> Enum.map(&parse_location/1)
  end
end
