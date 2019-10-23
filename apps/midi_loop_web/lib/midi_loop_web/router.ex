defmodule MidiLoopWeb.Router do
  use MidiLoopWeb, :router

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

  scope "/", MidiLoopWeb do
    pipe_through :browser

    live "/", MidiLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", MidiLoopWeb do
  #   pipe_through :api
  # end
end
