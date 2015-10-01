defmodule Elixtagram.API.Users do
  @moduledoc """
  Provides access to the `/users/` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetch a `%Elixtagram.Model.User` representing a user.
  Takes a user id and an optional token. If using a token (or `:global`),
  `:self` can be passed as a user id to return the user associated with the token.
  """
  def user(user_id, token \\ :global) do
    get("/users/#{user_id}", token).data |> parse_user
  end

  @doc """
  Fetch a list of users as `%Elixtagram.Model.UserSearchResult`.
  Takes a params Map and an optional token.

  The instagram API is actually broken, it returns the wrong number of results,
  so I adjust the returned List to make it work as expected.
  """
  def search(params, token \\ :global) do
    accepted = [:count, :q]
    request_params = parse_request_params(params, accepted)

    results = get("/users/search", token, request_params).data |> Enum.map(&parse_user_search_result(&1))

    if Map.has_key?(params, :count), do: Enum.take(results, params.count), else: results
  end

  @doc """
  Fetches a list of recent media posted by a user
  """
  def recent_media(user_id, params \\ %{}, token \\ :global) do
    accepted = [:count, :min_id, :max_id, :min_timestamp, :max_timestamp]
    request_params = parse_request_params(params, accepted)
    get("/users/#{user_id}/media/recent", token, request_params).data |> Enum.map(&parse_media(&1))
  end

  @doc """
  Fetches media items from the current user's feed
  """
  def feed(params \\ %{}, token \\ :global) do
    accepted = [:count, :min_id, :max_id]
    request_params = parse_request_params(params, accepted)
    get("/users/self/feed", token, request_params).data |> Enum.map(&parse_media(&1))
  end

  @doc """
  Fetches media the user `liked`
  """
  def media_liked(params \\ %{}, token \\ :global) do
    accepted = [:count, :max_like_id]
    request_params = parse_request_params(params, accepted)
    get("/users/self/media/liked", token, request_params).data |> Enum.map(&parse_media(&1))
  end
end
