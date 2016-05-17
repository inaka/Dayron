defmodule SimpleBlog.PageController do
  use SimpleBlog.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
