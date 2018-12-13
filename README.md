# Elixtagram

### Elixtagram is a simple Instagram client for Elixir.

[![Build Status](https://travis-ci.org/Zensavona/elixtagram.svg?branch=master)](https://travis-ci.org/Zensavona/elixtagram) [![Inline docs](http://inch-ci.org/github/zensavona/elixtagram.svg)](http://inch-ci.org/github/zensavona/elixtagram) [![Coverage Status](https://coveralls.io/repos/Zensavona/elixtagram/badge.svg?branch=master&service=github)](https://coveralls.io/github/Zensavona/elixtagram?branch=master) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/Zensavona/elixtagram.svg)](https://beta.hexfaktor.org/github/Zensavona/elixtagram) [![hex.pm version](https://img.shields.io/hexpm/v/elixtagram.svg)](https://hex.pm/packages/elixtagram) [![hex.pm downloads](https://img.shields.io/hexpm/dt/elixtagram.svg)](https://hex.pm/packages/elixtagram) [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

### [Read the docs](https://hexdocs.pm/elixtagram)

I've created an example application with Phoenix [here](https://github.com/Zensavona/instagram-phoenix-example)

## Usage

### Installation

Add the following to your `mix.exs`

````
...

def application do
  [mod: {InstagramPhoenixExample, []},
   applications: [:elixtagram]]
end

...

defp deps do
  [{:elixtagram, "~> 0.7.0"}]

...

````

### Configuration

Elixtagram will first look for application variables, then environment variables. This is useful if you want to set application variables locally and environment variables in production (e.g. on Heroku). That being said, I recommend using [Dotenv](https://github.com/avdi/dotenv_elixir) locally.

`config/dev.exs`
````
config :elixtagram,
  instagram_client_id: "YOUR-CLIENT-ID",
  instagram_client_secret: "YOUR-CLIENT-SECRET",
  instagram_redirect_uri: "YOUR-REDIRECT-URI"
````

`.env`
````
INSTAGRAM_CLIENT_ID=YOUR-CLIENT-ID
INSTAGRAM_CLIENT_SECRET=YOUR-CLIENT-SECRET
INSTAGRAM_REDIRECT_URI=YOUR-REDIRECT-URI
````

You can also configure these programatically at runtime if you wish:
````
iex(1)> Elixtagram.configure("YOUR-CLIENT-ID", "YOUR-CLIENT-SECRET", "YOUR-REDIRECT-URI")
{:ok, []}
````

### Usage

*Before using Elixtagram, it needs to be initialised. Run `Elixtagram.configure/0` or `Elixtagram.configure/1` before any other commands*

#### Authenticate a user

````
# Generate a URL to send them to
iex(1)> Elixtagram.authorize_url!
"https://api.instagram.com/oauth/authorize/?client_id=XXX&redirect_uri=localhost%3A4000&response_type=code"

# Instagram will redirect them back to your INSTAGRAM_REDIRECT_URI, so once they're there, you need to catch the url param 'code', and exchange it for an access token.

iex(2)> code = "XXXXXXXXXX"
"XXXXXXXXXX"
iex(3)> {:ok, access_token} = Elixtagram.get_token!(code: code)
{:ok, "XXXXXXXXXXXXXXXXXXXX"}

# Now we can optionally set this as the global token, and make requests with it by passing :global instead of a token.
iex(4)> Elixtagram.configure(:global, access_token)
:ok
````

#### Unauthenticated endpoints

There are a lot of endpoints you can use without an access token from a user. Most methods can be called in one of three ways, for example:
````
# Unauthenticated
iex(1)> Elixtagram.tag("lifeisaboutdrugs")
%Elixtagram.Model.Tag{media_count: 27, name: "lifeisaboutdrugs"}

# Explicitly authenticated
iex(1)> Elixtagram.tag("lifeisaboutdrugs", "XXXXXXXXXXXXXXXXX")
%Elixtagram.Model.Tag{media_count: 27, name: "lifeisaboutdrugs"}

# Implicitly authenticated (only works if you have configured a global token)
iex(1)> Elixtagram.tag("lifeisaboutdrugs", :global)
%Elixtagram.Model.Tag{media_count: 27, name: "lifeisaboutdrugs"}
````

#### Authenticated endpoints

Authenticated endpoints are mostly things which are about getting the current user's stuff
````
iex(1)> Elixtagram.user_feed(%{count: 2}, "XXXXXXXXXXXXXXXXX")
[%Elixtagram.Model.Media{...}, %Elixtagram.Model.Media{...}]

iex(2)> Elixtagram.user_feed(%{count: 2}, :global)
[%Elixtagram.Model.Media{...}, %Elixtagram.Model.Media{...}]
````

All of the available methods and the ways to call them are [in the docs](https://hexdocs.pm/elixtagram/Elixtagram.html)

## Running the tests

TL;DR: `mix test`

Longer answer:
```
$ mix deps.get
Running dependency resolution
All dependencies up to date

$ mix test
...........................................................................................

Finished in 17.6 seconds (2.9s on load, 14.7s on tests)
91 tests, 0 failures

Randomized with seed 846369

$ mix coveralls
...........................................................................................

Finished in 13.1 seconds (1.9s on load, 11.2s on tests)
91 tests, 0 failures

Randomized with seed 972312
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/elixtagram.ex                             806       49        0
100.0% lib/elixtagram/api/base.ex                     84       24        0
100.0% lib/elixtagram/api/comments.ex                 30        3        0
100.0% lib/elixtagram/api/follows.ex                  37        5        0
100.0% lib/elixtagram/api/likes.ex                    30        3        0
100.0% lib/elixtagram/api/locations.ex                56       12        0
100.0% lib/elixtagram/api/media.ex                    37        6        0
100.0% lib/elixtagram/api/tags.ex                     33        5        0
100.0% lib/elixtagram/api/users.ex                    59       14        0
100.0% lib/elixtagram/config.ex                       42       10        0
  0.0% lib/elixtagram/exception.ex                     3        0        0
  0.0% lib/elixtagram/model.ex                        38        0        0
100.0% lib/elixtagram/oauth_strategy.ex               50       13        0
100.0% lib/elixtagram/parser.ex                       48       10        0
[TOTAL] 100.0%
----------------
```

## Status

It's mostly complete, but these things are missing:

* Pagination of results for certain data types
* Real time subscriptions
* Secure requests


## Changelog

### 0.7.0
- Merge PR which adds `ELixtagram.recent_media_with_pagination/3` (PR #23, thanks @PuckOut!)
- Update dependencies

### 0.6.0
- Merge PR which updates the new API url for `Elixtagram.user_feed/2` (PR #17, thanks @sudostack!)
- Merge PR which adds support for the new `carousel_media` type (PR #19, thanks @mendab1e!)

### 0.5.1
- Merge PR which better handles cases where API request limiting kicks in (PR #18, thanks @mendab1e!)

### 0.5.0
- Merge PR #16 which implements a paginated version of `Elixtagram.tag_recent_media`: `Elixtagram.tag_recent_media_with_pagination` (thanks @mendab1e!)

### 0.4.0
- Merge PR #15 from @mendab1e which adds the `videos` field to `Media` (Thanks!)
- Update the `oauth2` library to version `0.9.1` which closes Issue #14 from @radzserg (Thanks, sorry it took me so long to get to this!)
- Update `httpoison` to `0.11.1`
- Update `poison` to `3.1.0`

### 0.3.0
- Change the `Elixtagram.get_token!` function to return a tuple like `{:ok, token}`
- Update dependencies
- Merge a [pull request](https://github.com/Zensavona/elixtagram/pull/13) which fixes an issue relating to a newer version of OAuth2 (thanks [@radzserg](https://github.com/radzserg))

### 0.2.9
- Add `user_recent_media_with_pagination` (thanks again [@deadkarma](https://github.com/deadkarma)!)

### 0.2.8
- Support [Elixir 1.3.x](https://github.com/Zensavona/elixtagram/pull/9) (thanks [@deadkarma](https://github.com/deadkarma)!)

### 0.2.7
- Add the `type` attribute to Media in order to tell the difference between 'image' and 'video' types (thanks [@deadkarma](https://github.com/deadkarma)!)

### 0.2.6
- Add the new `created_time` and `users_in_photo` to `Media` (thanks [@deadkarma](https://github.com/deadkarma)!)
- Add new required OAuth permissions request (thanks [@bobishh](https://github.com/bobishh)!)

### 0.2.5
- Add [credo](https://github.com/rrrene/credo) in `dev` environment
- Improve code readability and resolve credo warnings (thanks [@rrrene](https://github.com/rrrene)!)

### 0.2.4
- Update the OAuth2 library to `0.5` (thanks [@steffenix!](https://github.com/steffenix)!)
- add a couple more test cases around pagination to get back to 100% coverage

### 0.2.3
- Minor pagination bugfix - was throwing a `KeyError` when requesting a paginated `user_follows` and on the last page of results.

### 0.2.2
- Add pagination support for `user_follows`, this doesn't break the existing `user_follows/2` and `user_follows/3` API.

### 0.2.1

- Add `Elixtagram.authorize_url!/3`, which takes a `state` argument to pass back to the callback url. This is useful for things like CSRF protection ([read more here](https://instagram.com/developer/authentication/)). This change doesn't break or change the existing API.

### 0.2.0

- Change the api of `Elixtagram.user_follows/1` & `Elixtagram.user_follows/2` (now respectively `Elixtagram.user_follows/2` & `Elixtagram.user_follows/3`) to accept a `count` argument.
