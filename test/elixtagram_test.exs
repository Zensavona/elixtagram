defmodule ElixtagramTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.filter_sensitive_data("oauth_signature=[^\"]+", "<REMOVED>")
    ExVCR.Config.filter_sensitive_data("client_id=.+;", "<REMOVED>")
    ExVCR.Config.filter_sensitive_data("access_token\":\".+?\"", "access_token\":\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("code\":\".+?\"", "access_token\":\"<REMOVED>\"")

    Dotenv.reload!
    Elixtagram.configure

    :ok
  end

  test "gets current configuration" do
    config = Elixtagram.Config.get
    assert config.client_id != nil
    assert config.client_secret != nil
    assert config.redirect_uri != nil
  end

  test "gets an access token, and test it's validity" do
    tag_name = "ruaware"
    code = "XXXXXXXXXXXXXXXXXXXX"
    use_cassette "access_token" do
      token = Elixtagram.get_token!(code: code).access_token
      tag = Elixtagram.tag(tag_name, token)
      assert tag.name == tag_name
    end
  end

  test "get a hashtag (unauthenticated)" do
    tag_name = "lifeisaboutdrugs"
    use_cassette "tag" do
      tag = Elixtagram.tag(tag_name)
      assert tag.name == tag_name
      assert tag.media_count > 0
    end
  end

  test "get a hashtag (explicitly authenticated)" do
    tag_name = "lifeisaboutdrugs"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "tag_auth_explicit" do
      tag = Elixtagram.tag(tag_name, token)
      assert tag.name == tag_name
      assert tag.media_count > 0
    end
  end

  test "get a hashtag (implicitly authenticated)" do
    tag_name = "lifeisaboutdrugs"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "tag_auth_implicit" do
      tag = Elixtagram.tag(tag_name)
      assert tag.name == tag_name
      assert tag.media_count > 0
    end
  end

  test "search for some hashtags (unauthenticated)" do
    query = "fit"
    use_cassette "tag_search" do
      tags = Elixtagram.tag_search(query)
      [tag | _] = tags
      assert length(tags) > 0
      assert tag.name == query
    end
  end

  test "search for some hashtags (explicitly authenticated)" do
    query = "fit"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "tag_search_auth_explicit" do
      tags = Elixtagram.tag_search(query, token)
      [tag | _] = tags
      assert length(tags) > 0
      assert tag.name == query
    end
  end

  test "search for some hashtags (implicitly authenticated)" do
    query = "fit"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "tag_search_auth_implicit" do
      tags = Elixtagram.tag_search(query)
      [tag | _] = tags
      assert length(tags) > 0
      assert tag.name == query
    end
  end
end
