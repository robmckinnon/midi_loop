defmodule MidiFileTest do
  use ExUnit.Case
  doctest MidiFile

  def init_first_track(event) do
    %{
      track: [
        %{
          event: [
            event
          ]
        }
      ]
    }
  end

  describe "process_time_division when not frames" do
    test "returns ticks_per_quarter_note" do
      mid = %{time_division: 480}

      assert {mid, %{:ticks_per_quarter_note => 480}} ==
               MidiFile.process_time_division({mid, %{}})
    end
  end

  describe "process_set_tempo when set tempo meta in first track" do
    test "returns microseconds_per_quarter_note" do
      mid =
        init_first_track(%{
          data: 631_580,
          delta_time: 0,
          meta_type: MidiFile.SetTempo.meta_type(),
          type: 255
        })

      assert {mid, %{:microseconds_per_quarter_note => 631_580}} ==
               MidiFile.process_set_tempo({mid, %{}})
    end
  end

  describe "process_set_tempo when set tempo meta not in first track" do
    test "returns default microseconds_per_quarter_note" do
      mid =
        init_first_track(%{
          data: 631_580,
          delta_time: 0,
          meta_type: MidiFile.SetTempo.meta_type() - 1,
          type: 255
        })

      # assert {mid, %{:microseconds_per_quarter_note => 631_580}} ==
      # todo: what is default microseconds_per_quarter_note
      assert {mid, %{}} ==
               MidiFile.process_set_tempo({mid, %{}})
    end
  end

  describe "process_time_signature when time signature in first track" do
    test "returns numer, denom, metro, thirtySeconds" do
      mid =
        init_first_track(%{
          data: [4, 2, 24, 8],
          delta_time: 0,
          meta_type: MidiFile.TimeSignature.meta_type(),
          type: 255
        })

      expected = %{
        denom: 4,
        metro_clicks_per_tick: 24,
        numer: 4,
        thirty_second_notes_per_beat: 8
      }

      assert {mid, expected} ==
               MidiFile.process_time_signature({mid, %{}})
    end
  end

  describe "process_time_signature when time signature not in first track" do
    test "returns default numer, denom, metro, thirtySeconds" do
      mid =
        init_first_track(%{
          data: [4, 2, 24, 8],
          delta_time: 0,
          meta_type: MidiFile.TimeSignature.meta_type() - 1,
          type: 255
        })

      assert {mid, %{}} ==
               MidiFile.process_time_signature({mid, %{}})
    end
  end

  describe "process_key_signature when in first track" do
    test "returns mode, tonic" do
      mid =
        init_first_track(%{
          data: [4, 0],
          delta_time: 0,
          meta_type: MidiFile.KeySignature.meta_type(),
          type: 255
        })

      expected = %{mode: :major, tonic: :E}

      assert {mid, expected} ==
               MidiFile.process_key_signature({mid, %{}})
    end
  end
end
