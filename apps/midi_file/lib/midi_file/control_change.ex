defmodule MidiFile.ControlChange do
  @moduledoc false

  def process_event(%{delta_time: dt, type: 11, data: [key, value], channel: ch}) do
    %{delta_time: dt, control_change: key, value: value, channel: ch}
  end
end
