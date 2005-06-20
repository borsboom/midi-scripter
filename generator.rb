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
# Code for generating MIDI file
#

require 'midilib'
require 'generator_constants.rb'
require 'unsafe_proxy.rb'

module MIDI
	# Some changes to the MIDI module so it works better for our purposes

	# Add an order_id to events to help us sort them properly
	class Event
		attr_accessor :order_id
	end
	
	# These constants, for some reason, are missing from the library
	CC_BANK_SELECT_COURSE = 0
	CC_BANK_SELECT_FINE = 32 
	CC_DATA_ENTRY_LSB = 38
	CC_ALL_CONTROLLERS_OFF = 121

	# This is buggy in the library because it assume all 8 bits are used, and reverses the lsb and msb
	class PitchBend
		def data_as_bytes
			data = ''
			data << (@status + @channel)
			data << (@value & 0x7f) # lsb
			data << ((@value >> 7) & 0x7f) # msb
			return data
		end
	end

	# We don't actually use this here, but this is similarly buggy in midilib
	#~ class SeqReader
		#~ def pitch_bend(chan, lsb, msb)
			#~ @track.events << PitchBend.new(chan, (msb << 7) + lsb, @curr_ticks)
			#~ track_uses_channel(chan)
		#~ end
	#~ end

end

	
module MidiGenerator

	# Time steps between pitch events in a pitch bend
	Pitch_Bend_Interval = 20
	
	class MidiGenerator
		include MIDI
                
		def initialize(args)
                        if (args and args[:use_safe_mode] != nil)
                                @use_safe_mode = args[:use_safe_mode]
                        else
                                @use_safe_mode = true
                        end
                        # Since the song is evaluated at $SAFE level 4, we need to taint all the MIDI data so it can be accessed.
                        # Setting $SAFE level 3 tains everything.  We do this is another thread because $SAFE is thread-local
                        # and this way it doesn't affect the calling thread.
                        thr = Thread.new do
                                $SAFE = 3
                                @seq = Sequence.new()
                                @control_track = create_seq_track('control')
                                @order_id = 0
                                @top_track = GenTrack.new(self, @control_track)
                                
                                # Enable General MIDI mode.
                                # The following doesn't seem to work, so it's disabled
                                #~ gmEvent = ''
                                #~ gmEvent << 0x7E # Non-realtime
                                #~ gmEvent << 0x7F # Disregard SysEx channel
                                #~ gmEvent << 0x09 # GM System enable/disable
                                #~ gmEvent << 0x01 # enable
                                #~ @top_track.control_event SystemExclusive.new(gmEvent)
                                #~ @top_track.rest 0.1 #Give MIDI device time to reset
                                
                                (0..15).each do |channel|
                                        @top_track.event Controller.new(channel, CC_ALL_CONTROLLERS_OFF, 0)
                                end
                        end
                        thr.join
                        self.taint
		end
                
		def create_seq_track(name = nil)
			track = Track.new(@seq)
			@seq.tracks << track
			if (name)
				track.name = name
			end
			return track
		end
		
		def new_order_id
			@order_id += 1
			return @order_id
		end
			
		def control_event(ev)
			ev.order_id = @order_id
			@order_id += 1
			@control_track.events << ev;
		end
		
		def length_to_delta(length)
			if (length.instance_of? String)
				length = @seq.note_to_length(length)
			end
			return @seq.length_to_delta(length)
		end
		
		def load_track(filename)
                        if @use_safe_mode
                                # Since $SAFE level 4 code can't open files, we need a way to read a file.  The UnsafeProxy gives
                                # the $SAFE level 4 code a way to access an object at $SAFE level 0.
                                @loader = UnsafeProxy.new(Loader.new)
                                begin
                                        thr = Thread.new do
                                                # Run the user-supplied code at $SAFE level 4 so it can't do any harm
                                                $SAFE = 4
                                                @saved_exception = nil
                                                begin
                                                        @top_track.load_track(filename)
                                                rescue Exception => ex
                                                        # We want the caller to have a useful backtrace, and if we just let the exception propagate on its own,
                                                        # all they know is that it happened in thr.join, which is pointless.  So instead we save the exception
                                                        # with its backtrace and re-raise it outside the thread
                                                        @saved_exception = ex
                                                end
                                        end
                                        thr.join
                                ensure
                                        @loader.destroy
                                end
                                if @saved_exception
                                        raise @saved_exception
                                end
                        else
                                @loader = Loader.new
                                @top_track.load_track(filename)
                        end
		end
		
		def _read(filename)
			@loader.read(filename)
		end
		
		def _debug_msg(s)
			@loader.debug_msg(s)
		end
		
		def save_sequence(filename)
			@seq.tracks.each do |track|
				track.events.sort! do |a, b|
					if a.time_from_start == b.time_from_start && a.order_id && b.order_id
						a.order_id <=> b.order_id 
					else
						a.time_from_start <=> b.time_from_start
					end
				end
				track.recalc_delta_from_times
			end						
			File.open(filename, 'wb') do |file|
				@seq.write(file)
			end
		end
	end
	
	class Loader
		# This class may look pointless, but it is accessed using an UnsafeProxy which allows $SAFE level 4 code to
		# read files.
		def read(filename)
			File.open(filename) do |f|
				s = f.read
			end				
		end	
		def debug_msg(s)
			puts s
		end
	end
	
	class GenTrack
		include MIDI
	
		def initialize(generator, seqTrack)
			@gen = generator
			@time = 0
			@channel = 0
			@velocity = 64
			@transpose = 0
			@dir = '.'
			@create_midi_tracks = true
			@seqTrack = seqTrack;
		end
		
		def control_event(ev)
			ev.time_from_start = @time
			@gen.control_event(ev)
		end
		
		def event(ev)
			ev.time_from_start = @time
			ev.order_id = @gen.new_order_id
			@seqTrack.events << ev;
		end

		def tempo(bpm)
			control_event Tempo.new(Tempo.bpm_to_mpq(bpm));
		end
		
		def channel(chan)
			@channel = chan - 1
		end
		
		def enable_midi_tracks
			@create_midi_tracks = true
		end
		
		def disable_midi_tracks
			@create_midi_tracks = false
		end
		
		def event_channel
			@channel
		end
		
		def bank(bank, fine = nil)
			event Controller.new(event_channel, CC_BANK_SELECT_COURSE, bank)
			if (fine)
				event Controller.new(event_channel, CC_BANK_SELECT_FINE, fine)
			end
		end
		
		def program(prog)
			event ProgramChange.new(event_channel, prog)
		end
		
		def volume(vol)
			event Controller.new(event_channel, CC_VOLUME, vol)
		end
		
		def velocity(vel)
			@velocity = vel
		end
		
		def transpose(semitones)
			@transpose = semitones
		end
		
		def chorus(chor)
			event Controller.new(event_channel, CC_CHORUS_DEPTH, chor)	
		end
		
		def pan(p)
			event Controller.new(event_channel, CC_PAN, p)	
		end
		
		def reverb(rev)
			event Controller.new(event_channel, 91, rev)	
		end
		
		# Portamento does not work with most MIDI drivers, so this is disabled
		#def portamento(speed)
		#	if !speed
		#		event Controller.new(event_channel, CC_PORTAMENTO, 0)		
		#	else
		#		event Controller.new(event_channel, CC_PORTAMENTO, 127)
		#		event Controller.new(event_channel, CC_PORTAMENTO_TIME, speed)		
		#	end
		#end
		
		def pitch(val)
			val = (val * 8192).floor + 8192
			if val > 16383 then val = 16383 end
			if val < 0 then val = 0 end
			event PitchBend.new(event_channel, val)
		end
		
		def _pitch_bend_length_delta(start_pitch, end_pitch, length_delta)
			start_time = @time
			start_pitch = start_pitch.to_f
			end_pitch = end_pitch.to_f
			0.step(length_delta, Pitch_Bend_Interval) do |i|
				@time = start_time + i
				pitch(((end_pitch - start_pitch) * i/ length_delta.to_f) + start_pitch)
			end
			@time = start_time + length_delta		
			pitch(end_pitch)
		end
		
		def pitch_bend(start_pitch, end_pitch, length)
			length_delta = @gen.length_to_delta(length)
			_pitch_bend_length_delta(start_pitch, end_pitch, length_delta)
		end
		
		def pitch_range(semitones)
			event Controller.new(event_channel, CC_REG_PARAM_LSB, 0)
			event Controller.new(event_channel, CC_REG_PARAM_MSB, 0)
			lsb = ((semitones - semitones.floor) * 100).floor
			msb = semitones.floor
			event Controller.new(event_channel, CC_DATA_ENTRY_LSB, lsb)
			event Controller.new(event_channel, CC_DATA_ENTRY_MSB, msb)
		end

		def drum(note_num, params = {})
			p = params.dup
			p[Transpose] = false
			if params[Length]
				note note_num, params[Length], p
			else
				note note_num, Quarter, p
				rewind Quarter
			end
		end
		
		def rest(length)
			@time += @gen.length_to_delta(length)	
		end
		
		def rewind(length)
			@time -= @gen.length_to_delta(length)	
		end
		
		def time(time)
			@time = @gen.length_to_delta(time);
		end
	
		def _do_note(note_nums, params)
			if !note_nums.instance_of? Array
				note_nums = [note_nums]
			end
			if params[Velocity]
				velocity = params[Velocity]
			else
				velocity = @velocity
			end
			note_nums.each do |note_num|
				ev = yield note_num + ((params[Transpose] == nil || params[Transpose] != false) ? @transpose : 0), velocity
				event ev
			end
		end
		
		def note_on(note_nums, params = {})
			_do_note(note_nums, params) { |note_num, velocity| NoteOnEvent.new(event_channel, note_num, velocity) }
		end
		
		def note_off(note_nums, params = {})
			_do_note(note_nums, params) { |note_num, velocity| NoteOffEvent.new(event_channel, note_num, velocity) }
		end

		def note(note_nums, length, params = {})
			lengthDelta = @gen.length_to_delta(length)
			note_on note_nums, params
			@time += lengthDelta
			note_off note_nums, params
		end
		
		def start_porta(speed, &block)
			porta = GenPorta.new(@gen, self)
			porta._do(speed, &block)
		end
		
		def start_track(params, &block)
			self.dup._do_start_track(params, &block)
		end
		
		def _do_start_track(params, &block)
			if (params[Channel])
				channel params[Channel]
			end
			if (@create_midi_tracks)
				@seqTrack = @gen.create_seq_track(params[Name])		
			end
			instance_eval &block			
		end
		
		def load_track(filename, track_params = {})
			full_filename = File.expand_path(filename, @dir)
			if (!track_params[Name])
				track_params[Name] = File.basename(filename)
			end
			start_track(track_params) do
				@dir = File.dirname(full_filename)
				s = nil
				s = @gen._read(full_filename)
				instance_eval s, full_filename, 1
			end
		end
		
		def _time
			@time
		end
		
		def _time=(t)
			@time = t
		end
		
	end

	class GenPorta
	
		def initialize(gen, track)
			@gen = gen
			@track = track
		end
		
		def _do(spd, &block)
			# First phase runs the block and determines first note and pitch range
			@phase = 1
			@center_note = -1
			@first_notes = nil;
			@first_notes_params = nil;
			@range = 0	
			@prev_pitch = 0		
			self.instance_eval &block
			if @range == 0 then
				raise 'start_porta must have at least two notes'
			end
			
			# Second phase starts the first note and then bends the pitch upon note commands
			@phase = 2
			@track.pitch_range @range
			@track.pitch 0
			speed spd
			@track.note_on @first_notes, @first_notes_params
			@prev_note = @first_notes
			if @prev_note.instance_of? Array then @prev_note = @prev_note[0] end
			self.instance_eval &block
			
			# And finally we stop the note and reset the pitch
			@track.note_off @first_notes, @first_notes_params
			@track.pitch 0
		end

		def note(note_nums, length, params = {})
			lengthDelta = @gen.length_to_delta(length)
			if note_nums.instance_of? Array
				note_num = note_nums[0]
			else
				note_num = note_nums
			end
			if @phase == 1
				if @center_note == -1
					@center_note = note_num
					@first_notes = note_nums
					@first_notes_params = params
				end
				dist = (note_num - @center_note).abs
				if dist > @range
					@range = dist
				end
			else
				p = ((note_num - @center_note) / @range.to_f)
				if (@prev_pitch == p)
					# no change in pitch, so don't pitch bend
					@track._time += lengthDelta
				else
					delta = ((note_num - @prev_note).abs * @delta)
					if (lengthDelta < delta)
						# If bend time is longer than note, speed up the bend
						delta = lengthDelta
					end			
					@track._pitch_bend_length_delta @prev_pitch, p, delta
					@prev_pitch = p
					@prev_note = note_num
					@track._time += lengthDelta - delta
				end
			end		
		end

		def speed(spd)
			if @phase != 1
				@delta = (@gen.length_to_delta(1.0) / spd).to_i
			end
		end	
		
	end
	
end