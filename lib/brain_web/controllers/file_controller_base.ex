defmodule BrainWeb.File.FileControllerBase do

  use BrainWeb, :controller

  @moduledoc """
  Base module for controllers that deal with files. All functions take two parameters:

  - conn
  - params

  These should be passed as is from the controller.

  They will return a tuple with conn as the first element. Any other return value is added to the tuple.
  """

  require Logger

  @doc """
  Returns a list of all available files.
  """
  def index(conn, _params) do
    {conn, Brain.FileStorage.get_all()}
  end

  @doc """
  Returns a single file. Path is taken from path_info in conn

  """
  def show(conn, _params) do
    [_| path_elems] = conn.path_info
    path = Enum.map(path_elems, &(URI.decode(&1)))
           |> Enum.join("/")
    {conn, Brain.FileStorage.get_file(path)}
  end

  @doc """
  Creates a new file. Returns true if successful and false if not.

  Should receive a query parameter "path" with the path of the new file.
  """
  def create(conn, %{"path" => path}) do

    cond do
      Brain.FileStorage.get_file(path)->
        Logger.warn("Attempt to create existing file #{path}")
        {conn |> put_status(:conflict), false}
      true ->
        Logger.info("Creating new file at path #{path}")
        try do
          Brain.FileStorage.create_file!(path)
          Brain.FileFindServer.refresh(Brain.FileFindServer)
          {conn, true}
        rescue
          _e in RuntimeError ->
            {conn |> put_status(:internal_server_error), false}
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
