defmodule Elixtagram do
  @moduledoc """
  Provides access to the Instagram API.
  """

  @doc """
  Initialises and configures Elixtagram with a `client_id`,
  `client_secret` and `redirect_uri`. If you're not doing
  anything particularly interesting here, it's better to
  set them as environment variables and use `Elixtagram.configure/0`

  ## Example
      iex(1)> Elixtagram.configure("XXXX", "XXXX", "localhost:4000")
      {:ok, []}
  """
  defdelegate configure(client_id, client_secret, redirect_uri), to: Elixtagram.Config, as: :configure

  @doc """
  Initialises Elixtagram with system environment variables.
  For this to work, set `INSTAGRAM_CLIENT_ID`, `INSTAGRAM_CLIENT_SECRET`
  and `INSTAGRAM_REDIRECT_URI`.

  ## Example
      INSTAGRAM_CLIENT_ID=XXXX INSTAGRAM_CLIENT_SECRET=XXXX INSTAGRAM_REDIRECT_URI=localhost iex
      iex(1)> Elixtagram.configure
      {:ok, []}
  """
  defdelegate configure, to: Elixtagram.Config, as: :configure

  @doc """
  Sets a global user authentication token, this is useful for scenarios
  where your app will only ever make requests on behalf of one user at
  a time.

  ## Example
      iex(1)> Elixtagram.configure(:global, "MY-TOKEN")
      :ok
  """
  defdelegate configure(:global, token), to: Elixtagram.Config, as: :configure

  @doc """
  Returns the url you will need to redirect a user to for them to authorise your
  app with their Instagram account. When they log in there, you will need to
  implement a way to catch the code in the request url (they will be redirected back
  to your `INSTAGRAM_REDIRECT_URI`).

  **Note: This method authorises only 'basic' scoped permissions [(more on this)](https://instagram.com/developer/authentication).**

  ## Example
      iex(8)> Elixtagram.authorize_url!
      "https://api.instagram.com/oauth/authorize/?client_id=XXX&redirect_uri=localhost%3A4000&response_type=code"
  """
  defdelegate authorize_url!, to: Elixtagram.OAuthStrategy, as: :authorize_url!

  @doc """
  Returns the url to redirect a user to when authorising your app to use their
  account. Takes a list of permissions scopes as `atom` to request from Instagram.

  Available options: `:comments`, `:relationships` and `:likes`

  ## Example
      iex(1)> Elixtagram.authorize_url!([:comments, :relationships])
      "https://api.instagram.com/oauth/authorize/?client_id=XXX&redirect_uri=localhost%3A4000&response_type=code&scope=comments+relationships"
  """
  defdelegate authorize_url!(scope), to: Elixtagram.OAuthStrategy, as: :authorize_url!

  @doc """
  Takes a `keyword list` containing the code returned from Instagram in the redirect after
  login and returns a `%OAuth2.AccessToken` with an access token to store with the user or
  use for making authenticated requests.

  ## Example
      iex(1)> Elixtagram.get_token!(code: code).access_token
      "XXXXXXXXXXXXXXXXXXXX"
  """
  defdelegate get_token!(code), to: Elixtagram.OAuthStrategy, as: :get_token!

end
