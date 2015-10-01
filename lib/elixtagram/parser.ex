defmodule Elixtagram.Parser do

  def parse_tag(object) do
    struct(Elixtagram.Model.Tag, object)
  end

  def parse_media(object) do
    struct(Elixtagram.Model.Media, object)
  end

  def parse_location(object) do
    struct(Elixtagram.Model.Location, object)
  end

  def parse_user(object) do
    struct(Elixtagram.Model.User, object)
  end

  def parse_user_search_result(object) do
    struct(Elixtagram.Model.UserSearchResult, object)
  end

  def parse_comment(object) do
    struct(Elixtagram.Model.Comment, object)
  end

  def parse_relationship(object) do
    struct(Elixtagram.Model.Relationship, object)
  end

  def parse_relationship_response(object) do
    case object do
      %{outgoing_status: "none"} ->
        :ok
      %{outgoing_status: status} ->
        String.to_atom(status) 
      _ ->
        :ok
    end
  end

  @doc """
  Parse request parameters for the API.
  """
  def parse_request_params(options, accepted) do
    Enum.filter_map(options, fn({k,_}) -> Enum.member?(accepted, k) end, fn({k,v}) -> [to_string(k), to_string(v)] end)
  end
end
