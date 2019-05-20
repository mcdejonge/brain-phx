defmodule Brain.FileFind do
  @moduledoc """
  Search for text in files.
  
  @ignorewords contains a list of words to ignore.

  ## TODO list:


  ### FAR into the future

  * Allow searching multiple terms
  * Keep track of neighbors
  * Build a graph
  * Get fancy.
  """

  @ignorewords [
    "de",
    "het",
    "een",
    "die",
    "dat",
    "deze",
    "dit",
    "om",
    "te",
    "the",
    "a",
    "an",
    "this",
    "that",
    "to",
  ]
  
  @doc """
  Return a term index (term => number of occurences) for the given file. The term index is a map with the number
  of occurences for each term.
  
  Throws an exception if the file can't be read.

  ## Parameters

  - file: the file to read

  """
  def index_file!(file) do
    File.read!(file)
    |> String.trim
    |> String.downcase
    |> String.split(~r/\W+/)
    |> Enum.reduce(%{}, fn(word, words) -> 
      cond do
        word in @ignorewords -> words
        true -> Map.update(words, word, 1, & &1 + 1) 
      end
      end)
  end

  @doc """
  Return an index of all files in a given directory. The index is a map with the 
  path of every file as the key and a map of available terms and their occurences
  for the file.

  Throws an exception if a file can't be indexed.

  ## Parameters

  - dir: the directory to index
  """
  def index_dir!(dir) do
    index_dir!(%{} , dir)
  end

  # As it turns out, the version that uses Flow is *slower* than the version
  # that does not. So here's the Flow version we don't currently use.
  #defp index_dir_flow!(index, dir) do
    #Flow.from_enumerable(Path.wildcard("#{dir}/*"))
    #|> Flow.reduce(fn -> index end, fn(path, index_in_fn) ->
      #cond do
        #File.dir?(path) -> index_dir!(index_in_fn, path)
        ### Only index txt and md files
        #File.regular?(path) && String.match?(path, ~r/\.(txt|md)$/) 
          #-> Map.put(index_in_fn, path, index_file!(path))
        #true -> index_in_fn
      #end
    #end)
    #|> Enum.into(%{})
  #end

  # And here is the non-flow version.
  defp index_dir!(index, dir) do
    Path.wildcard("#{dir}/*")
    |> Enum.reduce(index, fn(path, index_in_fn) ->
      cond do
        File.dir?(path) -> index_dir!(index_in_fn, path)
        # Only index txt and md files
        File.regular?(path) && String.match?(path, ~r/\.(txt|md)$/) 
          -> Map.put(index_in_fn, path, index_file!(path))
        true -> index_in_fn
      end
    end)
  end


  @doc """
  Return files in the given index that match the given search term: a map and the number of occurences of the term.

  Throws an error if a file can't be read.

  ## Parameters

  - index: the index (see index_dir) to search
  - term: the term to search for.
  """
  def find_in_index(index, term) do
    #Enum.filter(index, fn({_path, item_index}) ->
      #find_in_index_entry(item_index, term) > 0
    #end)
    Enum.reduce(index, %{}, fn({path, item_index}, acc) ->
      num_matches = find_in_index_entry(item_index, term)
      cond do
        num_matches > 0 -> Map.update(acc, path, num_matches, &(&1 + num_matches) ) 
        true -> acc
      end
    end)

  end

  defp find_in_index_entry(index, term) do
    Map.get(index, term, 0)
  end





end
