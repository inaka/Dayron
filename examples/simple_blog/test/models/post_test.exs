defmodule SimpleBlog.PostTest do
  use SimpleBlog.ConnCase
  alias SimpleBlog.Post

  test "defines a post struct" do
    post = struct(Post, %{title: "post title", body: "post body"})  
    assert post.title == "post title"
    assert post.body == "post body"
  end

  test "implements the Dayron.Model resource" do
    assert Post.__resource__ == "posts"
  end
end
