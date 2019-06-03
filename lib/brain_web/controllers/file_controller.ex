defmodule BrainWeb.File.FileController do
  @moduledoc """
  HTML version of the file controller.
  """
  use BrainWeb, :controller

  alias BrainWeb.File.FileControllerBase, as: FCBase

  require Logger

  def index(conn, params) do
    {conn, files} = FCBase.index(conn, params)
    render(conn, "index.html", files: files)
  end

  def show(conn, params) do
    {conn, file} = FCBase.show(conn, params)
    cond do
      file == nil ->
        conn
        |> put_status(:not_found)
        |> put_view(BrainWeb.ErrorView)
        |> render("404.html")
      true -> 
        files = Brain.FileStorage.get_all()
        render(conn, "show.html", files: files, file: file)
    end
  end

  def create(conn, params) do
    {conn, result} = FCBase.create(conn, %{"path" => path} = params)
    cond do
      result -> redirect(conn, to: "/file/#{path}")
      true ->
        cond do
          conn.status == :conflict ->
            conn 
            |> put_view(BrainWeb.ErrorView)
            |> render("409.html")
          true ->
            conn
            |> put_view(BrainWeb.ErrorView)
            |> render("500.html")
        end
    end
  end

  def update(conn, _params) do
    # TODO
    conn
  end

  def delete(conn, _params) do
    # TODO
    conn
  end


  

end
