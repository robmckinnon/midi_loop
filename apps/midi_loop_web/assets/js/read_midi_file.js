const midiParser  = require('midi-parser-js')

const MIDI_FILE_MESSAGE = "mid"

const ReadMidi = {
  mounted() {
    midiParser.parse(this.el, obj => {
      const ctx = this
      ctx.pushEvent(MIDI_FILE_MESSAGE, { mid: obj })
    })
  }
}

export default ReadMidi
