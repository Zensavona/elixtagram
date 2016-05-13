defmodule Elixtagram.Model.ClientConfig do
  defstruct client_id: nil, client_secret: nil, redirect_uri: nil, access_token: nil
end

defmodule Elixtagram.Model.Response do
  defstruct data: nil
end

defmodule Elixtagram.Model.Tag do
  defstruct name: nil, media_count: nil
end

defmodule Elixtagram.Model.Media do
  defstruct attribution: nil, id: nil, caption: nil, comments: nil, type: nil,
            images: nil, likes: nil, link: nil, location: nil, tags: nil,
            user: nil, filter: nil, created_time: nil, users_in_photo: nil
end

defmodule Elixtagram.Model.Location do
  defstruct id: nil, name: nil, latitude: nil, longitude: nil
end

defmodule Elixtagram.Model.User do
  defstruct id: nil, username: nil, bio: nil, website: nil, profile_picture: nil,
            full_name: nil, counts: nil
end

defmodule Elixtagram.Model.UserSearchResult do
  defstruct id: nil, username: nil, full_name: nil, profile_picture: nil
end

defmodule Elixtagram.Model.Comment do
  defstruct id: nil, created_time: nil, text: nil, from: nil
end

defmodule Elixtagram.Model.Relationship do
  defstruct incoming_status: nil, outgoing_status: nil, target_user_is_private: nil
end
