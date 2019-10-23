import util from "util"
import onMidiMessageHandler from "./handle_midi"

const inputs = {}
const outputs = {}

const midiPortState = (port) => {
  return {
    id: port.id,
    manufacturer: port.manufacturer,
    name: port.name,
    type: port.type,
    version: port.version,
    state: port.state,
    connection: port.connection
  }
}

const setPort = (port, collection, ctx, event) => {
  collection[port.id] = port
  ctx.pushEvent(event, midiPortState(port))
}

const INPUT = 'input'
const OUTPUT = 'output'
const MIDI_INPUT = 'midi_input'
const MIDI_OUTPUT = 'midi_output'

const updatePort = (port, ctx) => {
  if (port.type === INPUT) {
    if (!inputs[port.id]) {
      port.onmidimessage = onMidiMessageHandler(ctx)
    }
    setPort(port, inputs, ctx, MIDI_INPUT)
  } else if (port.type === OUTPUT) {
    setPort(port, outputs, ctx, MIDI_OUTPUT)
  } else {
    console.error(port.name)
  }
}

const requestMidiAccess = async (navigator, ctx) => {
  try {
    const midiAccess = await navigator.requestMIDIAccess()
    console.log(util.inspect(midiAccess))

    midiAccess.inputs.forEach(midiInput => updatePort(midiInput, ctx))
    midiAccess.outputs.forEach(midiOutput => updatePort(midiOutput, ctx))
    midiAccess.onstatechange = ({ port }) => updatePort(port, ctx)
  } catch (err) {
    console.error(util.inspect(err))
  }
}

export default requestMidiAccess
