defmodule MidiFile.TimeDivision do
  @moduledoc false

  require Bitwise

  @time_division_is_frames 0x8000

  def process_time_division({mid = %{time_division: time_division}, derived}) do
    if time_division_is_frames?(time_division) do
      # todo handle frames
      {mid, derived}
    else
      {mid, derived |> Map.merge(%{ticks_per_quarter_note: time_division})}
    end
  end

  defp time_division_is_frames?(time_division) do
    Bitwise.&&&(time_division, @time_division_is_frames) != 0
  end
end
