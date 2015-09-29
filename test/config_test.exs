defmodule ConfigTest do
  use ExUnit.Case

  test "can set configuration at runtime" do
    config = %Elixtagram.Model.ClientConfig{client_id: "XXXXXXXX", client_secret: "XXXX", redirect_uri: "http://localhost:4000"}
    Elixtagram.configure(config.client_id, config.client_secret, config.redirect_uri)

    assert Elixtagram.Config.get == config
  end

  test "can get configuration from environment variables" do
    config = %Elixtagram.Model.ClientConfig{client_id: "XXXXXXXXXXXX", client_secret: "XXXXXXXXXXXX", redirect_uri: "http://localhost:4000/test"}
    System.put_env "INSTAGRAM_CLIENT_ID", config.client_id
    System.put_env "INSTAGRAM_CLIENT_SECRET", config.client_secret
    System.put_env "INSTAGRAM_REDIRECT_URI", config.redirect_uri
    Elixtagram.configure

    assert Elixtagram.Config.get == config
  end

  test "returns a basic scoped authorisation url" do
    Elixtagram.configure("XXX", "XXX", "https://localhost:4000/test")
    url = "https://api.instagram.com/oauth/authorize/?client_id=XXX&redirect_uri=https%3A%2F%2Flocalhost%3A4000%2Ftest&response_type=code"

    assert Elixtagram.authorize_url! == url
  end

  test "returns a specifically scoped authorisation url" do
    Elixtagram.configure("XXX", "XXX", "https://localhost:4000/test")
    url = "https://api.instagram.com/oauth/authorize/?client_id=XXX&redirect_uri=https%3A%2F%2Flocalhost%3A4000%2Ftest&response_type=code&scope=relationships+comments"

    assert Elixtagram.authorize_url!([:relationships, :comments]) == url
  end
end
