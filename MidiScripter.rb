# MIDI SCRIPTER
# Copyright (c) 2005 Emanuel Borsboom
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
# ------------------------------------------------------------------------------------
#
# Entry Point
#

require 'getoptlong'

Midi_Scripter_Version = "0.5.0"

$PROGRAM_DIR = File.dirname(File.expand_path(__FILE__)) unless defined? $PROGRAM_DIR
$LOAD_PATH[0, 0] = File.expand_path('lib', $PROGRAM_DIR)
$LOAD_PATH[0, 0] = File.expand_path($PROGRAM_DIR)

$safe_opt = true
argn = 0
if (ARGV.length - argn >= 1 && ARGV[argn] == '--unsafe')
        $safe_opt = false
        argn += 1
end

# If command-line arguments provided, generate the MIDI file and quit before the GUI is initialized
if ARGV.length - argn == 2
	require "generator.rb"
	gen = MidiGenerator::MidiGenerator.new(:use_safe_mode => $safe_opt)
	gen.load_track(File.expand_path(ARGV[argn]))
	gen.save_sequence(ARGV[argn + 1])
else
	require "wxruby_gui.rb"
	WxMidiGui::MidiApp.new.main_loop
end
