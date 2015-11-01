defmodule Elixtagram.OAuthStrategy do
  use OAuth2.Strategy

  @scopes ~w(comments relationships likes)

  # Public API
  def new do
    config = Elixtagram.Config.get
    OAuth2.new([
      strategy: __MODULE__,
      client_id: config.client_id,
      client_secret: config.client_secret,
      redirect_uri: config.redirect_uri,
      site: "https://api.instagram.com",
      authorize_url: "https://api.instagram.com/oauth/authorize/",
      token_url: "https://api.instagram.com/oauth/access_token"
    ])
  end

  def authorize_url!(scope, state) do
    scopes = scope
              |> Enum.map(fn s -> to_string(s) end)
              |> Enum.filter(fn s -> Enum.member?(@scopes, s) end)
              |> Enum.join(" ")
    new()
    |> put_param(:scope, scopes)
    |> put_param(:state, state)
    |> OAuth2.Client.authorize_url!([])
  end
  def authorize_url!(scope) do
    scopes = scope
              |> Enum.map(fn s -> to_string(s) end)
              |> Enum.filter(fn s -> Enum.member?(@scopes, s) end)
              |> Enum.join(" ")
    new()
    |> put_param(:scope, scopes)
    |> OAuth2.Client.authorize_url!([])
  end
  def authorize_url! do
    new()
    |> OAuth2.Client.authorize_url!([])
  end

  # you can pass options to the underlying http library via `options` parameter
  def get_token!(params \\ [], headers \\ [], options \\ []) do
    OAuth2.Client.get_token!(new(), params, headers, options)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
