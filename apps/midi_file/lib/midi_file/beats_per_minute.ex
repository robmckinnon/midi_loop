defmodule MidiFile.BeatsPerMinute do
  @moduledoc false

  @microseconds_per_minute 60_000_000
  # %{
  #   denom: 8,
  #   metro_clicks_per_tick: 24,
  #   microseconds_per_quarter_note: 631580,
  #   numer: 6,
  #   ticks_per_quarter_note: 480,
  # }

  @doc """
  When musicians refer to a "beat" in terms of tempo, they are referring to a
  quarter note (ie, a quarter note is always 1 beat when talking about tempo,
  regardless of the time signature. Yes, it's a bit confusing to non-musicians
  that the time signature's "beat" may not be the same thing as the tempo's
  "beat" -- it won't be unless the time signature's beat also happens to be a
  quarter note. But that's the traditional definition of BPM tempo).
  """
  def process_bpm(
        {mid,
         %{
           denom: _denom,
           microseconds_per_quarter_note: microseconds_per_quarter_note,
           numer: _numer
         } = derived}
      ) do
    # quarter_note_x = 4/denom
    # beats_per_bar = numer
    # quarter_notes_per_bar = quarter_note_x * beats_per_bar
    # beats_per_quarter_note = beats_per_bar / quarter_notes_per_bar

    quarter_notes_per_minute = @microseconds_per_minute / microseconds_per_quarter_note
    # bpm = quarter_notes_per_minute * beats_per_quarter_note

    {mid, derived |> Map.merge(%{bpm: quarter_notes_per_minute |> Float.round()})}
  end
end
