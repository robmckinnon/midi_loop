defmodule MidiFileTest do
  use ExUnit.Case
  doctest MidiFile

  describe "process_time_division when not frames" do
    test "returns ticks_per_quarter_note" do
      mid = %{time_division: 480}

      assert {mid, %{:ticks_per_quarter_note => 480}} ==
               MidiFile.process_time_division({mid, %{}})
    end
  end

  # 81
  @set_tempo 0x51

  describe "process_set_tempo when set tempo meta in first track" do
    test "returns microseconds_per_quarter_note" do
      mid = %{
        track: [%{event: [%{data: 631_580, delta_time: 0, meta_type: @set_tempo, type: 255}]}]
      }

      assert {mid, %{:microseconds_per_quarter_note => 631_580}} ==
               MidiFile.process_set_tempo({mid, %{}})
    end
  end

  describe "process_set_tempo when set tempo meta not in first track" do
    test "returns default microseconds_per_quarter_note" do
      mid = %{
        track: [%{event: [%{data: 631_580, delta_time: 0, meta_type: @set_tempo - 1, type: 255}]}]
      }

      # assert {mid, %{:microseconds_per_quarter_note => 631_580}} ==
      # todo: what is default microseconds_per_quarter_note
      assert {mid, %{}} ==
               MidiFile.process_set_tempo({mid, %{}})
    end
  end

  # obj.track[0].event.forEach(e => {
  #   if (e.metaType) {
  #     if (e.metaType === TIME_SIGNATURE) {
  #       console.log(util.inspect(e.data))
  #       obj.numer = e.data[0]
  #       obj.denom = Math.pow(2, e.data[1])
  #       obj.metro = e.data[2]
  #       obj.thirtySeconds = e.data[3]
  #     }
  #   }

  # %{
  #   format_type: 1,
  #   time_division: 480,
  #   track: [
  #     %{
  #       event: [
  #         %{data: [4, 2, 24, 8], delta_time: 0, meta_type: 88, type: 255},
  #         %{data: 65024, delta_time: 0, meta_type: 89, type: 255},
  #         %{data: 631580, delta_time: 0, meta_type: 81, type: 255},

  # 88
  @time_signature 0x58

  describe "process_time_signature when time signature in first track" do
    test "returns numer, denom, metro, thirtySeconds" do
      mid = %{
        track: [
          %{event: [%{data: [4, 2, 24, 8], delta_time: 0, meta_type: @time_signature, type: 255}]}
        ]
      }

      expected = %{denom: 4.0, metro: 24, numer: 4, thirty_seconds: 8}

      assert {mid, expected} ==
               MidiFile.process_time_signature({mid, %{}})
    end
  end

  describe "process_time_signature when time signature not in first track" do
    test "returns default numer, denom, metro, thirtySeconds" do
      mid = %{
        track: [
          %{
            event: [
              %{data: [4, 2, 24, 8], delta_time: 0, meta_type: @time_signature - 1, type: 255}
            ]
          }
        ]
      }

      assert {mid, %{}} ==
               MidiFile.process_time_signature({mid, %{}})
    end
  end
end
