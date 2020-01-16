defmodule MidiFile.ProgramChange do
  @moduledoc false
  alias MidiFile.GeneralMidiInstrument

  def process_event(%{delta_time: dt, type: 12, data: program_number, channel: ch}) do
    %{
      channel: ch,
      delta_time: dt,
      instrument: GeneralMidiInstrument.level_1_sound(program_number + 1),
      program_number: program_number
    }
  end
end
