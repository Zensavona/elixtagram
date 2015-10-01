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

  test "raise an exception when a bad access token is used" do
    use_cassette "oauth_exception" do
      assert_raise Elixtagram.Error, fn ->
        Elixtagram.tag("exceptional", "lol")
      end
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
      tag = Elixtagram.tag(tag_name, :global)
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
      tags = Elixtagram.tag_search(query, :global)
      [tag | _] = tags
      assert length(tags) > 0
      assert tag.name == query
    end
  end

  test "get recent media from a tag (unauthenticated)" do
    tag = "ts"
    use_cassette "tag_recent_media" do
      medias = Elixtagram.tag_recent_media(tag, %{count: 10})
      media = List.first(medias)
      assert length(medias) > 0
      assert Enum.member?(media.tags, "ts")
    end
  end

  test "get recent media from a tag (implicitly authenticated)" do
    tag = "ts"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "tag_recent_media_auth_implicit" do
      medias = Elixtagram.tag_recent_media(tag, %{count: 10}, :global)
      media = List.first(medias)
      assert length(medias) > 0
      assert Enum.member?(media.tags, "ts")
    end
  end

  test "get recent media from a tag (explicitly authenticated)" do
    tag = "ts"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "tag_recent_media_auth_explicit" do
      medias = Elixtagram.tag_recent_media(tag, %{count: 10}, token)
      media = List.first(medias)
      assert length(medias) > 0
      assert Enum.member?(media.tags, "ts")
    end
  end

  test "get a location by id (unauthenticated)" do
    id = 1

    use_cassette "location" do
      location = Elixtagram.location(id)
      assert location.id == to_string(id)
    end
  end

  test "get a location by id (implicitly authenticated)" do
    id = 1
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "location_auth_implicit" do
      location = Elixtagram.location(id, :global)
      assert location.id == to_string(id)
    end
  end

  test "get a location by id (explicitly authenticated)" do
    id = 1
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "location_auth_explicit" do
      location = Elixtagram.location(id, token)
      assert location.id == to_string(id)
    end
  end

  test "get recent media at a location (unauthenticated)" do
    use_cassette "location_recent_media" do
      recent_media = Elixtagram.location_recent_media(1, %{count: 1})
      assert length(recent_media) == 1
    end
  end

  test "get recent media at a location (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)
    use_cassette "location_recent_media_auth_implicit" do
      recent_media = Elixtagram.location_recent_media(1, %{count: 1}, :global)
      assert length(recent_media) == 1
    end
  end

  test "get recent media at a location (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    use_cassette "location_recent_media_auth_explicit" do
      recent_media = Elixtagram.location_recent_media(1, %{count: 1}, token)
      assert length(recent_media) == 1
    end
  end

  test "find locations by latitude/longitude (unauthenticated)" do
    use_cassette "location_lat_lng" do
      locations = Elixtagram.location_search(%{lat: 1, lng: 2, count: 1})
      assert length(locations) == 1
      assert List.first(locations).latitude == 1.0
      assert List.first(locations).longitude == 2.0
    end
  end

  test "find locations by Facebook Places ID (unauthenticated)" do
    use_cassette "location_facebook_places" do
      locations = Elixtagram.location_search(%{facebook_places_id: 1})
      assert length(locations) == 1
      assert List.first(locations).name == "my home"
    end
  end

  test "find locations by Foursquare ID (v2) (unauthenticated)" do
    use_cassette "location_foursquare_v2" do
      locations = Elixtagram.location_search(%{foursquare_v2_id: "430d0a00f964a5203e271fe3"})
      assert length(locations) == 1
    end
  end

  # Foursquare v1 API is deprecated and this endpoint will probably be killed
  # off in the future, so if this test starts failing, that might be it.
  test "find locations by Foursquare ID (v1) (unauthenticated)" do
    use_cassette "location_foursquare_v1" do
      locations = Elixtagram.location_search(%{foursquare_id: 79273})
      assert length(locations) == 1
    end
  end

  test "find 30 locations near Berlin by latitude/longitude (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)
    use_cassette "location_lat_lng_auth_implicit" do
      locations = Elixtagram.location_search(%{lat: "52.5167", lng: "13.3833", count: 30}, :global)
      my_fave_spot = List.first(for l=%{name: "برلين"} <- locations, do: l)
      assert length(locations) == 30
      assert my_fave_spot.name == "برلين"
    end
  end

  test "find Lab.Oratory with Foursquare v2 ID (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    use_cassette "location_foursquare_v2_auth_explicit" do
      # From the Foursquare page: "Best Gay Sex club ever!!!"
      #                           "Always you can find something big for yourself"
      my_other_fave = Elixtagram.location_search(%{foursquare_v2_id: "4c941c0f03413704fb386fef"}, token)
      assert List.first(my_other_fave).name == "lab.oratory"
    end
  end

  test "get a media item by id (unauthenticated)" do
    id = "1085620159293161830_430882815"
    use_cassette "media" do
      media = Elixtagram.media(id)
      assert media.id == id
    end
  end

  test "get a media item by id (implicitly authenticated)" do
    id = "1085620159293161830_430882815"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "media_auth_implicit" do
      media = Elixtagram.media(id, :global)
      assert media.id == id
    end
  end

  test "get a media item by id (explicitly authenticated)" do
    id = "1085620159293161830_430882815"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    use_cassette "media_auth_explicit" do
      media = Elixtagram.media(id, token)
      assert media.id == id
    end
  end

  test "get a media item by shortcode (unauthenticated)" do
    shortcode = "D"
    use_cassette "media_shortcode" do
      media = Elixtagram.media_shortcode(shortcode)
      assert media.user.username == "kevin"
    end
  end

  test "get a media item by shortcode (implicitly authenticated)" do
    shortcode = "D"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "media_shortcode_auth_implicit" do
      media = Elixtagram.media_shortcode(shortcode, :global)
      assert media.user.username == "kevin"
    end
  end

  test "get a media item by shortcode (explicitly authenticated)" do
    shortcode = "D"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    use_cassette "media_shortcode_auth_explicit" do
      media = Elixtagram.media_shortcode(shortcode, token)
      assert media.user.username == "kevin"
    end
  end

  test "search for media by location (unauthenticated)" do
    use_cassette "media_search" do
      medias = Elixtagram.media_search(%{lat: 1, lng: 2, count: 10})
      assert length(medias) == 10
    end
  end

  test "search for media by location (implicit authentication)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "media_search_auth_implicit" do
      medias = Elixtagram.media_search(%{lat: 1, lng: 2, count: 10}, :global)
      assert length(medias) == 10
    end
  end

  test "search for media by location (explicit authentication)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "media_search_auth_explicit" do
      medias = Elixtagram.media_search(%{lat: 1, lng: 2, count: 10}, token)
      assert length(medias) == 10
    end
  end

  test "get popular media items (unauthenticated)" do
    use_cassette "media_popular" do
      popular = Elixtagram.media_popular(50)
      assert length(popular) == 50
    end
  end

  test "get popular media items (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "media_popular_auth_implicit" do
      popular = Elixtagram.media_popular(50, :global)
      assert length(popular) == 50
    end
  end

  test "get popular media items (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "media_popular_auth_explicit" do
      popular = Elixtagram.media_popular(50, token)
      assert length(popular) == 50
    end
  end
end
