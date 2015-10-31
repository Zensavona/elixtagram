defmodule Elixtagram.API.Follows do
  @moduledoc """
  Provides access to the `/users/:id/follows` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetch the users a user follows
  """
  def follows(user_id, count, token \\ :global) do
    get("/users/#{user_id}/follows", token, [["count", count]]).data |> Enum.map(&parse_user_search_result/1)
  end

  @doc """
  Fetch the user's followers
  """
  def followed_by(user_id, token \\ :global) do
    get("/users/#{user_id}/followed-by", token).data |> Enum.map(&parse_user_search_result/1)
  end

  @doc """
  Fetch the users who have requested to follow the user associated with the token passed
  """
  def requested_by(token \\ :global) do
    get("/users/self/requested-by", token).data |> Enum.map(&parse_user_search_result/1)
  end

  def relationship(user_id, token) do
    get("/users/#{user_id}/relationship", token).data |> parse_relationship
  end

  def relationship(user_id, action, token) do
    post("/users/#{user_id}/relationship", token, "action=#{action}").data |> parse_relationship_response
  end

end
