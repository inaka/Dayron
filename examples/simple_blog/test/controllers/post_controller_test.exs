defmodule SimpleBlog.PostControllerTest do
  use SimpleBlog.ConnCase

  @valid_attrs %{title: "post title", body: "post body", userId: 1}
  @invalid_attrs %{}
  @post_json """
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  }
  """

  setup %{conn: conn} do
    bypass = Bypass.open
    Application.put_env(:simple_blog, SimpleBlog.RestRepo, url: "http://localhost:#{bypass.port}")

    {:ok, conn: conn, bypass: bypass}
  end

  test "lists all entries on index", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<[#{@post_json}]>)
    end
    conn = get conn, post_path(conn, :index)
    assert html_response(conn, 200) =~ "sunt aut facere repellat"
    assert html_response(conn, 200) =~ "quia et suscipit"
    assert Enum.count(conn.assigns.posts) == 1
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, post_path(conn, :new)
    assert html_response(conn, 200) =~ "New post"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 201, @post_json)
    end

    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :index)
    assert get_flash(conn, :info) =~ "Post created successfully"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 422, ~s<Error on creating post>)
    end
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert html_response(conn, 200) =~ "New post"
    assert html_response(conn, 200) =~ "Error on creating post"
  end

  test "shows chosen resource", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts/1" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, @post_json)
    end
    conn = get conn, post_path(conn, :show, 1)
    assert html_response(conn, 200) =~ "sunt aut facere repellat"
    assert html_response(conn, 200) =~ "quia et suscipit"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts/999" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 404, ~s<{}>)
    end
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, 999)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts/1" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, @post_json)
    end
    conn = get conn, post_path(conn, :edit, 1)
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts/1" == conn.request_path
      assert "PATCH" == conn.method
      Plug.Conn.resp(conn, 200, @post_json)
    end

    conn = put conn, post_path(conn, :update, 1), post: @valid_attrs
    assert get_flash(conn, :info) =~ "Post updated successfully"
    assert redirected_to(conn) == post_path(conn, :show, 1)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts/1" == conn.request_path
      case conn.method do
        "PATCH" -> Plug.Conn.resp(conn, 422, ~s<Error on updating post>)
        "GET" -> Plug.Conn.resp(conn, 200, @post_json)
      end
    end

    conn = put conn, post_path(conn, :update, 1), post: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit post"
    assert html_response(conn, 200) =~ "Error on updating post"
  end

  test "deletes chosen resource", %{conn: conn, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "/posts/1" == conn.request_path
      assert "DELETE" == conn.method
      Plug.Conn.resp(conn, 200, @post_json)
    end

    conn = delete conn, post_path(conn, :delete, 1)
    assert redirected_to(conn) == post_path(conn, :index)
    assert get_flash(conn, :info) =~ "Post deleted successfully"
  end
end
