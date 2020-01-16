defmodule MidiFile.NoteOff do
  @moduledoc false

  def process_event(%{delta_time: dt, type: 8, data: [key, _value], channel: ch}, nil, _list) do
    %{delta_time: dt, note_off: key, channel: ch}
  end

  def process_event(%{type: 8, data: [key, _value]} = event, scale, list) do
    # note_on = Enum.find(list, & &1.note_on == key)
    event
    |> process_event(nil, list)
    |> Map.merge(Musical.Scale.scale_degree(scale, key))
  end
end
