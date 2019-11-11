import requestMidiAccess from "./setup_midi"
import setupReader from "./read_midi_file"

const ConnectMidi = {
  mounted() {
    if (!navigator.requestMIDIAccess) {
      this.el.disabled = true
      this.el.innerHTML =
        "This browser <a href='https://developer.mozilla.org/en-US/docs/Web/API/MIDIAccess#Browser_compatibility'>does not support Web MIDI</a>. Try site in <a href='https://www.google.com/chrome/'>Chrome browser</a>."
      alert("This browser does not support Web MIDI. Try site in Chrome browser.")
      return
    } else {
      const ctx = this
      const handler = () => {
        const requestAccess = requestMidiAccess
        const setupRead = setupReader
        console.log('Request access...')
        requestAccess(navigator, ctx)
      }
      this.el.addEventListener("click", handler)
    }
  }
}

export default ConnectMidi
