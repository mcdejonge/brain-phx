defmodule Brain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.warn("Starting application.")
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Brain.Repo,
      # Start the endpoint when the application starts
      BrainWeb.Endpoint,
      # Starts a worker by calling: Brain.Worker.start_link(arg)
      # {Brain.Worker, arg},

      # Start the file find server
      {Brain.FileFindServer, name: Brain.FileFindServer}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Brain.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Make sure we start indexing as soon as the application is started.
    Brain.FileFindServer.refresh(Brain.FileFindServer)
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BrainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
