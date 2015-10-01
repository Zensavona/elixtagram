defmodule Elixtagram.API.Comments do
  @moduledoc """
  Provides access to the `/media/:id/comments` area of the Instagram API (for internal use).
  """
  import Elixtagram.API.Base
  import Elixtagram.Parser

  @doc """
  Fetches comments on a media item
  """
  def comments(media_id, token \\ :global) do
    get("/media/#{media_id}/comments", token).data |> Enum.map(&parse_comment/1)
  end

  @doc """
  Posts a comment to a media item
  """
  def comment(media_id, text, token \\ :global) do
    post("/media/#{media_id}/comments", token, String.replace(text, " ", "+"))
    :ok
  end

  @doc """
  Deletes a comment from a media item
  """
  def comment_delete(media_id, comment_id, token \\ :global) do
    delete("/media/#{media_id}/comments/#{comment_id}", token)
    :ok
  end
end
