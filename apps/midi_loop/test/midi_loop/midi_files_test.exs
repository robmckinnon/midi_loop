defmodule MidiLoop.MidiFilesTest do
  use ExUnit.Case, async: true
  alias MidiLoop.MidiFiles
  doctest MidiFiles

  describe "midi files process time division when not frames" do
    test "returns ticks_per_quarter_note" do
      mid = %{"timeDivision" => 480}

      assert {mid, %{:ticks_per_quarter_note => 480}} ==
               MidiFiles.process_time_division({mid, %{}})
    end
  end
end
