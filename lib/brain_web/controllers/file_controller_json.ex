defmodule BrainWeb.File.FileControllerJSON do
  @moduledoc """
  JSON API version of the file controller.
  """
  use BrainWeb, :controller

  alias BrainWeb.File.FileControllerBase, as: FCBase

  require Logger

  def index(conn, params) do
    {conn, files} = FCBase.index(conn, params)
    json(conn, files)
  end

  def show(conn, params) do
    # HACK the first element in the path info is "file". It needs to be
    # stripped.
    [_|[_| path_elems]] = conn.path_info
    path = Enum.map(path_elems, &(URI.decode(&1)))
           |> Enum.join("/")
    {conn, file} = FCBase.show(conn, %{"path" => path})
    cond do
      file == nil ->
        conn
        |> put_status(:not_found)
        json(conn, [])
      true -> 
        files = Brain.FileStorage.get_all()
        json(conn, file)
    end
  end

  def create(conn, params) do
    {conn, result} = FCBase.create(conn, %{"path" => path} = params)
    cond do
      result -> redirect(conn, to: "/file/#{path}")
      true ->
        json(conn, [])
    end
  end


  # TODO the rest
end
