defmodule MidiLoop.Repo do
  use Ecto.Repo,
    otp_app: :midi_loop,
    adapter: Ecto.Adapters.Postgres
end
