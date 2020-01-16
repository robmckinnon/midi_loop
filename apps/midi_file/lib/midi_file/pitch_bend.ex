defmodule MidiFile.PitchBend do
  @moduledoc false

  def process_event(%{delta_time: dt, type: 14, data: [lsb, msb], channel: ch}) do
    %{delta_time: dt, pitch_bend: [lsb, msb], channel: ch}
  end
end
