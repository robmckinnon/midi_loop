defmodule MidiFile.NoteAftertouch do
  @moduledoc false

  def process_event(%{delta_time: dt, type: 10, data: [key, value], channel: ch}) do
    %{delta_time: dt, note_aftertouch: key, value: value, channel: ch}
  end
end
