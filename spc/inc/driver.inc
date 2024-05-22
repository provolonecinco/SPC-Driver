.global play_sample, song_init, driver_update

; Effects --------------------------------------
;$00.XX: Silence
;     • XX = Rows to wait
opSilence = $01
;$00.XY: Key On
;    • X = Octave, Y = Note Index    
opKON = $02
;$00: Key Off (Behaves differently based on release type)
opKOFF = $03
;$00.XX: Set Instrument
;     • XX = Instrument Index
opINST = $04
;$00.XX: Pitch (Change note without retrigger)
;     • X = Octave, Y = Note index
opNOTE = $05
; Furnace Effects to Support/Map ---------------
;
;$03.XX: Portamento 
;            XX = Speed
opPORTAMENTO = $06
;$04.XY: Vibrato
;            X = Speed, Y = Depth (Max ±1 Semitone)
opVIBRATO = $07
;$07.XY: Tremolo
;            X = Speed, Y = Depth (Downward Only, max depth -60 VOL Steps)
opTREMOLO = $08
;$80.XX: Set panning (linear)
;            (00 = Left, 80 = Center, FF = Right)
opPAN = $09
;$0A.XY: Volume Slide
;            If X = 0, Slide down by Y every tick
;            If Y = 0, Slide up by X every tick
opVSLIDE = $0A
;$0B.XX: Jump to order
;            XX = Order Number
opJUMP = $0B
;$11.XX: Noise Enable
opNOISE = $0C
;$12.XX: Echo Enable (Channel)
opECHO = $0D
;$13.XX: PMOD Enable
opPMOD = $0E
;$1D.XX: Noise Frequency
opNOISEFREQ = $0F
;$81.XX: Left Channel Volume
;            XX = 0-7F
opLVOL = $10
;$82.XX: Right Channel Volume
;            XX = 0-7F
opRVOL = $11
;$CX.XX: Tick Rate
;            000-3FF = Ticks/Second
opTICK = $12
;$E1.XY: Slide Note Up
;            X = Speed, Y = Semitones
opNSLIDEUP = $13
;$E2.XY: Slide Note Down 
;            X = Speed, Y = Semitones
opNSLIDEDOWN = $14
;$E5.XX: Detune
;            (00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone)
opDETUNE = $15
;$FF.XX: Stop Playback
opSTOP = $16
