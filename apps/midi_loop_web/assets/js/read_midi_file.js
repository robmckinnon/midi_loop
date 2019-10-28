import {MidiParser} from 'midi-parser.js'

// select the INPUT element that will handle
// the file selection.
let source = document.getElementById('filereader');

// provide the File source and a callback function
MidiParser.parse( source, function(obj){
  console.log(obj);
});
