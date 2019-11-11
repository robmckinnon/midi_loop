defmodule MidiFile do
  @moduledoc """
  MidiFile processing.
  """
  alias MidiFile.{SetTempo, TimeDivision, TimeSignature}

  defp filter_meta_type(events, value) do
    events
    |> Stream.filter(&(&1.meta_type == value))
    |> Enum.take(1)
  end

  def apply_to_meta_type(meta_type, func, %{event: events}, derived) when is_list(events) do
    events
    |> filter_meta_type(meta_type)
    |> func.(derived)
  end

  defdelegate process_time_division(mid_derived_tuple), to: TimeDivision

  defdelegate process_set_tempo(mid_derived_tuple), to: SetTempo

  defdelegate process_time_signature(mid_derived_tuple), to: TimeSignature
end
