defmodule MidiFile do
  @moduledoc """
  MidiFile processing.
  """
  alias MidiFile.{
    BeatsPerMinute,
    ChannelAftertouch,
    ControlChange,
    DeltaTime,
    KeySignature,
    ProgramChange,
    NoteAftertouch,
    NoteOn,
    NoteOff,
    PitchBend,
    SetTempo,
    TimeDivision,
    TimeSignature
  }

  def process(mid) do
    {mid, %{}}
    |> MidiFile.process_time_division()
    |> MidiFile.process_set_tempo()
    |> MidiFile.process_time_signature()
    |> MidiFile.process_key_signature()
    |> MidiFile.process_bpm()
    |> MidiFile.process_delta_time()
    |> MidiFile.process_tracks()
  end

  defp filter_meta_type(events, value) do
    events
    |> Stream.filter(&(Map.has_key?(&1, :meta_type) && &1.meta_type == value))
    |> Enum.take(1)
  end

  def apply_to_meta_type(meta_type, func, %{event: events}, derived) when is_list(events) do
    events
    |> filter_meta_type(meta_type)
    |> func.(derived)
  end

  def process_tracks({%{track: list} = mid, derived}) do
    tracks = Enum.map(list, &process_events(&1.event, %{processed_events: []}, nil))
    {mid, derived |> Map.merge(%{track: tracks})}
  end

  def process_events([], state, _scale) do
    %{event: state.processed_events |> Enum.reverse()}
  end

  def process_events([event | tail], state, scale) do
    processed = process_event(event, scale, state.processed_events)

    scale =
      case processed do
        %{mode: mode, tonic: tonic} -> Musical.Scale.scale_notes(tonic, mode)
        _ -> scale
      end

    state = %{state | processed_events: [processed | state.processed_events]}
    process_events(tail, state, scale)
  end

  # defp post_process(%{mode: mode, tonic: tonic} = e, map) do
  #   {map, e}
  # end
  #
  # defp post_process(%{} = e, map) do
  #   {map, e}
  # end

  defdelegate process_time_division(mid_derived_tuple), to: TimeDivision

  defdelegate process_set_tempo(mid_derived_tuple), to: SetTempo

  defdelegate process_time_signature(mid_derived_tuple), to: TimeSignature

  defdelegate process_key_signature(mid_derived_tuple), to: KeySignature

  defdelegate process_bpm(mid_derived_tuple), to: BeatsPerMinute

  defdelegate process_delta_time(mid_derived_tuple), to: DeltaTime

  @key_signature 0x59
  # 0x8 - 0xE
  @note_off 8
  @note_on 9
  @note_aftertouch 10
  @controller 11
  @program_change 12
  @channel_aftertouch 13
  @pitch_bend 14

  def process_event(%{meta_type: @key_signature} = event, _scale, _list),
    do: KeySignature.process_event(event)

  def process_event(%{meta_type: _} = event, _scale, _list), do: event

  def process_event(%{type: @note_off} = event, scale, list),
    do: NoteOff.process_event(event, scale, list)

  def process_event(%{type: @note_on} = event, scale, list),
    do: NoteOn.process_event(event, scale, list)

  def process_event(%{type: @note_aftertouch} = event, _scale, _list),
    do: NoteAftertouch.process_event(event)

  def process_event(%{type: @controller} = event, _scale, _list),
    do: ControlChange.process_event(event)

  def process_event(%{type: @program_change} = event, _scale, _list),
    do: ProgramChange.process_event(event)

  def process_event(%{type: @channel_aftertouch} = event, _scale, _list),
    do: ChannelAftertouch.process_event(event)

  def process_event(%{type: @pitch_bend} = event, _scale, _list),
    do: PitchBend.process_event(event)
end
