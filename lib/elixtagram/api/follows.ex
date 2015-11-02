defmodule Elixtagram.API.Follows do
  @moduledoc """
  Provides access to the `/users/:id/follows` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser
  @acceptable ~w(count cursor)

  @doc """
  Fetches user's follows
  """
  def follows(user_id, query, token \\ :global)
  @doc """
  Fetch the users a user follows, with pagination.
  """
  def follows(user_id, %{count: count} = data, token) do
    params = Enum.filter_map(data,
                             fn({k, v}) -> Enum.member?(@acceptable, to_string(k)) end,
                             fn({k, v}) -> [to_string(k), v] end)
    result = get("/users/#{user_id}/follows", token, params)
    %{
      results: Enum.map(result.data, &parse_user_search_result/1),
      next_cursor: result.pagination.next_cursor
    }
  end
  @doc """
  Fetch the users a user follows, without pagination.
  """
  def follows(user_id, count, token) do
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
