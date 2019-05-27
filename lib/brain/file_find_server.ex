defmodule Brain.FileFindServer do
  use GenServer

  require Logger

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def find(pid, term) do
    GenServer.call(pid, {:term, term})
  end

  def refresh(pid) do
    GenServer.cast(pid, :refresh)
  end

  # Server (callbacks)

  @impl true
  def init(_) do

    # Make sure the cache is initialized.
    try do
      _ = :ets.lookup(:file_index, "file_index")
      Logger.info("File index cache exists.")
    rescue
      ArgumentError -> 
        Logger.warn("File index cache does not exist. Initialize it.")
        _ = :ets.new(:file_index, [:set, :protected, :named_table])
    end

    {:ok, Nil}
  end

  @impl true
  def handle_call({:term, term}, _, _) do
    result = call_find_in_index_cache(:ets.lookup(:file_index, "file_index"), term)
    {:reply, result, Nil}
  end

  defp call_find_in_index_cache([{_key, index}], term) when is_map(index) do
    Brain.FileFind.find_in_index(index, term)
  end

  defp call_find_in_index_cache(_, _) do
    %{}
  end

  @impl true
  def handle_cast(:refresh, _state) do
    refresh_index()
    {:noreply, Nil}
  end

  defp refresh_index do
    Logger.warn("Refreshing file index cache.")
    basedir = Application.get_env(:brain, BrainWeb.Endpoint)[:content_dir]
    :ets.insert(:file_index, {"file_index", Brain.FileFind.index_dir!(basedir)})
    Logger.warn("Done refreshing file index cache.")
  end

end
