defmodule BrainWeb.File.FileController do
  use BrainWeb, :controller

  def index(conn, _params) do
    files = Brain.FileStorage.get_all()
    render(conn, "index.html", files: files)
  end

  def show(conn, _params) do
    files = Brain.FileStorage.get_all()
    [_| path_elems] = conn.path_info
    path = Enum.map(path_elems, &(URI.decode(&1)))
           |> Enum.join("/")
    file = Brain.FileStorage.get_file(path);
    cond do
      file == Nil -> 
        conn
        |> put_status(:not_found)
        |> put_view(BrainWeb.ErrorView)
        |> render("404.html")
      true -> 
        render(conn, "show.html", files: files, file: file)
    end
  end

  

end
