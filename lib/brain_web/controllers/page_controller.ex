defmodule BrainWeb.PageController do
  use BrainWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
