defmodule Elixtagram.API.Base do
  @moduledoc """
  Provides general request making and handling functionality (for internal use).
  """
  alias Elixtagram.Config

  @base_url "https://api.instagram.com/v1"

  @json_library Application.get_env(:elixtagram, :json_library)

  @doc """
  General HTTP `GET` request function. Takes a url part
  and optionally a token and list of params.
  """
  def get(url_part, token, params \\ []) do
    [url_part, params]
      |> build_url(token)
      |> HTTPoison.get!
      |> handle_response
  end

  @doc """
  General HTTP `POST` request function. Takes a url part,
  and optionally a token, data Map and list of params.
  """
  def post(url_part, token \\ :global, data \\ "", params \\ []) do
    [url_part, params]
      |> build_url(token)
      |> HTTPoison.post!(data)
      |> handle_response
  end

  @doc """
  General HTTP `DELETE` request function. Takes a url part
  and optionally a token and list of params.
  """
  def delete(url_part, token, params \\ []) do
    [url_part, params]
      |> build_url(token)
      |> HTTPoison.delete!
      |> handle_response
  end

  defp handle_response(data) do
    response = @json_library.decode!(data.body, keys: :atoms)
    case response do
      %{code: 200} ->
        response
      %{code: code} ->
        raise(Elixtagram.Error, [code: code, message: "#{response.error_type}: #{response.error_message}"])
      %{meta: %{code: 200}} ->
        response
      %{meta: %{code: code}} ->
        raise(Elixtagram.Error, [code: code, message: "#{response.meta.error_type}: #{response.meta.error_message}"])
    end
  end

  defp build_url([part, []], :global) do
    config = Config.get
    string = if config.access_token, do: "access_token=#{config.access_token}", else:  "client_id=#{config.client_id}"

    "#{@base_url}#{part}?#{string}"
  end
  defp build_url([part, []], token) do
    "#{@base_url}#{part}?access_token=#{token}"
  end

  defp build_url([part, params], :global) do
    config = Config.get
    auth_param = if config.access_token, do: ["access_token", config.access_token], else:  ["client_id", config.client_id]
    params_with_auth = [auth_param|params]
    "#{@base_url}#{part}?#{params_join(params_with_auth)}"
  end
  defp build_url([part, params], token) do
    params_with_auth = [["access_token", token]|params]
    "#{@base_url}#{part}?#{params_join(params_with_auth)}"
  end

  defp params_join(params) do
    params_join(params, "")
  end
  defp params_join([h | []], string) do
    [param, value] = h
    string <> "&#{param}=#{value}"
  end
  defp params_join([h | t], "") do
    [param | value] = h
    params_join(t, "#{param}=#{value}")
  end
  defp params_join([h | t], string) do
    [param | value] = h
    params_join(t, string<>"&#{param}=#{value}")
  end
end
