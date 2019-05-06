defmodule BrainWeb.Router do
  use BrainWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/file", BrainWeb.File do
    pipe_through :browser

    resources "/", FileController

  end

  scope "/", BrainWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BrainWeb do
  #   pipe_through :api
  # end
end
