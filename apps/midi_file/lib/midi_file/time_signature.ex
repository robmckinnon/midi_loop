defmodule MidiFile.TimeSignature do
  @moduledoc false

  import MidiFile, only: [apply_to_meta_type: 4]
  # 88
  @time_signature 0x58

  def process_time_signature({%{track: [track | _tail]} = mid, derived}) do
    {mid, @time_signature |> apply_to_meta_type(&time_signature/2, track, derived)}
  end

  def time_signature(
        [%{data: [data0, data1, data2, data3], meta_type: @time_signature}],
        derived
      ) do
    derived
    |> Map.merge(%{
      numer: data0,
      denom: :math.pow(2, data1),
      metro: data2,
      thirty_seconds: data3
    })
  end

  def time_signature(_, derived), do: derived
end
