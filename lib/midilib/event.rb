require 'midilib/consts'
require 'midilib/utils'

module MIDI

# The abstract superclass of all MIDI events.
class Event
    # Modifying delta_time does not affect time_from_start. You need to call
    # the event's track's +recalc_time+ method.
    attr_accessor :delta_time
    # The start time of this event from the beginning of the track. This value
    # is held here but is maintained by the track.
    attr_accessor :time_from_start
    # The MIDI status byte. Never includes the channel, which is held
    # separately by MIDI::ChannelEvent.
    attr_reader :status

    # Determines if to_s outputs hex note numbers (false, the default) or
    # decimal note names (true).
    attr_accessor :print_note_names

    # Determines if to_s outputs numbers as hex (false, the default) or
    # decimal # (true). Delta times are always printed as decimal.
    attr_accessor :print_decimal_numbers

    def initialize(status = 0, delta_time = 0)
	@status = status
	@delta_time = delta_time
	@is_channel = false	# the majority of events are channel events
	@is_note = false	# note on, note off, and poly press return true
	@is_note_on = false
	@is_note_off = false
	@is_meta = false
	@is_system = false
	@is_realtime = false
	@time_from_start = 0	# maintained by tracks
    end
    protected :initialize

    # Returns the raw bytes that are written to a MIDI file or output to a
    # MIDI stream. In MIDI::EVENT this raises a "subclass responsibility"
    # exception.
    def data_as_bytes
	raise "subclass responsibility"
    end

    # Returns +true+ if this is a channel event.
    def channel?
	return @is_channel
    end

    # Returns +true+ if this is a note on, note off, or polyphonic pressure
    # event.
    def note?
	return @is_note
    end

    # Returns +true+ if this is a note on event.
    def note_on?
	@is_note_on
    end

    # Returns +true+ if this is a note off event.
    def note_off?
	@is_note_off
    end

    # Returns +true+ if this is a meta event.
    def meta?
	return @is_meta
    end

    # Returns +true+ if this is a system message event.
    def system?
	return @is_system
    end

    # Returns +true+ if this is a realtime status byte.

    def realtime?
	return @is_realtime
    end

    # Quantize this event's time_from_start by moving it to the nearest
    # multiple of +boundary+. See MIDI::Track#quantize. *Note*: does not
    # modify the event's delta_time, though MIDI::Track#quantize calls
    # recalc_delta_from_times after it asks each event to quantize itself.
    def quantize_to(boundary)
	diff = @time_from_start % boundary
	@time_from_start -= diff
	if diff >= boundary / 2
	    @time_from_start += boundary
	end
    end

    # For sorting. Uses @time_from_start, which is maintained by this event's
    # track. I'm not sure this is necessary, since each track has to
    # maintain its events' time-from-start values anyway.
    def <=>(an_event)
	return @time_from_start <=> an_event.time_from_start
    end

    # Returns +val+ as a decimal or hex string, depending upon the value of
    # @print_decimal_numbers.
    def number_to_s(val)
	return @print_decimal_numbers ? val.to_s : ('%02x' % val)
    end

    def to_s
	"#{@delta_time}: "
    end
end

# The abstract superclass of all channel events (events that have a MIDI
# channel, like notes and program changes).
class ChannelEvent < Event
    # MIDI channel, 0-15.
    attr_accessor :channel

    def initialize(status, channel, delta_time)
	super(status, delta_time)
	@channel = channel
	@is_channel = true
    end
    protected :initialize

    def to_s
	return super << "ch #{number_to_s(@channel)} "
    end

end

