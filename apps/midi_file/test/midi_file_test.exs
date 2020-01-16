defmodule MidiFileTest do
  use ExUnit.Case
  doctest MidiFile

  alias MidiFile.{KeySignature, SetTempo, TimeSignature}

  def init_track(events) do
    %{
      event: events
    }
  end

  def init_first_track(event) do
    %{
      track: [
        init_track([event])
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
          meta_type: SetTempo.meta_type(),
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
          meta_type: SetTempo.meta_type() - 1,
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
          meta_type: TimeSignature.meta_type(),
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
          meta_type: TimeSignature.meta_type() - 1,
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
          meta_type: KeySignature.meta_type(),
          type: 255
        })

      expected = %{mode: :major, tonic: :E}

      assert {mid, expected} ==
               MidiFile.process_key_signature({mid, %{}})
    end
  end

  describe "bpm calculation 4/4 time" do
    test "works" do
      derived = %{
        denom: 4,
        metro_clicks_per_tick: 24,
        microseconds_per_quarter_note: 631_580,
        numer: 4,
        thirty_second_notes_per_beat: 8,
        ticks_per_quarter_note: 480
      }

      assert {%{}, derived |> Map.merge(%{bpm: 95.0})} ==
               MidiFile.process_bpm({%{}, derived})
    end
  end

  describe "bpm calculation 6/8 time" do
    test "works" do
      derived = %{
        denom: 8,
        metro_clicks_per_tick: 24,
        microseconds_per_quarter_note: 631_580,
        numer: 6,
        ticks_per_quarter_note: 480
      }

      assert {%{}, derived |> Map.merge(%{bpm: 95.0})} ==
               MidiFile.process_bpm({%{}, derived})
    end
  end

  describe "track length" do
    test "calculates for each track" do
      mid = %{
        track: [
          init_track([%{delta_time: 3}, %{delta_time: 0}, %{delta_time: 333}]),
          init_track([%{delta_time: 36}])
        ]
      }

      assert {mid,
              %{
                track_delta_time: [
                  %{total_delta_time: 336},
                  %{total_delta_time: 36}
                ]
              }} ==
               MidiFile.process_delta_time({mid, %{}})
    end
  end

  describe "control change" do
    test "records change at time" do
      mid = %{
        track: [
          init_track([%{delta_time: 0, type: 11, data: [121, 0], channel: 0}]),
          init_track([%{delta_time: 0, type: 11, data: [7, 103], channel: 1}])
        ]
      }

      assert {mid,
              %{
                track: [
                  %{event: [%{channel: 0, control_change: 121, delta_time: 0, value: 0}]},
                  %{event: [%{channel: 1, control_change: 7, delta_time: 0, value: 103}]}
                ]
              }} = MidiFile.process_tracks({mid, %{}})
    end
  end

  describe "program change" do
    test "records change at time" do
      mid = %{
        track: [
          init_track([%{delta_time: 0, type: 12, data: 120, channel: 0}])
        ]
      }

      assert {mid, derived} = MidiFile.process_tracks({mid, %{}})

      assert %{
               track: [
                 %{
                   event: [
                     %{
                       channel: 0,
                       instrument: "Guitar Fret Noise",
                       program_number: 120,
                       delta_time: 0
                     }
                   ]
                 }
               ]
             } = derived
    end
  end

  describe "key signature" do
    setup do
      mid = %{
        time_division: 480,
        track: [
          init_track([
            %{
              data: 631_580,
              delta_time: 0,
              meta_type: SetTempo.meta_type(),
              type: 255
            },
            %{
              data: [4, 0],
              delta_time: 0,
              meta_type: KeySignature.meta_type(),
              type: 255
            },
            %{
              data: [4, 2, 24, 8],
              delta_time: 0,
              meta_type: TimeSignature.meta_type(),
              type: 255
            },
            %{delta_time: 0, type: 9, data: [51, 95], channel: 2},
            %{delta_time: 5, type: 9, data: [52, 127], channel: 2},
            %{delta_time: 0, type: 9, data: [51, 0], channel: 2}
          ])
        ]
      }

      %{mid: mid}
    end

    @tag :focus
    test "returned in events", %{mid: mid} do
      assert {mid, derived} = MidiFile.process(mid)

      assert %{
               track: [
                 %{
                   event: [
                     eventa,
                     eventb,
                     eventc,
                     event1,
                     event2,
                     event3
                     # event4
                   ]
                 }
               ]
             } = derived

      IO.inspect(mid, label: "mid")
      IO.inspect(derived, label: "derived")

      # assert %{data: [4, 0], delta_time: 0, meta_type: 89, type: 255} = eventb
      assert %{delta_time: 0, mode: :major, tonic: :E} = eventb

      assert %{
               channel: 2,
               delta_time: 0,
               note_on: 51,
               value: 95,
               note: :Ds,
               octave: 3,
               degree: 7
             } = event1

      assert %{
               channel: 2,
               delta_time: 5,
               note_on: 52,
               value: 127,
               note: :E,
               octave: 3,
               degree: 1
             } = event2

      assert %{
               channel: 2,
               delta_time: 0,
               note_off: 51,
               note: :Ds,
               octave: 3,
               degree: 7
             } = event3

      assert %{duration: 5} = event3

    end
  end
end
