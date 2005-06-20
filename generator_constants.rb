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
# Constants to be used in tracks
#

module MidiGenerator

	# Channels
	Drum_Channel = 10
	
	# Note numbers
		#Octave 1
	Af0 = 8
	A0 = 9
	As0 = Bf0 = 10
	B0 = 11
	C0 = 12
	Cs0 = Df0 = 13
	D0 = 14
	Ds0 = Ef0 = 15
	E0 = 16
	F0 = 17
	Fs0 = Gf0 = 18
	G0 = 19
	Gs0 = Af1 = 20
		#Octave 1
	A1 = 21
	As1 = Bf1 = 22
	B1 = 23
	C1 = 24
	Cs1 = Df1 = 25
	D1 = 26
	Ds1 = Ef1 = 27
	E1 = 28
	F1 = 29
	Fs1 = Gf1 = 30
	G1 = 31
	Gs1 = Af2 = 32
		#Octave 2
	A2 = 33
	As2 = Bf2 = 34
	B2 = 35
	C2 = 36
	Cs2 = Df2 = 37
	D2 = 38
	Ds2 = Ef2 = 39
	E2 = 40
	F2 = 41
	Fs2 = Gf2 = 42
	G2 = 43
	Gs2 = Af3 = 44
		#Octave 3
	A3 = 45
	As3 = Bf3 = 46
	B3 = 47
	C3 = 48
	Cs3 = Df3 = 49
	D3 = 50
	Ds3 = Ef3 = 51
	E3 = 52
	F3 = 53
	Fs3 = Gf3 = 54
	G3 = 55
	Gs3 = Af4 = 56
		#Octave 4
	A4 = 57
	As4 = Bf4 = 58
	B4 = 59
	C4 = 60
	Cs4 = Df4 = 61
	D4 = 62
	Ds4 = Ef4 = 63
	E4 = 64
	F4 = 65
	Fs4 = Gf4 = 66
	G4 = 67
	Gs4 = Af5 = 68
		#Octave 5
	A5 = 69
	As5 = Bf5 = 70
	B5 = 71
	C5 = 72
	Cs5 = Df5 = 73
	D5 = 74
	Ds5 = Ef5 = 75
	E5 = 76
	F5 = 77
	Fs5 = Gf5 = 78
	G5 = 79
	Gs5 = Af6 = 80
		#Octave 6
	A6 = 81
	As6 = Bf6 = 82
	B6 = 83
	C6 = 84
	Cs6 = Df6 = 85
	D6 = 86
	Ds6 = Ef6 = 87
	E6 = 88
	F6 = 89
	Fs6 = Gf6 = 90
	G6 = 91
	Gs6 = Af7 = 92
		#Octave 7
	A7 = 93
	As7 = Bf7 = 94
	B7 = 95
	C7 = 96
	Cs7 = Df7 = 97
	D7 = 98
	Ds7 = Ef7 = 99
	E7 = 100
	F7 = 101
	Fs7 = Gf7 = 102
	G7 = 103
	Gs7 = Af8 = 104
		#Octave 8
	A8 = 105
	As8 = Bf8 = 106
	B8 = 107
	C8 = 108
	Cs8 = Df8 = 109
	D8 = 110
	Ds8 = Ef8 = 111
	E8 = 112
	F8 = 113
	Fs8 = Gf8 = 114
	G8 = 115
	Gs8 = Af9 = 116
	
	# Note lengths
	Whole = 'whole'
	Half = 'half'
	Quarter = 'quarter'
	Eighth = 'eighth'
	Sixteenth = 'sixteenth'
	Thirtysecond = 'thirty second'
	Sixtyfourth = 'sixty fourth'
		#Dotted
	Dotted_Whole = 'dotted whole'
	Dotted_Half = 'dotted half'
	Dotted_Quarter = 'dotted quarter'
	Dotted_Eighth = 'dotted eighth'
	Dotted_Sixteenth = 'dotted sixteenth'
	Dotted_Thirtysecond = 'dotted thirty second'
	Dotted_Sixtyfourth = 'dotted sixty fourth'
		#Triplet
	Whole_Triplet = 'whole triplet'
	Half_Triplet= 'half triplet'
	Quarter_Triplet = 'quarter triplet'
	Eighth_Triplet = 'eighth triplet'
	Sixteenth_Triplet = 'sixteenth triplet'
	Thirtysecond_Triplet = 'thirty second triplet'
	Sixtyfourth_Triplet = 'sixty fourth triplet'
		#Dotted Triplet
	Dotted_Whole_Triplet = 'dotted whole triplet'
	Dotted_Half_Triplet = 'dotted half triplet'
	Dotted_Quarter_Triplet = 'dotted quarter triplet'
	Dotted_Eighth_Triplet = 'dotted eighth triplet'
	Dotted_Sixteenth_Triplet = 'dotted sixteenth triplet'
	Dotted_Thirtysecond_Triplet = 'dotted thirty second triplet'
	Dotted_Sixtyfourth_Triplet = 'dotted sixty fourth triplet'
	
	# General MIDI programs
		#PIANO                           
	Acoustic_Grand = 0
	Bright_Acoustic = 1
	Electric_Grand = 2
	Honky_Tonk = 3
	Electric_Piano_1 = 4
	Electric_Piano_2 = 5
	Harpsichord = 6
	Clavinet = 7
		#CHROMATIC PERCUSSION
	Celesta = 8
	Glockenspiel = 9
	Music_Box = 10
	Vibraphone = 11
	Marimba = 12
	Xylophone = 13
	Tubular_Bells = 14
	Dulcimer = 15
		#ORGAN                          
	Drawbar_Organ = 16
	Percussive_Organ = 17
	Rock_Organ = 18
	Church_Organ = 19
	Reed_Organ = 20
	Accoridan = 21
	Harmonica = 22
	Tango_Accordian = 23
		#GUITAR
	Nylon_String_Guitar = 24
	Steel_String_Guitar = 25
	Electric_Jazz_Guitar = 26
	Electric_Clean_Guitar = 27
	Electric_Muted_Guitar = 28
	Overdriven_Guitar = 29
	Distortion_Guitar = 30
	Guitar_Harmonics = 31
		#BASS
	Acoustic_Bass = 32
	Electric_Bass_Finger = 33
	Electric_Bass_Pick = 34
	Fretless_Bass = 35
	Slap_Bass_1 = 36
	Slap_Bass_2 = 37
	Synth_Bass_1 = 38
	Synth_Bass_2 = 39
		#SOLO_STRINGS
	Violin = 40
	Viola = 41
	Cello = 42
	Contrabass = 43
	Tremolo_Strings = 44
	Pizzicato_Strings = 45
	Orchestral_Strings = 46
	Timpani = 47
		#ENSEMBLE
	String_Ensemble_1 = 48
	String_Ensemble_2 = 49
	SynthStrings_1 = 50
	SynthStrings_2 = 51
	Choir_Aahs = 52
	Voice_Oohs = 53
	Synth_Voice = 54
	Orchestra_Hit = 55
		#BRASS
	Trumpet = 56
	Trombone = 57
	Tuba = 58
	Muted_Trumpet = 59
	French_Horn = 60
	Brass_Section = 61
	SynthBrass_1 = 62
	SynthBrass_2 = 63
		#REED
	Soprano_Sax = 64
	Alto_Sax = 65
	Tenor_Sax = 66
	Baritone_Sax = 67
	Oboe = 68
	English_Horn = 69
	Bassoon = 70
	Clarinet = 71
		#PIPE
	Piccolo = 72
	Flute = 73
	Recorder = 74
	Pan_Flute = 75
	Blown_Bottle = 76
	Skakuhachi = 77
	Whistle = 78
	Ocarina = 79
		#SYNTH_LEAD
	Lead_1= 80
	Lead_2 = 81
	Lead_3 = 82
	Lead_4 = 83
	Lead_5 = 84
	Lead_6 = 85
	Lead_7 = 86
	Lead_8 = 87
		#SYNTH_PAD
	Pad_1 = 88
	Pad_2 = 89
	Pad_3 = 90
	Pad_4 = 91
	Pad_5 = 92
	Pad_6 = 93
	Pad_7 = 94
	Pad_8 = 95
		#SYNTH_EFFECTS
	FX_1 = 96
	FX_2 = 97
	FX_3 = 98
	FX_4 = 99
	FX_5 = 100
	FX_6 = 101
	FX_7 = 102
	FX_8 = 103
		#ETHNIC
	Sitar = 104
	Banjo = 105
	Shamisen = 106
	Koto = 107
	Kalimba = 108
	Bagpipe = 109
	Fiddle = 110
	Shanai = 111
		#PERCUSSIVE
	Tinkle_Bell = 112
	Agogo = 113
	Steel_Drums = 114
	Woodblock = 115
	Taiko_Drum = 116
	Melodic_Tom = 117
	Synth_Drum = 118
	Reverse_Cymbal = 119
		#SOUND_EFFECTS
	Guitar_Fret_Noise = 120
	Breath_Noise = 121
	Seashore = 122
	Bird_Tweet = 123
	Telephone_Ring = 124
	Helicopter = 125
	Applause = 126
	Gunshot = 127
	
	# Drum note numbers
	Acoustic_Bass_Drum = 35
	Bass_Drum_1 = 36
	Side_Stick = 37
	Acoustic_Snare = 38
	Hand_Clap = 39
	Electric_Snare = 40
	Low_Floor_Tom = 41
	Closed_Hi_Hat = 42
	High_Floor_Tom = 43
	Pedal_Hi_Hat = 44
	Low_Tom = 45
	Open_Hi_Hat = 46
	Low_Mid_Tom = 47
	Hi_Mid_Tom = 48
	Crash_Cymbal_1 = 49
	High_Tom = 50
	Ride_Cymbal_1 = 51
	Chinese_Cymbal = 52
	Ride_Bell = 53
	Tambourine = 54
	Splash_Cymbal = 55
	Cowbell = 56
	Crash_Cymbal_2 = 57
	Vibraslap = 58
	Ride_Cymbal_2 = 59
	Hi_Bongo = 60
	Low_Bongo = 61
	Mute_Hi_Conga = 62
	Open_Hi_Conga = 63
	Low_Conga = 64
	High_Timbale = 65
	Low_Timbale = 66
	High_Agogo = 67
	Low_Agogo = 68
	Cabasa = 69
	Maracas = 70
	Short_Whistle = 71
	Long_Whistle = 72
	Short_Guiro = 73
	Long_Guiro = 74
	Claves = 75
	Hi_Wood_Block = 76
	Low_Wood_Block = 77
	Mute_Cuica = 78
	Open_Cuica = 79
	Mute_Triangle = 80
	Open_Triangle = 81
	
	# note named parameters
	Velocity = :velocity
	Transpose = :transpose
	
	# start_track parameters
	Channel = :channel
	Name = :name
	
	# drum parameters
	Length = :length
	
end