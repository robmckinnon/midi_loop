defmodule MidiFile.SetTempo do
  @moduledoc false

  import MidiFile, only: [apply_to_meta_type: 4]
  # 81
  @set_tempo 0x51

  def process_set_tempo({%{track: [track | _tail]} = mid, derived}) when is_map(track) do
    {mid, @set_tempo |> apply_to_meta_type(&set_tempo/2, track, derived)}
  end

  def set_tempo([%{data: data, meta_type: @set_tempo}], derived) do
    derived
    |> Map.merge(%{microseconds_per_quarter_note: data})
  end

  def set_tempo(_, derived), do: derived
end
