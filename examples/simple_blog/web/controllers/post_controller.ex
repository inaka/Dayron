defmodule SimpleBlog.PostController do
  use SimpleBlog.Web, :controller

  alias SimpleBlog.RestRepo
  alias SimpleBlog.Post

  plug :scrub_params, "post" when action in [:create, :update]

  def index(conn, _params) do
    posts = RestRepo.all(Post)
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    render(conn, "new.html", error: nil)
  end

  def create(conn, %{"post" => post_params}) do
    case RestRepo.insert(Post, post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :index))
      {:error, %{response: response}} ->
        render(conn, "new.html", error: response.body)
    end
  end

  def show(conn, %{"id" => id}) do
    post = RestRepo.get!(Post, id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = RestRepo.get!(Post, id)
    conn = %{conn | params: %{"post" => stringify_keys(post) }}
    render(conn, "edit.html", post: post, error: nil)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    case RestRepo.update(Post, id, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, %{response: response}} ->
        post = RestRepo.get!(Post, id)
        render(conn, "edit.html", post: post, error: response.body)
    end
  end

  def delete(conn, %{"id" => id}) do
    RestRepo.delete!(Post, id)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  defp stringify_keys(post) do
    post
    |> Map.from_struct
    |> Enum.reduce(%{}, fn ({key, val}, acc) -> 
      Map.put(acc, Atom.to_string(key), val) 
    end)
  end
end
