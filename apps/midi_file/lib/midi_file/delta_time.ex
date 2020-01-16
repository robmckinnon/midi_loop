defmodule MidiFile.DeltaTime do
  @moduledoc false

  def process_delta_time({%{track: list} = mid, derived}) do
    tracks = list |> Enum.map(&total_delta_time(&1.event))
    {mid, derived |> Map.merge(%{track_delta_time: tracks})}
  end

  defp total_delta_time(track) do
    total_delta_time =
      track
      |> Enum.filter(&(&1 |> Map.has_key?(:delta_time)))
      |> Enum.map(& &1.delta_time)
      |> Enum.sum()

    %{total_delta_time: total_delta_time}
  end
end
