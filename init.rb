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
# Entry-point used by tar2rubyscript.rb and rubyscript2exe.rb - Assumes wxRuby is available and display any errors with it (since there is no access to console)
#

require "wxruby"

$PROGRAM_DIR = File.dirname(File.expand_path(__FILE__))

class ErrorApp < Wx::App
	def on_init
		Wx::message_box($errorMsg,  "MidiScripter Fatal Error", Wx::OK | Wx::ICON_ERROR)
	end
end

begin
        Dir.chdir oldlocation if defined? oldlocation
        load File.expand_path('MidiScripter.rb', $PROGRAM_DIR)
rescue Exception => exception
	#puts exception.to_s
	$errorMsg = exception.to_s # + "\n\n" + exception.backtrace.join("\n")
	ErrorApp.new.main_loop	
end
