defmodule Midi.MessageHandler do
  @moduledoc """
  Handle MIDI messages.

  Summary of MIDI Messages:
  https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message
  """

  alias Midi.{Note, Quantise}

  @nil_duration nil
  @nil_beats nil

  @doc """
  Add note to events and notes.
  """
  def note_on(time, initial_time, _ms_per_beat, number, velocity, %{
        events: events,
        grid: grid,
        notes_on: notes_on
      })
      when is_integer(number) and is_integer(velocity) and
             is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: velocity}
    notes_on = notes_on |> Map.put(number, note)

    %{
      events: [{time, time - initial_time, @nil_duration, @nil_beats, note} | events],
      grid: grid,
      notes_on: notes_on
    }
  end

  defp set_note_duration(_number, _end_time, _ms_per_beat, []) do
    {[], nil}
  end

  defp set_note_duration(number, end_time, ms_per_beat, [
         {start_time, rel_time, @nil_duration, @nil_beats, %Note{number: number} = note} | events
       ]) do
    duration = end_time - start_time
    beats = duration / ms_per_beat
    {[{start_time, rel_time, duration, beats, note} | events], duration}
  end

  defp set_note_duration(number, end_time, ms_per_beat, [event | events]) do
    {events, duration} = set_note_duration(number, end_time, ms_per_beat, events)
    {[event | events], duration}
  end

  @doc """
  Add note off to events and remove from notes.
  """
  def note_off(time, initial_time, ms_per_beat, number, %{
        events: events,
        grid: grid,
        notes_on: notes_on
      })
      when is_integer(number) and is_map(notes_on) and is_list(events) do
    note = %Note{number: number, velocity: 0}
    notes_on = notes_on |> Map.delete(number)
    {events, duration} = set_note_duration(number, time, ms_per_beat, events)
    rel_time = time - initial_time

    grid_update = case duration do
      nil ->
        grid
      _ ->
        start_end_beats =
          Quantise.start_end_beats(
            round(rel_time - duration),
            round(duration),
            round(ms_per_beat / 4)
          )
        [[{number} | start_end_beats] | grid]
      end

    %{
      events: [{time, rel_time, @nil_duration, @nil_beats, note} | events],
      grid: grid_update,
      notes_on: notes_on
    }
  end

  @doc """
  Add control change to events.
  """
  def control_change(time, initial_time, key, value, %{events: events} = channel_state) do
    put_in(channel_state.events, [{time, time - initial_time, {key, value}} | events])
  end

  def init_time(%{initial_time: nil} = state, time), do: %{state | initial_time: time}
  def init_time(state, _time), do: state

  @initial_channel_state %{
    events: [],
    notes_on: %{},
    grid: []
  }

  def init_state(channel, state, time, port_id, channel_mode_message) do
    state = init_time(state, time)
    state = if !(state.inputs[port_id].channels |> Map.has_key?(channel)) do
      if channel_mode_message do
        state
      else
        put_in(state.inputs[port_id].channels[channel], channel)
      end
    else
      state
    end

    if state.channels[channel] == nil do
      put_in(state.channels[channel], @initial_channel_state)
    else
      state
    end
  end

  # 1001nnnn
  @note_on 144
  # 1000nnnn
  @note_off 128
  # 1011nnnn
  @control_change 176
  # 1100nnnn
  @program_change 192

  def handle_message(@note_on, note, 0, channel, port_id, time, state) do
    handle_message(@note_off, note, 0, channel, port_id, time, state)
  end

  def handle_message(@note_on, note, velocity, channel, port_id, time, state) do
    state = init_state(channel, state, time, port_id, false)

    updated =
      note_on(
        time,
        state.initial_time,
        state.ms_per_beat,
        note,
        velocity,
        state.channels[channel]
      )

    put_in(state.channels[channel], updated)
  end

  def handle_message(@note_off, note, _velocity, channel, _port_id, time, state) do
    if state.channels[channel] != nil do
      updated =
        note_off(time, state.initial_time, state.ms_per_beat, note, state.channels[channel])

      state = put_in(state.channels[channel], updated)
      state
    else
      state
    end
  end

  @channel_mode_messages [120,121,122,123,124,125,126,127]
  def handle_message(@control_change, key, value, channel, port_id, time, state) do
    channel_mode_message = key in @channel_mode_messages
    state = init_state(channel, state, time, port_id, channel_mode_message)

    # IO.puts([
    #   "CC ",
    #   Integer.to_string(key),
    #   " ",
    #   Integer.to_string(value),
    #   " ",
    #   Integer.to_string(channel)
    # ])

    updated = control_change(time, state.initial_time, key, value, state.channels[channel])
    put_in(state.channels[channel], updated)
  end

  def handle_message(@program_change, number, channel, _port_id, _time, state) do
    IO.puts([
      "PC ",
      Integer.to_string(number),
      " ",
      Integer.to_string(channel)
    ])

    state
  end
end
