const midiParser  = require('midi-parser-js')
const midiParser2 = require('func-midi-parser');
const MIDI_FILE_MESSAGE = "mid"

const ReadMidi = {
  mounted() {
    midiParser.parse(this.el, obj => {
      const ctx = this
      ctx.pushEvent(MIDI_FILE_MESSAGE, { mid: obj })
    })
    this.el.addEventListener('change', function(InputEvt) {
      if (!InputEvt.target.files.length) return false
      console.log('MidiParser.addListener() : File detected in INPUT ELEMENT processing data..')
      const reader = new FileReader()
      reader.readAsArrayBuffer(InputEvt.target.files[0])
      reader.onload =  function(e) {
        const obj = midiParser2.parse(new Uint8Array(e.target.result))
        console.log('---')
        // console.log(JSON.stringify(obj))
        // console.log(JSON.stringify(obj['track'][0]['event'][4]))
        // console.log(JSON.stringify(obj['track'][0]['event'][5]))
        // console.log(JSON.stringify(obj.track[0].event[3]))
        // console.log(JSON.stringify(obj.track[0].event[3]))
      }
    })
  }
}

export default ReadMidi
