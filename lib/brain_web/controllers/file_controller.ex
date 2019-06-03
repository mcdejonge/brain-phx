defmodule BrainWeb.File.FileController do
  use BrainWeb, :controller
  require Logger

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
      file == nil -> 
        conn
        |> put_status(:not_found)
        |> put_view(BrainWeb.ErrorView)
        |> render("404.html")
      true -> 
        render(conn, "show.html", files: files, file: file)
    end
  end

  def create(conn, %{"path" => path}) do

    cond do
      Brain.FileStorage.get_file(path)->
        Logger.warn("Attempt to create existing file #{path}")
        conn |> put_status(:conflict)
        |> put_view(BrainWeb.ErrorView)
        |> render("409.html")
      true ->
        Logger.info("Creating new file at path #{path}")
        try do
          Brain.FileStorage.create_file!(path)
          Brain.FileFindServer.refresh(Brain.FileFindServer)
          redirect(conn, to: "/file/#{path}")
        rescue
          e in RuntimeError ->
            conn
            |> put_status(:internal_server_error)
            |> render("500.html")
        end

    end
  end

  def updrate(conn, _params) do
    # TODO
    conn
  end

  def delete(conn, _params) do
    # TODO
    conn
  end


  

end
