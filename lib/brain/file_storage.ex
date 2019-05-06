defmodule Brain.FileStorage do

  @moduledoc """
  Module for handling file storage. 
  """

  @doc """
  Returns a list of all available files (recursively).
  Each item in the list looks like this:
  title : the title to display, meaning the file name without the extension or the directory name if it's a directory.
  type : the file type (""if it's a directory)
  path : the file system path
  children : items below this item (only relevant for directories - [] for files).
  TODO : date last modified
"""
  def get_all() do
    basedir = Application.get_env(:brain, BrainWeb.Endpoint)[:content_dir]
    get_all_below(basedir, basedir)
  end

  defp get_all_below(root, startdir) do
    Enum.map(Path.wildcard("#{startdir}/*", [true] ), fn(raw) -> 
      %{
        :path => Path.relative_to(raw, root), 
        :dir => Path.dirname(raw),
        :type => String.downcase(Regex.replace(~r/^\./, Path.extname(raw), "")),
        :title => Regex.replace(~r/[^a-zA-Z0-9-]+/, Path.basename(raw, Path.extname(raw)), " "),
        :children => get_all_below(root, raw)
      }
    end)
    |> Enum.sort(fn a, b -> a.type >= b.type end)
    |> Enum.sort(fn a, b -> a.title <= b.title end)
  end


  @doc """
  Return data for the requested file. The path is expanded to the full path, ie appended to the base content dir.
  path : the path to open
  Returns: Nil if the file does not exist or is a directory, otherwise a map with:
  title
  path (relative to content dir)
  type
  contents
  TODO make it a struct
  """
  def get_file(path) do
    full_path = Path.join(Application.get_env(:brain, BrainWeb.Endpoint)[:content_dir], path)
    cond do
      ! File.exists?(full_path) -> Nil
      File.dir?(full_path) -> Nil
      true -> get_file_verified_to_exist(path)
        
    end
  end

  defp get_file_verified_to_exist(path) do
    full_path = Path.join(Application.get_env(:brain, BrainWeb.Endpoint)[:content_dir], path)
    {_, contents} = File.read(full_path)
    %{
      :path => path,
      :title => Regex.replace(~r/[^a-zA-Z0-9-]+/, Path.basename(full_path, Path.extname(full_path)), " "),
      :type => String.downcase(Regex.replace(~r/^\./, Path.extname(full_path), "")),
      :contents => contents,
    }

  end
  
end
