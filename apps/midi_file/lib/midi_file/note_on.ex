defmodule MidiFile.NoteOn do
  @moduledoc false

  def process_event(%{type: 9, data: [_key, 0]} = event, scale, list) do
    MidiFile.NoteOff.process_event(%{event | type: 8}, scale, list)
  end

  def process_event(%{delta_time: dt, type: 9, data: [key, value], channel: ch}, nil, _list) do
    %{delta_time: dt, note_on: key, value: value, channel: ch}
  end

  def process_event(%{type: 9, data: [key, _value]} = event, scale, list) do
    event
    |> process_event(nil, list)
    |> Map.merge(Musical.Scale.scale_degree(scale, key))
  end
end
