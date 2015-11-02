defmodule ElixtagramTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.filter_sensitive_data("oauth_signature=[^\"]+", "<REMOVED>")
    ExVCR.Config.filter_sensitive_data("client_id=.+;", "<REMOVED>")
    ExVCR.Config.filter_sensitive_data("access_token\":\".+?\"", "access_token\":\"<REMOVED>\"")
    ExVCR.Config.filter_sensitive_data("code\":\".+?\"", "access_token\":\"<REMOVED>\"")

    System.put_env "INSTAGRAM_CLIENT_ID", "XXXXXXXXXXXXXXXXXXXX"
    System.put_env "INSTAGRAM_CLIENT_SECRET", "XXXXXXXXXXXXXXXXXXXX"
    System.put_env "INSTAGRAM_ACCESS_TOKEN", "XXXXXXXXXXXXXXXXXXXX"
    System.put_env "INSTAGRAM_REDIRECT_URI", "https://github.com/zensavona/elixtagram"

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

  test "get a user by id (unauthenticated)" do
    user_id = 35822824
    use_cassette "user" do
      user = Elixtagram.user(user_id)
      assert user.id == to_string(user_id)
    end
  end

  test "get a user by id (implicitly authenticated)" do
    user_id = 35822824
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_auth_implicit" do
      user = Elixtagram.user(user_id, :global)
      assert user.id == to_string(user_id)
    end
  end

  test "get a user by id (explicitly authenticated)" do
    user_id = 35822824
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_auth_explicit" do
      user = Elixtagram.user(user_id, token)
      assert user.id == to_string(user_id)
    end
  end

  test "get a user by :self (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_self_auth_implicit" do
      user = Elixtagram.user(:self, :global)
      assert user.id != nil
    end
  end

  test "get a user by :self (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_self_auth_explicit" do
      user = Elixtagram.user(:self, token)
      assert user.id != nil
    end
  end

  test "search for users by name (unauthenticated)" do
    q = "zen"
    use_cassette "user_search" do
      users = Elixtagram.user_search(%{q: q, count: 3})
      assert length(users) == 3
    end
  end

  test "search for users by name (implicitly authenticated)" do
    q = "zen"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_search_auth_implicit" do
      users = Elixtagram.user_search(%{q: q, count: 3}, :global)
      assert length(users) == 3
    end
  end

  test "search for users by name (explicitly authenticated)" do
    q = "zen"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_search_auth_explicit" do
      users = Elixtagram.user_search(%{q: q, count: 3}, token)
      assert length(users) == 3
    end
  end

  test "get recent media for user (unauthenticated)" do
    id = 35822824
    use_cassette "user_recent_media" do
      medias = Elixtagram.user_recent_media(id, %{count: 3})
      assert length(medias) == 3
    end
  end

  test "get recent media for user (implicitly authenticated)" do
    id = 35822824
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_recent_media_auth_implicit" do
      medias = Elixtagram.user_recent_media(id, %{count: 3}, :global)
      assert length(medias) == 3
    end
  end

  test "get recent media for user (explicitly authenticated)" do
    id = 35822824
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_recent_media_auth_explicit" do
      medias = Elixtagram.user_recent_media(id, %{count: 3}, token)
      assert length(medias) == 3
    end
  end

  test "get recent media for user with :self (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_recent_media_self_auth_implicit" do
      medias = Elixtagram.user_recent_media(:self, %{count: 3}, :global)
      assert length(medias) == 3
    end
  end

  test "get recent media for user with :self (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_recent_media_self_auth_explicit" do
      medias = Elixtagram.user_recent_media(:self, %{count: 3}, token)
      assert length(medias) == 3
    end
  end

  test "get feed for user (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_feed_auth_implicit" do
      medias = Elixtagram.user_feed(%{count: 3}, :global)
      assert length(medias) == 3
    end
  end

  test "get feed for user (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_feed_auth_explicit" do
      medias = Elixtagram.user_feed(%{count: 3}, token)
      assert length(medias) == 3
    end
  end

  test "get liked media for user (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_media_liked_auth_implicit" do
      medias = Elixtagram.user_media_liked(%{count: 3}, :global)
      assert length(medias) == 3
    end
  end

  test "get liked media for user (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_media_liked_auth_explicit" do
      medias = Elixtagram.user_media_liked(%{count: 3}, token)
      assert length(medias) == 3
    end
  end

  test "get likes on a media item (unauthenticated)" do
    use_cassette "media_likes" do
      likes = Elixtagram.media_likes("1075894327634310197_2183820012")
      assert length(likes) > 0
    end
  end

  test "get likes on a media item (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "media_likes_auth_implicit" do
      likes = Elixtagram.media_likes("1075894327634310197_2183820012", :global)
      assert length(likes) > 0
    end
  end

  test "get likes on a media item (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "media_likes_auth_explicit" do
      likes = Elixtagram.media_likes("1075894327634310197_2183820012", token)
      assert length(likes) > 0
    end
  end

  # these tests are kind of bullshit because I don't have access to special
  # scopes on Instagram's API and thus can't capture real responses, I'm
  # working on the assumption their API docs are accurate.

  test "like media as user (implicitly authenticated)" do
    Elixtagram.configure(:global, "XXXXXXXXXX")
    use_cassette "like_media", custom: true do
      like = Elixtagram.media_like("1234567890", :global)
      assert like == :ok
    end
  end

  test "like media as user (explicitly authenticated)" do
    use_cassette "like_media", custom: true do
      like = Elixtagram.media_like("1234567890", "XXXXXXXXXX")
      assert like == :ok
    end
  end

  test "like media as user (scope failure)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "like_media_scope_exception" do
      assert_raise Elixtagram.Error, fn ->
        Elixtagram.media_like("1075894327634310197_2183820012", token)
      end
    end
  end

  test "unlike media as user (implicitly authenticated)" do
    Elixtagram.configure(:global, "XXXXXXXXXX")
    use_cassette "unlike_media", custom: true do
      like = Elixtagram.media_unlike("1234567890", :global)
      assert like == :ok
    end
  end

  test "unlike media as user (explicitly authenticated)" do
    use_cassette "unlike_media", custom: true do
      like = Elixtagram.media_unlike("1234567890", "XXXXXXXXXX")
      assert like == :ok
    end
  end

  test "unlike media as user (scope failure)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "unlike_media_scope_exception" do
      assert_raise Elixtagram.Error, fn ->
        Elixtagram.media_unlike("1075894327634310197_2183820012", token)
      end
    end
  end

  test "get comments on a media item (unauthenticated)" do
    id = "1072892704941941781_35822824"
    use_cassette "comments" do
      comments = Elixtagram.media_comments(id)
      assert length(comments) > 0
    end
  end

  test "get comments on a media item (implicitly authenticated)" do
    id = "1072892704941941781_35822824"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "comments_auth_implicit" do
      comments = Elixtagram.media_comments(id, :global)
      assert length(comments) > 0
    end
  end

  test "get comments on a media item (explicitly authenticated)" do
    id = "1072892704941941781_35822824"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "comments_auth_explicit" do
      comments = Elixtagram.media_comments(id, token)
      assert length(comments) > 0
    end
  end

  test "post comment to media item (explicitly authenticated)" do
    id = "XXXXXXXXXXX"
    comment = "Nice pic m8"

    use_cassette "comment", custom: true do
      result = Elixtagram.media_comment(id, comment, "XXXXXXXXXXX")
      assert result == :ok
    end
  end

  test "post comment to media item (implicitly authenticated)" do
    id = "XXXXXXXXXXX"
    comment = "Nice pic m8"
    Elixtagram.configure(:global, "XXXXXXXXXXX")

    use_cassette "comment", custom: true do
      result = Elixtagram.media_comment(id, comment, :global)
      assert result == :ok
    end
  end

  test "post comment to media item (scope failure)" do
    id = "1072892704941941781_35822824"
    comment = "Nice pic m8"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "comment_scope_exception" do
      assert_raise Elixtagram.Error, fn ->
        Elixtagram.media_comment(id, comment, token)
      end
    end
  end

  test "delete comment from media item (explicitly authenticated)" do
    media_id = "XXXXXXXXXXX"
    comment_id = "XXXXXXXXXXX"

    use_cassette "comment_delete", custom: true do
      result = Elixtagram.media_comment_delete(media_id, comment_id, "XXXXXXXXXX")
      assert result == :ok
    end
  end

  test "delete comment from media item (implicitly authenticated)" do
    media_id = "XXXXXXXXXXX"
    comment_id = "XXXXXXXXXXX"
    Elixtagram.configure(:global, "XXXXXXXXXX")

    use_cassette "comment_delete", custom: true do
      result = Elixtagram.media_comment_delete(media_id, comment_id, :global)
      assert result == :ok
    end
  end

  test "delete comment from media item (scope failure)" do
    media_id = "1072892704941941781_35822824"
    comment_id = "1072905761030153596"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "comment_delete_scope_exception" do
      assert_raise Elixtagram.Error, fn ->
        Elixtagram.media_comment_delete(media_id, comment_id, token)
      end
    end
  end

  test "get users the user follows (unauthenticated)" do
    user_id = "35822824"
    use_cassette "user_following" do
      follows = Elixtagram.user_follows(user_id, 10)
      assert length(follows) == 10
    end
  end

  test "get users the user follows (implicitly authenticated)" do
    user_id = "35822824"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_following_auth_implicit" do
      follows = Elixtagram.user_follows(user_id, 50, :global)
      assert length(follows) == 50
    end
  end

  test "get users the user follows (explicitly authenticated)" do
    user_id = "35822824"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_following_auth_explicit" do
      follows = Elixtagram.user_follows(user_id, 6, token)
      assert length(follows) > 0
    end
  end

  test "get users the user follows (unauthenticated, paginated)" do
    user_id = "35822824"
    use_cassette "user_following_paginated" do
      follows = Elixtagram.user_follows(user_id, %{count: 10})
      assert length(follows.results) == 10
      assert Map.has_key?(follows, :next_cursor)
    end
  end

  test "get user's followers (unauthenticated)" do
    user_id = "35822824"
    use_cassette "user_followers" do
      followers = Elixtagram.user_followed_by(user_id)
      assert length(followers) > 0
    end
  end

  test "get user's followers (implicitly authenticated)" do
    user_id = "35822824"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_followers_auth_implicit" do
      followers = Elixtagram.user_followed_by(user_id, :global)
      assert length(followers) > 0
    end
  end

  test "get user's followers (explicitly authenticated)" do
    user_id = "35822824"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_followers_auth_explicit" do
      followers = Elixtagram.user_followed_by(user_id, token)
      assert length(followers) > 0
    end
  end

  test "get user's requested followers (implicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_requested_by_auth_implicit" do
      requested_by = Elixtagram.user_requested_by(:global)
      assert requested_by == []
    end
  end

  test "get user's requested followers (explicitly authenticated)" do
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")

    use_cassette "user_requested_by_auth_explicit" do
      requested_by = Elixtagram.user_requested_by(token)
      assert requested_by == []
    end
  end

  test "get user's relationship with another user (implicitly authenticated)" do
    user_id = "798275610"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_relationship_auth_implicit" do
      relationship = Elixtagram.user_relationship(user_id, :global)

      assert relationship.incoming_status == "followed_by"
      assert relationship.outgoing_status == "follows"
      assert relationship.target_user_is_private == false
    end
  end

  test "get user's relationship with another user (explicitly authenticated)" do
    user_id = "798275610"
    token = System.get_env("INSTAGRAM_ACCESS_TOKEN")
    Elixtagram.configure(:global, token)

    use_cassette "user_relationship_auth_explicit" do
      relationship = Elixtagram.user_relationship(user_id, token)

      assert relationship.incoming_status == "followed_by"
      assert relationship.outgoing_status == "follows"
      assert relationship.target_user_is_private == false
    end
  end

  # These are just contrived, as I don't have an authorised Instagram account
  # to capture real responses from.

  test "follow a user" do
    token = "XXXXXXXXXX"
    user_id = "XXXXXXXXXX"

    use_cassette "user_follow", custom: true do
      response = Elixtagram.user_relationship(user_id, :follow, token)
      assert response == :requested
    end
  end

  test "unfollow a user" do
    token = "XXXXXXXXXX"
    user_id = "XXXXXXXXXX"

    use_cassette "user_unfollow", custom: true do
      response = Elixtagram.user_relationship(user_id, :unfollow, token)
      assert response == :ok
    end
  end

  test "block a user" do
    token = "XXXXXXXXXX"
    user_id = "XXXXXXXXXX"

    use_cassette "user_block", custom: true do
      response = Elixtagram.user_relationship(user_id, :block, token)
      assert response == :ok
    end
  end

  test "unblock a user" do
    token = "XXXXXXXXXX"
    user_id = "XXXXXXXXXX"

    use_cassette "user_unblock", custom: true do
      response = Elixtagram.user_relationship(user_id, :unblock, token)
      assert response == :ok
    end
  end

  test "approve a follower" do
    token = "XXXXXXXXXX"
    user_id = "XXXXXXXXXX"

    use_cassette "user_approve", custom: true do
      response = Elixtagram.user_relationship(user_id, :approve, token)
      assert response == :follows
    end
  end

  test "ignore a follow request" do
    token = "XXXXXXXXXX"
    user_id = "XXXXXXXXXX"

    use_cassette "user_ignore", custom: true do
      response = Elixtagram.user_relationship(user_id, :ignore, token)
      assert response == :ok
    end
  end
end
