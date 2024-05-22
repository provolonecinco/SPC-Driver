.include "inc/spc.inc"
.include "inc/driver.inc"
;--------------------------------------
.segment "DRIVER" ; [Opcode ID], [Furnace Equivalent]
;--------------------------------------
.proc opSilence ; $01, (None)
; XX: Rows to wait
    JMP !process_channels::next
.endproc 
;--------------------------------------
.proc opKON ; $02, (None)
; XY: X = Octave, Y = Note Index    
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opKOFF ; $03, (None)
; Behaves differently based on release type
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opINST ; $04, (None)
; XX: Instrument Index
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opNOTE ; $05, (None)
; XY: X = Octave, Y = Note Index
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opPORTAMENTO ; $06, (F:$03)
; XX: Speed
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opVIBRATO ; $07, (F:$04)
; XY: X = Speed, Y = Depth (Max ±1 Semitone)
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opTREMOLO ; $08, (F:$07)
; XY: X = Speed, Y = Depth (Downward Only, max depth -60 VOL Steps)
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opPAN ; $09, (F:$80)
; XX: 00 = Left, 80 = Center, FF = Right
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opVSLIDE ; $0A, (F:$0A)
; XY: If X = 0, Slide down by Y every tick
;     If Y = 0, Slide up by X every tick
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opJUMP ; $0B, (F:$0B)
; XX: Order Number
    JMP !process_channels::read_opcode
.endproc
;-------------------------------------- 
.proc opNOISE ; $0C, (F:$11)
    JMP !process_channels::read_opcode
.endproc
;--------------------------------------
.proc opECHO ; $0D, (F:$12)
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opPMOD ; $0E, (F:$13)
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opNOISEFREQ ; $0F, (F:$1D)
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opLVOL ; $10, (F:$81)
    JMP !process_channels::read_opcode
; XX: 00-7F
.endproc 
;--------------------------------------
.proc opRVOL ; $11, (F:$82)
    JMP !process_channels::read_opcode
; XX: 00-7F
.endproc 
;--------------------------------------
.proc opTICK ; $12, (F:$CX)
    JMP !process_channels::read_opcode
; XX: 00-FF = Ticks/Second
.endproc 
;--------------------------------------
.proc opNSLIDEUP ; $13, (F:$E1)
    JMP !process_channels::read_opcode
; XY: X = Speed, Y = Semitones
.endproc 
;--------------------------------------
.proc opNSLIDEDOWN ; $14, (F:$E2)
    JMP !process_channels::read_opcode
; XY: X = Speed, Y = Semitones
.endproc 
;--------------------------------------
.proc opDETUNE ; $15, (F:$E5)
; XX: 00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opSTOP ; $16, (F:$FF)
    JMP !process_channels::done
.endproc
;--------------------------------------