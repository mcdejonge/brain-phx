defmodule Brain.FileStorage do

  @moduledoc """
  Module for handling file storage. 
  """

  require Logger

  @doc """
  Returns a list of all available files (recursively).
  Each item in the list looks like this:
  title : the title to display, meaning the file name without the extension or the directory name if it's a directory.
  type : the file type (""if it's a directory)
  path : the file system path
  children : items below this item (only relevant for directories - [] for files).
  ctime : time last modified
"""
  def get_all() do
    basedir = Application.get_env(:brain, BrainWeb.Endpoint)[:content_dir]
    
    init_cache_if_needed()

    # If there is nothing in the cache, either we haven't loaded it yet - so
    # load it - or there are no files so refreshing it won't hurt.
    cached_data = :ets.lookup(:file_storage, "all_files")
    cond do
      length(cached_data) == 0 ->
        Logger.warn("Cache is empty. Refreshing it.")
        :ets.insert(:file_storage, {"all_files", get_all_below(basedir, basedir)})
      true ->
        Logger.info("Cache is not empty. Returning its contents.")
      end
    [{_key, file_list}] = :ets.lookup(:file_storage, "all_files")
    file_list
  end


  defp init_cache_if_needed do
    try do
      _ = :ets.lookup(:file_storage, "all_files")
      Logger.info("Cache exists.")
    rescue
      ArgumentError -> 
        Logger.warn("Cache does not exist. Initialize it.")
        _ = :ets.new(:file_storage, [:set, :protected, :named_table])
    end
  end

  defp get_all_below(root, startdir) do
    
    Enum.map(Path.wildcard("#{startdir}/*", [true] ), fn(raw) -> 
      {_, stats} = File.stat(raw)
      %{
        :path => Path.relative_to(raw, root), 
        :dir => Path.dirname(raw),
        :type => String.downcase(Regex.replace(~r/^\./, Path.extname(raw), "")),
        :title => Regex.replace(~r/[^a-zA-Z0-9-]+/, Path.basename(raw, Path.extname(raw)), " "),
        :children => get_all_below(root, raw),
        :ctime => stats.ctime
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
  ctime
  """
  def get_file(path) do
    full_path = Path.join(Application.get_env(:brain, BrainWeb.Endpoint)[:content_dir], path)
    cond do
      File.exists?(full_path) -> get_file_verified_to_exist(full_path)
      File.dir?(full_path) -> Nil
      true -> get_file_at_repaired_path(path)
    end
  end

  @doc """
  Vimwiki links don't contain file extensions. This makes them not work.
  Attempt to find the real path for an invalid link.
  """
  defp get_file_at_repaired_path(false_path) do
    correct_path = find_repaired_path(get_all(), false_path)
    cond do
      # Calling get_file on the fixed path would probably work, but would be
      # circular. So no.
      correct_path -> get_file_verified_to_exist(correct_path)
      true -> Nil
    end
  end

  defp find_repaired_path(_item = %{:path => path, :type => type}, requested_path) when path == requested_path <> "." <> type do
    Logger.info("Repaired path is " <> path)
    path
  end

  defp find_repaired_path(itemlist, requested_path) when is_list(itemlist) do
    Logger.info("Looking for " <> requested_path <> " in list of items")
    Enum.find_value(itemlist, fn(item) -> 
      find_repaired_path(item, requested_path)
    end)
  end

  defp find_repaired_path(item = %{}, requested_path) do
    Logger.info("Looking for " <> requested_path <> " in children of " <> item.path)
    Enum.find_value(item.children, fn(child) ->
      find_repaired_path(child, requested_path)
    end)
  end



  defp get_file_verified_to_exist(path) do
    {_, contents} = File.read(path)
    {_, stats} = File.stat(path)
    Logger.info("In get file verified to exist at " <> path <> ": " <> inspect(stats))
    %{
      :path => path,
      :title => Regex.replace(~r/[^a-zA-Z0-9-]+/, Path.basename(path, Path.extname(path)), " "),
      :type => String.downcase(Regex.replace(~r/^\./, Path.extname(path), "")),
      :contents => contents,
      #:ctime => stats.ctime
    }

  end

  
end