# The abstract superclass of all note on, and note off, and polyphonic
# pressure events.
class NoteEvent < ChannelEvent
    attr_accessor :note, :velocity
    def initialize(status, channel, note, velocity, delta_time)
	super(status, channel, delta_time)
	@note = note
	@velocity = velocity
	@is_note = true
    end
    protected :initialize

    PITCHES = %w(C C# D D# E F F# G G# A A# B)

    # Returns note name as a pitch/octave string like "C4" or "F#6".
    def pch_oct(val=@note)
	pch = val % 12
	oct = (val / 12) - 1
	"#{PITCHES[pch]}#{oct}"
    end

    # If @print_note_names is true, returns pch_oct(val) else returns value
    # as a number using number_to_s.
    def note_to_s
	return @print_note_names ? pch_oct(@note) : number_to_s(@note)
    end

    def data_as_bytes
	data = ''
	data << (@status + @channel)
	data << @note
	data << @velocity
	return data
    end
end

class NoteOnEvent < NoteEvent
    attr_accessor :off
    def initialize(channel = 0, note = 64, velocity = 64, delta_time = 0)
	super(NOTE_ON, channel, note, velocity, delta_time)
	@is_note_on = true
    end
    def to_s
	return super <<
	    "on #{note_to_s} #{number_to_s(@velocity)}"
    end
end

class NoteOffEvent < NoteEvent
    attr_accessor :on
    def initialize(channel = 0, note = 64, velocity = 64, delta_time = 0)
	super(NOTE_OFF, channel, note, velocity, delta_time)
	@is_note_off = true
    end
    def to_s
	return super <<
	    "off #{note_to_s} #{number_to_s(@velocity)}"
    end
end

class PolyPressure < NoteEvent
    def initialize(channel = 0, note = 64, value = 0, delta_time = 0)
	super(POLY_PRESSSURE, channel, note, value, delta_time)
    end

    def pressure
	return @velocity
    end
    def pressure=(val)
	@velocity = val
    end
    def to_s
	return super <<
	    "poly press #{number_to_s(@channel)} #{note_to_s} #{number_to_s(@velocity)}"
    end
end

class Controller < ChannelEvent
    attr_accessor :controller, :value

    def initialize(channel = 0, controller = 0, value = 0, delta_time = 0)
	super(CONTROLLER, channel, delta_time)
	@controller = controller
	@value = value
	@is_controller = true
    end

    def data_as_bytes
	data = ''
	data << (@status + @channel)
	data << @controller
	data << @value
	return data
    end

    def to_s
	return super << "cntl #{number_to_s(@controller)} #{number_to_s(@value)}"
    end
end

class ProgramChange < ChannelEvent
    attr_accessor :program

    def initialize(channel = 0, program = 0, delta_time = 0)
	super(PROGRAM_CHANGE, channel, delta_time)
	@program = program
    end

    def data_as_bytes
	data = ''
	data << (@status + @channel)
	data << @program
	return data
    end

    def to_s
	return super << "prog #{number_to_s(@program)}"
    end
end

class ChannelPressure < ChannelEvent
    attr_accessor :pressure

    def initialize(channel = 0, pressure = 0, delta_time = 0)
	super(CHANNEL_PRESSURE, channel, delta_time)
	@pressure = pressure
    end

    def data_as_bytes
	data = ''
	data << (@status + @channel)
	data << @pressure
	return data
    end

    def to_s
	return super << "chan press #{number_to_s(@pressure)}"
    end
end

class PitchBend < ChannelEvent
    attr_accessor :value

    def initialize(channel = 0, value = 0, delta_time = 0)
	super(PITCH_BEND, channel, delta_time)
	@value = value
    end

    def data_as_bytes
	data = ''
	data << (@status + @channel)
	data << ((@value >> 8) & 0xff) # msb
	data << (@value & 0xff) # lsb
	return data
    end

    def to_s
	return super << "pb #{number_to_s(@value)}"
    end
end

class SystemCommon < Event
    def initialize(status, delta_time)
	super(status, delta_time)
	@is_system = true
    end
end

class SystemExclusive < SystemCommon
    attr_accessor :data

    def initialize(data, delta_time = 0)
	super(SYSEX, delta_time)
	@data = data
    end

    def data_as_bytes
	data = ''
	data << @status
	data << Utils.as_var_len(@data.length)
	data << @data
	data << EOX
	return data
    end

    def to_s
	return super << "sys ex"
    end
end

class SongPointer < SystemCommon
    attr_accessor :pointer

    def initialize(pointer = 0, delta_time = 0)
	super(SONG_POINTER, delta_time)
	@pointer = pointer
    end

    def data_as_bytes
	data = ''
	data << @status
	data << ((@pointer >> 8) & 0xff)
	data << (@pointer & 0xff)
	return data
    end

    def to_s
	return super << "song ptr #{number_to_s(@pointer)}"
    end
end

class SongSelect < SystemCommon
    attr_accessor :song

    def initialize(song = 0, delta_time = 0)
	super(SONG_SELECT, delta_time)
	@song = song
    end

    def data_as_bytes
	data = ''
	data << @status
	data << @song
	return data
    end

    def to_s
	return super << "song sel #{number_to_s(@song)}"
    end
end

class TuneRequest < SystemCommon
    def initialize(delta_time = 0)
	super(TUNE_REQUEST, delta_time)
    end

    def data_as_bytes
	data = ''
	data << @status
	return data
    end

    def to_s
	return super << "tune req"
    end
end

class Realtime < Event
    def initialize(status, delta_time)
	super(status, delta_time)
	@is_realtime = true
    end

    def data_as_bytes
	data = ''
	data << @status
	return data
    end

    def to_s
	return super << "realtime #{number_to_s(@status)}"
    end
end

class Clock < Realtime
    def initialize(delta_time = 0)
	super(CLOCK, delta_time)
    end

    def to_s
	return super << "clock"
    end
end

class Start < Realtime
    def initialize(delta_time = 0)
	super(START, delta_time)
    end
    def to_s
	return super << "start"
    end
end

class Continue < Realtime
    def initialize(delta_time = 0)
	super(CONTINUE, delta_time)
    end
    def to_s
	return super << "continue"
    end
end

class Stop < Realtime
    def initialize(delta_time = 0)
	super(STOP, delta_time)
    end
    def to_s
	return super << "stop"
    end
end

class ActiveSense < Realtime
    def initialize(delta_time = 0)
	super(ACTIVE_SENSE, delta_time)
    end
    def to_s
	return super << "act sens"
    end
end

class SystemReset < Realtime
    def initialize(delta_time = 0)
	super(SYSTEM_RESET, delta_time)
    end
    def to_s
	return super << "sys reset"
    end
end

class MetaEvent < Event
    attr_reader :meta_type
    attr_accessor :data

    def initialize(meta_type, data = nil, delta_time = 0)
	super(META_EVENT, delta_time)
	@meta_type = meta_type
	@data = data
	@is_meta = true
    end

    def data_as_bytes
	data = ''
	data << @status
	data << @meta_type
	data << (@data ? Utils.as_var_len(@data.length) : 0)
	data << @data if @data
	return data
    end

    def to_s
	str = super()
	str << "meta #{number_to_s(@meta_type)} "
	# I know, I know...this isn't OO.
	case @meta_type
	when META_SEQ_NUM
	    str << "sequence number"
	when META_TEXT
	    str << "text: #{@data}"
	when META_COPYRIGHT
	    str << "copyright: #{@data}"
	when META_SEQ_NAME
	    str << "sequence or track name: #{@data}"
	when META_INSTRUMENT
	    str << "instrument name: #{@data}"
	when META_LYRIC
	    str << "lyric: #{@data}"
	when META_MARKER
	    str << "marker: #{@data}"
	when META_CUE
	    str << "cue point: #{@data}"
	when META_TRACK_END
	    str << "track end"
#  	when META_SET_TEMPO
#  	    str << "set tempo: #{@data}"
	when META_SMPTE
	    str << "smpte"
	when META_TIME_SIG
	    str << "time signature"
	when META_KEY_SIG
	    str << "key signature"
	when META_SEQ_SPECIF
	    str << "sequence specific"
	else
	    str << "(other)"
	end
	return str
    end
end

class Marker < MetaEvent
    def initialize(msg, delta_time = 0)
	super(META_MARKER, msg, delta_time)
    end
end

class Tempo < MetaEvent

    MICROSECS_PER_MINUTE = 1_000_000 * 60

    # Translates beats per minute to microseconds per quarter note (beat).
    def Tempo.bpm_to_mpq(bpm)
	return MICROSECS_PER_MINUTE / bpm
    end

    # Translates microseconds per quarter note (beat) to beats per minute.
    def Tempo.mpq_to_bpm(mpq)
	return MICROSECS_PER_MINUTE / mpq
    end

    def initialize(msecs_per_qnote, delta_time = 0)
	super(META_SET_TEMPO, msecs_per_qnote, delta_time)
    end

    def tempo
	return @data
    end

    def tempo=(val)
	@data = val
    end

    def data_as_bytes
	data = ''
	data << @status
	data << @meta_type
	data << 3
	data << ((@data >> 16) & 0xff)
	data << ((@data >> 8) & 0xff)
	data << (@data & 0xff)
	return data
    end

    def to_s
	"tempo #{@data} msecs per qnote (#{Tempo.mpq_to_bpm(@data)} bpm)"
    end
end
end