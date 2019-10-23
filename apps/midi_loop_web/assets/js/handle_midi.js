import util from "util"
const WebAudioTinySynth = require('webaudio-tinysynth')

// Summary of MIDI Messages:
// https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message

// Active Sensing. This message is intended to be sent repeatedly to tell the
// receiver that a connection is alive. Use of this message is optional.
// We have found that the problems introduced by active sensing outweigh its
// benefits, therefore we filter out active sensing messages.
const ACTIVE_SENSING = 254 // 11111110

// Timing Clock. This message sent 24 times per quarter note when
// synchronization is required.
const TIMING_CLOCK = 248 // 11111000

const MESSAGE = "m"
let synth = null

// 1001nnnn
const note_on = 144
// 1000nnnn
const note_off = 128
// 1011nnnn
const control_change = 176
// 1100nnnn
const program_change = 192

const STATUS_BYTE = 0xf0
const CHANNEL_BYTE = 0x0f
const NOTE_OFF = 0x80
const NOTE_ON = 0x90

const timestamp = (msg) => {
  return msg.timeStamp || Date.now()
}

const onMidiMessageHandler = (ctx) => {
  return function (msg) {
    if (!msg.data) {
      console.error(util.inspect(msg))
      return
    }
    if (msg.data.length === 1) {
      switch (msg.data[0]) {
        case ACTIVE_SENSING:
          return // ignore active sensing messages
        case TIMING_CLOCK:
          return // ignore timing clock for now
        default:
          console.log(util.inspect(msg.data)) // log other system messages for now
      }
    } else {
      ctx.pushEvent(MESSAGE, {
        d: msg.data,
        t: timestamp(msg),
        i: msg.target.id // msg.target is the midiInput port object
      })
      const messageCode = msg.data[0] & STATUS_BYTE
      const channel = msg.data[0] & CHANNEL_BYTE;
      if (messageCode === NOTE_ON) {
        synth = synth || new WebAudioTinySynth()
        console.log(msg.timeStamp)
        console.log(msg.receivedAt)
        console.log(util.inspect(msg))
        synth.noteOn(channel, msg.data[1], msg.data[2])
      } else if (messageCode === NOTE_OFF) {
        synth = synth || new WebAudioTinySynth()
        synth.noteOff(channel, msg.data[1])
      }
    }
  }
}

export default onMidiMessageHandler
