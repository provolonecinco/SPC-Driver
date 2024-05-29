.setcpu "none"
.include "inc/spc.inc"
.include "inc/driver.inc"
.segment "ZEROPAGE"
; Driver-Specific --------------------;
frame:          .res 1 ; index into pattern table
pathead:        .res 2
patptr:         .res 2 ; pathead + frame + channel
instptr:        .res 2
tick:           .res 1
counter:        .res 1 ; Engine speed, ticks down (0=update)
chwait:         .res 8 ; Silence/Wait opcode counter
; DSP Buffer ------------------------ ;
sSRCN:          .res 8
sADSR1:         .res 8
sADSR2:         .res 8
sGAIN:          .res 8
sPITCHL:        .res 8
sPITCHH:        .res 8
sLVOL:          .res 8
sRVOL:          .res 8
sKON:           .res 1
sKOFF:          .res 1
;--------------------------------------
.segment "DRIVER"
;--------------------------------------
op_table: ; opcode jump table
    .word 0, opWait, opKON, opKOFF, opINST, opNOTE, opPORTAMENTO, opVIBRATO, opTREMOLO, opPAN, opVSLIDE, opJUMP
    .word opNOISE, opECHO, opPMOD, opNOISEFREQ, opVOL, opTICK, opNSLIDEUP, opNSLIDEDOWN, opDETUNE, opSTOP
;--------------------------------------
.proc driver_update ; unload shadow buffers
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    DEC counter
    BNE dspwrite
; Process channels -----
    INC tick
    JMP !opWait
read_opcode:
next:
done:
    MOV A, !$0500           ; Reset speed counter
    MOV counter, A

; Write DSP Registers --
dspwrite:

    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc
;--------------------------------------
.proc opWait ; $01, (None)
; XX: Rows to wait
    INC chwait
    INC chwait + 1 
    INC chwait + 2
    INC chwait + 3
    INC chwait + 4
    INC chwait + 5
    INC chwait + 6
    INC chwait + 7
    JMP !driver_update::next
.endproc 
;--------------------------------------
.proc opKON ; $02, (None)
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opKOFF ; $03, (None)
; Behaves differently based on release type
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opINST ; $04, (None)
; XX: Instrument Index
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNOTE ; $05, (None)
; XY: X = Octave, Y = Note Index
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opPORTAMENTO ; $06, (F:$03)
; XX: Speed
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opVIBRATO ; $07, (F:$04)
; XY: X = Speed, Y = Depth (Max ±1 Semitone)
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opTREMOLO ; $08, (F:$07)
; XY: X = Speed, Y = Depth (Downward Only, max depth -60 VOL Steps)
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opPAN ; $09, (F:$80)
; XX: 00 = Left, 80 = Center, FF = Right
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opVSLIDE ; $0A, (F:$0A)
; XY: If X = 0, Slide down by Y every tick
;     If Y = 0, Slide up by X every tick
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opJUMP ; $0B, (F:$0B)
; XX: Order Number
    JMP !driver_update::read_opcode
.endproc
;-------------------------------------- 
.proc opNOISE ; $0C, (F:$11)
    JMP !driver_update::read_opcode
.endproc
;--------------------------------------
.proc opECHO ; $0D, (F:$12)
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opPMOD ; $0E, (F:$13)
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNOISEFREQ ; $0F, (F:$1D)
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opVOL ; $10, (F:$81, $82)
; XX: 00-7F
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opTICK ; $11, (F:$CX)
; XX: 00-FF = Ticks/Second
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEUP ; $12, (F:$E1)
; XY: X = Speed, Y = Semitones
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEDOWN ; $13, (F:$E2)
; XY: X = Speed, Y = Semitones
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opDETUNE ; $14, (F:$E5)
; XX: 00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opSTOP ; $15, (F:$FF)
    JMP !driver_update::done
.endproc
;--------------------------------------

.include "songdata.inc"