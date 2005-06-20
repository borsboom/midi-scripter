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
# User interface using wxRuby
#

require "wxruby"
require "generator"

module WxMidiGui

	class MidiApp < Wx::App
		def on_init
			set_vendor_name("EmanuelBorsboom")
			set_app_name("MidiScripter")
			MidiFrame.new.show()
		end
	end
	 
	class MidiFrame < Wx::Dialog
	
		def initialize
			super(nil, -1, "MIDI Scripter (v#{Midi_Scripter_Version})", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::MINIMIZE_BOX | Wx::SYSTEM_MENU | Wx::CAPTION)
			evt_close { on_close }
			
			conf = Wx::ConfigBase::get()
			
			vsizer = Wx::BoxSizer.new(Wx::VERTICAL)
	
			hsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@inputFileText = Wx::TextCtrl.new(self, -1, conf.read("/Settings/InputFile", File.expand_path("example.song")), Wx::DEFAULT_POSITION, Wx::Size.new(250, -1))
			hsizer.add(@inputFileText, 1, Wx::ALL, 2)
			selectInputFileButton = Wx::Button.new(self, -1, "Select &Input File...")		
			hsizer.add(selectInputFileButton, 0, Wx::ALL, 2)
			evt_button(selectInputFileButton.get_id) { on_selectInputFileButton }
			vsizer.add(hsizer, 0, Wx::EXPAND)
			
			hsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@outputFileText = Wx::TextCtrl.new(self, -1, conf.read("/Settings/OutputFile", File.expand_path("example.mid")), Wx::DEFAULT_POSITION, Wx::Size.new(250, -1))
			hsizer.add(@outputFileText, 1, Wx::ALL, 2)
			selectOutputFileButton = Wx::Button.new(self, -1, "Select &Output File...")		
			hsizer.add(selectOutputFileButton, 0, Wx::ALL, 2)
			evt_button(selectOutputFileButton.get_id) { on_selectOutputFileButton }
			vsizer.add(hsizer, 0, Wx::EXPAND)
			
			hsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@playerPathText = Wx::TextCtrl.new(self, -1, conf.read("/Settings/PlayerPath", "C:\\Program Files\\Windows Media Player\\wmplayer.exe"), Wx::DEFAULT_POSITION, Wx::Size.new(250, -1))
			hsizer.add(@playerPathText, 1, Wx::ALL, 2)
			selectPlayerPathButton = Wx::Button.new(self, -1, "Select MIDI Player...")		
			hsizer.add(selectPlayerPathButton, 0, Wx::ALL, 2)
			evt_button(selectPlayerPathButton.get_id) { on_selectPlayerPathButton }
			vsizer.add(hsizer, 0, Wx::EXPAND)		
	
			hsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			generateButton = Wx::Button.new(self, -1, "&Generate MIDI File")
			hsizer.add(generateButton, 0, Wx::ALL, 2)
			evt_button(generateButton.get_id) { on_generateButton }
			playButton = Wx::Button.new(self, -1, "Generate and &Play")
			hsizer.add(playButton, 0, Wx::ALL, 2)
			evt_button(playButton.get_id) { on_playButton }
			quitSizer = Wx::BoxSizer.new(Wx::VERTICAL)
			quitButton = Wx::Button.new(self, Wx::ID_CANCEL, "&Quit")
			quitSizer.add(quitButton, 0, Wx::ALIGN_RIGHT|Wx::ALL, 2)
			evt_button(quitButton.get_id) { on_quitButton }
			hsizer.add(quitSizer, 1, Wx::EXPAND, 2)
			vsizer.add(hsizer, 0, Wx::EXPAND)
			
			copyright = Wx::StaticText.new(self, -1, "Copyright (c) 2005 Emanuel Borsboom.  See COPYING.txt for license.")
			vsizer.add(copyright, 1, Wx::CENTER|Wx::ALL, 4)
	
			set_sizer(vsizer)
			vsizer.fit(self)
			vsizer.set_size_hints(self)
		end
		
		def message(title, text)
			Wx::MessageDialog.new(self, text, title, Wx::OK | Wx::ICON_INFORMATION).show_modal()
		end
	
		def error(title, text)
			Wx::MessageDialog.new(self, text, title, Wx::OK | Wx::ICON_ERROR).show_modal()
		end
		
		def on_close
			conf = Wx::ConfigBase::get()
			conf.write("/Settings/InputFile", @inputFileText.get_value)
			conf.write("/Settings/OutputFile", @outputFileText.get_value)
			conf.write("/Settings/PlayerPath", @playerPathText.get_value)
			destroy()
		end
	
		def on_selectInputFileButton
			dlg = Wx::FileDialog.new(self, "Select Input File", File.dirname(@inputFileText.get_value), File.basename(@inputFileText.get_value), "Song Files (*.song)|*.song|All Files (*.*)|*.*", Wx::OPEN, Wx::DEFAULT_POSITION)
			if dlg.show_modal == Wx::ID_OK
				@inputFileText.set_value(File.expand_path(dlg.get_filename, dlg.get_directory))
				
			end
		end
		
		def on_selectOutputFileButton
		
			dlg = Wx::FileDialog.new(self, "Select Output File", File.dirname(@outputFileText.get_value), File.basename(@outputFileText.get_value), "MIDI Files (*.mid;*.midi;*.smf)|*.midi;*.smf;*.mid|All Files (*.*)|*.*", Wx::SAVE, Wx::DEFAULT_POSITION)
			if dlg.show_modal == Wx::ID_OK
				@outputFileText.set_value(File.expand_path(dlg.get_filename, dlg.get_directory))
			end
		end
		
		def generate
                        ex = nil
                        Wx::BusyCursor.busy do
                                begin
                                        gen = MidiGenerator::MidiGenerator.new(:use_safe_mode => $safe_opt)
                                        gen.load_track(@inputFileText.get_value)
                                        gen.save_sequence(@outputFileText.get_value)
                                rescue Exception => exception
                                        ex = exception
                                end
                        end
                        if ex
				#puts ex.to_s + "\n" + ex.backtrace.join("\n")				
				# Give the user a friendly indication of where the error was without a full backtrace
				# If the exception happend in generator.rb, go down the backtrace until we find what called a method in generator.rb
				bt = ex.backtrace.find { |b| !(b =~ /generator\.rb/) }				
				if bt == nil then bt = ex.backtrace[0] end
				# The string ":in `instance_eval'" is just confusing, so remove it
				bt.sub!(/:in `.*'/, '')
				error("Error Generating MIDI File", ex.to_s + "\n\n(" + bt + ")")
				return false
			end
			return true
		end
		
		def on_generateButton
			if generate
				message "MIDI Scripter", "The output file has been successfully created."
			end
		end
		
		def on_playButton
			if generate	
                                Wx::BusyCursor.busy do
                                        if !system(@playerPathText.get_value, @outputFileText.get_value)
                                                error("Error Playing MIDI File", "Could not start MIDI player.")
                                        end
                                end
			end
		end
		
		def on_quitButton
			close(true)
		end
		
		def on_selectPlayerPathButton
			dlg = Wx::FileDialog.new(self, "Select MIDI Player", File.dirname(@playerPathText.get_value), File.basename(@playerPathText.get_value), "Programs (*.exe)|*.exe|All Files (*.*)|*.*", Wx::OPEN, Wx::DEFAULT_POSITION)
			if dlg.show_modal == Wx::ID_OK
				@playerPathText.set_value(File.expand_path(dlg.get_filename, dlg.get_directory))
			end
		end
		
	end
end