defmodule Elixtagram.API.Likes do
  @moduledoc """
  Provides access to the `/users/` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetches the users who like a particular media item.
  """
  def likes(media_id, token \\ :global) do
    get("/media/#{media_id}/likes", token).data |> Enum.map(&parse_user_search_result/1)
  end

  @doc """
  Like a media item
  """
  def like(media_id, token \\ :global) do
    post("/media/#{media_id}/likes", token)
    :ok
  end

  @doc """
  Unlike a media item
  """
  def unlike(media_id, token \\ :global) do
    delete("/media/#{media_id}/likes", token)
    :ok
  end
end
