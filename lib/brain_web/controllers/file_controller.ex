defmodule BrainWeb.File.FileController do
  use BrainWeb, :controller

  def index(conn, _params) do
    files = Brain.FileStorage.get_all("/Users/matthijs/00_db")
    render(conn, "index.html", files: files)
  end

  

end
