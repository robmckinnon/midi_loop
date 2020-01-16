defmodule MidiFile.TimeSignature do
  @moduledoc false

  import MidiFile, only: [apply_to_meta_type: 4]
  # 88
  @time_signature 0x58
  def meta_type, do: @time_signature

  def process_time_signature({%{track: [track | _tail]} = mid, derived}) do
    {mid, @time_signature |> apply_to_meta_type(&time_signature/2, track, derived)}
  end

  def time_signature(
        [%{data: [data0, data1, data2, data3], meta_type: @time_signature}],
        derived
      ) do
    {denom, _} = :math.pow(2, data1) |> Float.to_string() |> Integer.parse()

    derived
    |> Map.merge(%{
      numer: data0,
      denom: denom,
      metro_clicks_per_tick: data2,
      thirty_second_notes_per_beat: data3
    })
  end

  def time_signature(_, derived), do: derived
end
