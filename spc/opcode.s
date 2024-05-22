.setcpu "none"
.include "inc/spc.inc"
.include "inc/opcode.inc"
.include "inc/driver.inc"
;--------------------------------------
.segment "DRIVER" ; [Opcode ID], [Furnace Equivalent]
;--------------------------------------
op_tablelo: ; opcode jump table
    .byte 0, <opWait, <opKON, <opKOFF, <opINST, <opNOTE, <opPORTAMENTO, <opVIBRATO, <opTREMOLO, <opPAN, <opVSLIDE, <opJUMP
    .byte <opNOISE, <opECHO, <opPMOD, <opNOISEFREQ, <opVOL, <opTICK, <opNSLIDEUP, <opNSLIDEDOWN, <opDETUNE, <opSTOP
op_tablehi:
    .byte 0, >opWait, >opKON, >opKOFF, >opINST, >opNOTE, >opPORTAMENTO, >opVIBRATO, >opTREMOLO, >opPAN, >opVSLIDE, >opJUMP
    .byte >opNOISE, >opECHO, >opPMOD, >opNOISEFREQ, >opVOL, >opTICK, >opNSLIDEUP, >opNSLIDEDOWN, >opDETUNE, >opSTOP
;--------------------------------------
.proc opWait ; $01, (None)
; XX: Rows to wait
    POP X
    MOV Y, #0 
    MOV A, [patternptr] + Y
    MOV chwait + X, A
    INCW patternptr
    JMP !process_channels::next
.endproc 
;--------------------------------------
.proc opKON ; $02, (None)
    POP X    
    MOV A, X
    MOV Y, A
    MOV A, #0
    SETC
:
    ROL A
    DEC Y
    BPL :-
    OR A, sKON    ; buffer KON
    MOV sKON, A
get_note: 
    MOV Y, #0
    MOV A, [patternptr] + Y
    MOV Y, A
    MOV A, !freq_table + Y
    MOV sPITCHL + X, A
    INC Y
    MOV A, !freq_table + Y
    MOV sPITCHH + X, A

    INCW patternptr
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
    POP X
    MOV Y, #0
    MOV A, [patternptr] + Y     ; next byte, inst index
    ASL A
    MOV Y, A
    
    MOV A, [instptr] + Y ; ptr lsb
    MOV tmp0, A
    INC Y
    MOV A, [instptr] + Y ; ptr msb
    MOV tmp1, A
   
    MOV Y, #0
load_inst:
    MOV A, [tmp0] + Y
    MOV sSRCN + X, A
    INC Y
    MOV A, [tmp0] + Y
    MOV sADSR1 + X, A
    INC Y
    MOV A, [tmp0] + Y
    MOV sADSR2 + X, A
    INC Y
    MOV A, [tmp0] + Y
    MOV sGAIN, A

    INCW patternptr
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
    POP X
    MOV Y, #0
    MOV frame, Y
    MOV A, [patternptr] + Y    ; frame # 
    BEQ done
    MOV Y, A
    CLRC
:
    ADC frame, !0501
    DEC Y
    BNE :-  
done:
    INCW patternptr
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
.proc opVOL ; $10, (F:$81, $82)
; XX: 00-7F
    POP X
    MOV Y, #0 
    MOV A, [patternptr] + Y  ; Left Channel
    MOV sVOLL + X, A
    INCW patternptr
    MOV A, [patternptr] + Y ; Right Channel
    MOV sVOLR + X, A
    INCW patternptr
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opTICK ; $11, (F:$CX)
; XX: 00-FF = Ticks/Second

    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEUP ; $12, (F:$E1)
; XY: X = Speed, Y = Semitones
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEDOWN ; $13, (F:$E2)
; XY: X = Speed, Y = Semitones
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opDETUNE ; $14, (F:$E5)
; XX: 00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone
    JMP !process_channels::read_opcode
.endproc 
;--------------------------------------
.proc opSTOP ; $15, (F:$FF)
    JMP !process_channels::done
.endproc
;--------------------------------------