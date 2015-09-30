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


  ## ---------- Tags


  @doc """
  Takes a tag name and an optional access token, returns a `%Elixtagram.Model.Tag`.

  If a global access token was set with `Elixtagram.configure(:global, token)`, this
  will be defaulted to, otherwise the client ID is used.

  ## Example
      iex(1)> Elixtagram.tag("lifeisaboutdrugs")
      %Elixtagram.Model.Tag{media_count: 27, name: "lifeisaboutdrugs"}
  """
  defdelegate tag(name), to: Elixtagram.API.Tags, as: :tag

  @doc """
  Same as `Elixtagram.tag/1`, except takes an explicit access token.

  *The only real benefit to using an access token over a client id here
  is less rate limiting (in general and per token).*

  ## Example
      iex(1)> Elixtagram.tag("lifeisaboutdrugs", "XXXXXXXXXXXXXXXXX")
      %Elixtagram.Model.Tag{media_count: 27, name: "lifeisaboutdrugs"}
  """
  defdelegate tag(name, token), to: Elixtagram.API.Tags, as: :tag

  @doc """
  Takes a query string and returns a list of tags as `%Elixtagram.Model.Tag`.

  If a global access token was set with `Elixtagram.configure(:global, token)`, this
  will be defaulted to, otherwise the client ID is used.

  ## Example
      iex(1)> Elixtagram.tag_search("mdmazing")
      [%Elixtagram.Model.Tag{media_count: 8826.0, name: "mdmazing"},
      %Elixtagram.Model.Tag{media_count: 22.0, name: "mdmazingnight"},
      %Elixtagram.Model.Tag{media_count: 4.0, name: "mdmazingtime"},
      %Elixtagram.Model.Tag{media_count: 3.0, name: "mdmazingjourney"},
      %Elixtagram.Model.Tag{media_count: 3.0, name: "mdmazingweekend"},
      %Elixtagram.Model.Tag{media_count: 3.0, name: "mdmazinglife"},
      %Elixtagram.Model.Tag{media_count: 3.0, name: "mdmazinggggg"},
      %Elixtagram.Model.Tag{media_count: 1.0, name: "mdmazing💋💊🎉🍸"},
      %Elixtagram.Model.Tag{media_count: 1.0, name: "mdmazinglights"},
      %Elixtagram.Model.Tag{media_count: 1.0, name: "mdmazing😈👽👀"}]
  """
  defdelegate tag_search(query), to: Elixtagram.API.Tags, as: :search

  @doc """
  Takes a query string and an access token, returns a list of tags

  *The only real benefit to using an access token over a client id here
  is less rate limiting (in general and per token).*

  ## Example
      iex(1)> iex(10)> Elixtagram.tag_search("munted", "XXXXXXXXXXXXXXXXX")
      [%Elixtagram.Model.Tag{media_count: 20681.0, name: "munted"},
       %Elixtagram.Model.Tag{media_count: 267.0, name: "muntedasfuck"},
       %Elixtagram.Model.Tag{media_count: 267.0, name: "muntedheads"},
       %Elixtagram.Model.Tag{media_count: 202.0, name: "muntedas"},
       %Elixtagram.Model.Tag{media_count: 188.0, name: "muntedshakas"},
       %Elixtagram.Model.Tag{media_count: 161.0, name: "muntedmondays"},
       %Elixtagram.Model.Tag{media_count: 109.0, name: "muntedselfie"},
       %Elixtagram.Model.Tag{media_count: 94.0, name: "muntedeye"},
       %Elixtagram.Model.Tag{media_count: 93.0, name: "muntedcunts"},
       %Elixtagram.Model.Tag{media_count: 63.0, name: "muntedsmile"},
       %Elixtagram.Model.Tag{media_count: 58.0, name: "muntedaf"},
       %Elixtagram.Model.Tag{media_count: 57.0, name: "munteddd"}]
  """
  defdelegate tag_search(query, token), to: Elixtagram.API.Tags, as: :search

  @doc """
  Takes a tag name, and a Map of params
  Returns the n latest items in that tag

  Search params:
    - count
    - min_tag_id
    - max_tag_id

  If a global access token was set with `Elixtagram.configure(:global, token)`, this
  will be defaulted to, otherwise the client ID is used.

  ## Example
      iex(1)> Elixtagram.tag_recent_media("ts", %{count: 1})
      [%Elixtagram.Model.Media{...}]
  """
  defdelegate tag_recent_media(tag_name, params),
    to: Elixtagram.API.Tags, as: :recent_media

  @doc """
  Takes a tag name, a Map of params and an access token
  Returns the n latest items in that tag

  Search params:
    - count
    - min_tag_id
    - max_tag_id

  If a global access token was set with `Elixtagram.configure(:global, token)`, this
  will be defaulted to, otherwise the client ID is used.

  ## Example
      iex(1)> Elixtagram.tag_recent_media("ts", %{count: 1}, token)
      [%Elixtagram.Model.Media{...}]
  """
  defdelegate tag_recent_media(tag_name, params, token),
    to: Elixtagram.API.Tags, as: :recent_media


  ## ---------- Locations


  @doc """
  Takes a location id and returns a `%Elixtagram.Model.Location`

  ## Example
      iex(1)> Elixtagram.location(1)
      %Elixtagram.Model.Location{id: "1", latitude: 37.782492553,
      longitude: -122.387785235, name: "Dog Patch Labs"}
  """
  defdelegate location(location_id), to: Elixtagram.API.Locations, as: :location

  @doc """
  Takes a location id and an access token.
  Returns a `%Elixtagram.Model.Location`

  ## Example
      iex(1)> Elixtagram.location(1, token)
      %Elixtagram.Model.Location{id: "1", latitude: 37.782492553,
      longitude: -122.387785235, name: "Dog Patch Labs"}
  """
  defdelegate location(location_id, token), to: Elixtagram.API.Locations, as: :location

  @doc """
  Takes a location id and a Map of params.
  Returns a List of recent media (as `Elixtagram.Model.Media`)

  Search params:
    - count
    - min_timestamp
    - max_timestamp
    - min_id
    - max_id

  ## Example
      iex(1)> Elixtagram.location_recent_media(1, %{count: 1})
      [%Elixtagram.Model.Media{..}]
  """
  defdelegate location_recent_media(location_id, params), to: Elixtagram.API.Locations, as: :recent_media

  @doc """
  Takes a location id a Map of params and an access token.
  Returns a List of recent media (as `Elixtagram.Model.Media`)

  Search params:
    - count
    - min_timestamp
    - max_timestamp
    - min_id
    - max_id

  ## Example
      iex(1)> Elixtagram.location_recent_media(1, %{count: 1})
      [%Elixtagram.Model.Media{..}]
  """
  defdelegate location_recent_media(location_id, params, token), to: Elixtagram.API.Locations, as: :recent_media

  @doc """
  Takes a Map of search params.
  Returns a List of locations (as `Elixtagram.Model.Location`)

  Search params:
    - distance (in meters, defaults to 1000)
    - count
    - lat and lng (must be used together)
    - facebook_places_id
    - foursquare_v2_id
    - foursquare_id (For IDs from Foursquare's (deprecated) v1 API)

  ## Examples
      iex(1)> Elixtagram.location_search(%{lat: "52.5167", lng: "13.3833", count: 3})
      [%Elixtagram.Model.Location{id: "1014581914", latitude: 52.516667,
      longitude: 13.383333, name: "Alemanha"},
      %Elixtagram.Model.Location{id: "1003437077", latitude: 52.516667,
      longitude: 13.383333, name: "Njemačka"},
      %Elixtagram.Model.Location{id: "1014197989", latitude: 52.516667,
      longitude: 13.383333, name: "Γερμανία"}]

      iex(2)> Elixtagram.location_search(%{facebook_places_id: 1})
      [%Elixtagram.Model.Location{id: "343525978", latitude: 57.9913,
      longitude: 56.1355, name: "my home"}]

      iex(3)> Elixtagram.location_search(%{foursquare_v2_id: "4c941c0f03413704fb386fef"})
      [%Elixtagram.Model.Location{id: "14095316", latitude: 52.5110893,
      longitude: 13.4413996, name: "lab.oratory"}]
  """
  defdelegate location_search(params), to: Elixtagram.API.Locations, as: :search

  @doc """
  Takes a Map of search params and an access token.
  Returns a List of locations (as `Elixtagram.Model.Location`)

  Search params:
    - distance (in meters, defaults to 1000)
    - count
    - lat and lng (must be used together)
    - facebook_places_id
    - foursquare_v2_id
    - foursquare_id (For IDs from Foursquare's (deprecated) v1 API)

  ## Examples
      iex(1)> Elixtagram.location_search(%{lat: "52.5167", lng: "13.3833", count: 3}, token)
      [%Elixtagram.Model.Location{id: "1014581914", latitude: 52.516667,
      longitude: 13.383333, name: "Alemanha"},
      %Elixtagram.Model.Location{id: "1003437077", latitude: 52.516667,
      longitude: 13.383333, name: "Njemačka"},
      %Elixtagram.Model.Location{id: "1014197989", latitude: 52.516667,
      longitude: 13.383333, name: "Γερμανία"}]

      iex(2)> Elixtagram.location_search(%{facebook_places_id: 1}, token)
      [%Elixtagram.Model.Location{id: "343525978", latitude: 57.9913,
      longitude: 56.1355, name: "my home"}]

      iex(3)> Elixtagram.location_search(%{foursquare_v2_id: "4c941c0f03413704fb386fef"}, token)
      [%Elixtagram.Model.Location{id: "14095316", latitude: 52.5110893,
      longitude: 13.4413996, name: "lab.oratory"}]
  """
  defdelegate location_search(params, token), to: Elixtagram.API.Locations, as: :search
end
