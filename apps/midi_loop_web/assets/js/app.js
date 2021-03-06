// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import "core-js/stable"
import "regenerator-runtime/runtime"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import ConnectMidi from "./connect_midi"
import ReadMidi from "./read_midi_file"

const Hooks = {
  ConnectMidi,
  ReadMidi
}

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks })
liveSocket.connect()
