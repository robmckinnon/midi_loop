defmodule MidiFile.KeySignature do
  @moduledoc false

  import MidiFile, only: [apply_to_meta_type: 4]
  # 89
  @key_signature 0x59
  def meta_type, do: @key_signature

  def process_key_signature({%{track: [track | _tail]} = mid, derived}) do
    {
      mid,
      @key_signature |> apply_to_meta_type(&key_signature/2, track, derived)
    }
  end

  def key_signature(
        [%{data: [data0, data1], meta_type: @key_signature}],
        derived
      ) do
    scale =
      case data1 do
        0 -> :major
        1 -> :minor
      end

    key = tonic(scale, data0)

    derived
    |> Map.merge(%{
      mode: scale,
      tonic: key
    })
  end

  def key_signature(_, derived), do: derived

  defp tonic(:major, value) do
    case value do
      7 -> :Cs
      6 -> :Fs
      5 -> :B
      4 -> :E
      3 -> :A
      2 -> :D
      1 -> :G
      0 -> :C
      -1 -> :F
      -2 -> :Bb
      -3 -> :Eb
      -4 -> :Ab
      -5 -> :Db
      -6 -> :Gb
      -7 -> nil
    end
  end

  defp tonic(:minor, value) do
    case value do
      7 -> :As
      6 -> :Ds
      5 -> :Gs
      4 -> :Cs
      3 -> :Fs
      2 -> :B
      1 -> :E
      0 -> :A
      -1 -> :D
      -2 -> :G
      -3 -> :C
      -4 -> :F
      -5 -> :Bb
      -6 -> :Eb
      -7 -> :Ab
    end
  end
end
