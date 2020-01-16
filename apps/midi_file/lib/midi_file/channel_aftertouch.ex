defmodule MidiFile.ChannelAftertouch do
  @moduledoc false

  def process_event(%{delta_time: dt, type: 13, data: value, channel: ch}) do
    %{delta_time: dt, channel_aftertouch: value, channel: ch}
  end
end
