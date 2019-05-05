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
"""
  def get_all(basedir) do
    get_all_below(basedir, "")
  end

  defp get_all_below(root, startdir) do
    Enum.map(Path.wildcard("#{root}/#{startdir}/*"), fn(raw) -> 
      %{:path => Path.relative_to(raw, root), 
        :dir => Path.dirname(raw),
        :type => String.downcase(Regex.replace(~r/^\./, Path.extname(raw), "")),
        :title => Regex.replace(~r/[^a-zA-Z0-9-]+/, Path.basename(raw, Path.extname(raw)), " "),
        :children => get_all_below(root, raw)
      }
    end)
    |> Enum.sort(fn a, b -> a.type >= b.type end)
    |> Enum.sort(fn a, b -> a.title <= b.title end)
  end
  
end
