defmodule SimpleBlog.Post do
  @moduledoc """
    A Dayron Model to interact with /posts resource in api
  """
  use Dayron.Model, resource: "posts"

  defstruct id: nil, userId: nil, title: "", body: ""
end
