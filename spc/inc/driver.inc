.global play_sample, play_song, driver_update

; Effects --------------------------------------
;$00.XX: Silence
;     • XX = Rows to wait
;$00.XY: Key On
;    • X = Octave, Y = Note Index    
;$00: Key Off
;$00.XX: Set Instrument
;     • XX = Instrument Index
;$00.XX: Pitch (Change note without retrigger)
;     • X = Octave, Y = Note index
;$00: Pattern End
;
;$00: Software Release
;
; Furnace Effects to Support/Map ---------------
;
;$03.XX: Portamento 
;            XX = Speed
;$04.XY: Vibrato
;            X = Speed, Y = Depth (Max ±1 Semitone)
;$07.XY: Tremolo
;            X = Speed, Y = Depth (Downward Only, max depth -60 VOL Steps)
;$80.XX: Set panning (linear)
;            (00 = Left, 80 = Center, FF = Right)
;$0A.XY: Volume Slide
;            If X = 0, Slide down by Y every tick
;            If Y = 0, Slide up by X every tick
;$0B.XX: Jump to order
;            XX = Order Number
;$11.XX: Noise Enable
;$12.XX: Echo Enable (Channel)
;$13.XX: PMOD Enable
;$1D.XX: Noise Frequency
;$81.XX: Left Channel Volume
;            XX = 0-7F
;$82.XX: Right Channel Volume
;            XX = 0-7F
;$CX.XX: Tick Rate
;            000-3FF = Ticks/Second
;$E1.XY: Slide Note Up
;            X = Speed, Y = Semitones
;$E2.XY: Slide Note Down 
;            X = Speed, Y = Semitones
;$E5.XX: Detune
;            (00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone)
;$FF.XX: Stop Playback

