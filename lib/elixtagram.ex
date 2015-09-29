defmodule Elixtagram do

  defdelegate configure(client_id, client_secret, redirect_uri), to: Elixtagram.Config, as: :configure
  defdelegate configure, to: Elixtagram.Config, as: :configure

  defdelegate configure(:global, token), to: Elixtagram.Config, as: :configure

  defdelegate authorize_url!, to: Elixtagram.OAuthStrategy, as: :authorize_url!
  defdelegate authorize_url!(scope), to: Elixtagram.OAuthStrategy, as: :authorize_url!

  defdelegate get_token!(code), to: Elixtagram.OAuthStrategy, as: :get_token!

end
