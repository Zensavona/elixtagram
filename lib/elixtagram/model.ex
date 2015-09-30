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
  defstruct attribution: nil, id: nil, caption: nil, comments: nil,
            images: nil, likes: nil, link: nil, location: nil,
            tags: nil, user: nil
end

defmodule Elixtagram.Model.Location do
  defstruct id: nil, name: nil, latitude: nil, longitude: nil
end
