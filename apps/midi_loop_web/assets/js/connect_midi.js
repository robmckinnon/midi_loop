import requestMidiAccess from "./setup_midi"

const ConnectMidi = {
  mounted() {
    if (!navigator.requestMIDIAccess) {
      this.el.disabled = true
      this.el.innerHTML =
        "This browser <a href='https://developer.mozilla.org/en-US/docs/Web/API/MIDIAccess#Browser_compatibility'>does not support Web MIDI</a>. Try site in <a href='https://www.google.com/chrome/'>Chrome browser</a>."
      alert("This browser does not support Web MIDI. Try site in Chrome browser.")
      return
    } else {
      const _this = this
      const handler = () => {
        const requestAccess = requestMidiAccess
        console.log('Request access...')
        requestAccess(navigator, _this)
      }
      this.el.addEventListener("click", handler)
    }
  }
}

export default ConnectMidi
