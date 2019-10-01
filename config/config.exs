# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :midi_loop,
  ecto_repos: [MidiLoop.Repo]

config :midi_loop_web,
  ecto_repos: [MidiLoop.Repo],
  generators: [context_app: :midi_loop]

# Configures the endpoint
config :midi_loop_web, MidiLoopWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PQLSrtKuu0QAjwgK1Bp4+B5OZdVnwIH3WKHk7YBaXoTaIJqy8qn/D4902eR9qpR5",
  render_errors: [view: MidiLoopWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MidiLoopWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
