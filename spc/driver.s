.setcpu "none"
.include "inc/spc.inc"
.include "inc/driver.inc"
.segment "ZEROPAGE"
; Driver-Specific --------------------;
frame:          .res 1 ; index into pattern table
pathead:        .res 2
chptr:          .res 16 ; holds pattern state per channel
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
    .word opNOISE, opECHO, opPMOD, opNOISEFREQ, opVOL;, opTICK, opNSLIDEUP, opNSLIDEDOWN, opDETUNE, opSTOP
;--------------------------------------
.proc driver_update ; unload shadow buffers
chnum = tmp2

    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    DEC counter
    BNE dspwrite
; Process channels -----
    MOV chnum, #0
check_channel:
    MOV X, chnum
    MOV A, chwait + X
    BEQ set_pointer
    DEC chwait + X
    JMP !silence
    
set_pointer:
    MOV A, chnum
    ASL A
    MOV X, A
    MOV A, chptr + X
    MOV tmp0, A
    INC X
    MOV A, chptr + X
    MOV tmp1, A
read_opcode:
    MOV A, [tmp0] + Y
    ASL A
    MOV X, A
    JMP [!op_table + X]
next_channel:
    MOV A, chnum  ; preserve pointer state
    ASL A
    MOV X, A
    MOV A, tmp0
    MOV chptr + X, A
    INC X
    MOV A, tmp1
    MOV chptr + X, A
silence:
    MOV A, chnum
    INC A                   ; check if done
    CMP A, !$0501
    BEQ done

    INC chnum
    JMP !check_channel
done:
    MOV A, !$0500           ; Reset speed counter
    MOV counter, A
; Write DSP Registers --
dspwrite:   
    MOV A, sKON
    BEQ :+
    dmov (SRCN|CH0), sSRCN + 0
    dmov (VOLL|CH0), sLVOL + 0
    dmov (VOLR|CH0), sRVOL + 0
    dmov (ADSR1|CH0), sADSR1 + 0
    dmov (ADSR2|CH0), sADSR2 + 0
    dmov (PITCHL|CH0), sPITCHL + 0
    dmov (PITCHH|CH0), sPITCHH + 0
    dmov (KON|CH0), sKON + 0
    NOP
    NOP
    NOP
    MOV sKON, #0
:

    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc
;--------------------------------------
.proc opWait ; $01, (None)
; XX: Rows to wait
    INCW tmp0
    MOV A, [tmp0] + Y
    MOV X, tmp2
    MOV chwait + X, A
    INCW tmp0
    JMP !driver_update::next_channel
.endproc 
;--------------------------------------
.proc opKON ; $02, (None)
    INCW tmp0
    MOV X, tmp2
    SETC 
    MOV A, #0
:
    ROL A
    DEC X
    BPL :-
    OR A, sKON
    MOV sKON, A

get_note:
    MOV A, [tmp0] + Y
    MOV X, A
    MOV A, !freq_table + X
    MOV sPITCHL, A
    INC X
    MOV A, !freq_table + X
    MOV sPITCHH, A
    INCW tmp0
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
; note -- this will break if instrument index is anything other than 0?    
    INCW tmp0
    MOV A, [tmp0] + Y       ; get pointer to inst data
    ASL A
    MOV Y, A
    MOV A, [instptr] + Y
    MOV tmp3, A
    INC Y
    MOV A, [instptr] + Y
    MOV tmp4, A

    MOV Y, #0
    MOV A, [tmp3] + Y
    MOV sSRCN, A
    INC Y
    MOV A, [tmp3] + Y
    MOV sADSR1, A
    INC Y
    MOV A, [tmp3] + Y
    MOV sADSR2, A
    INC Y    
    MOV A, [tmp3] + Y
    MOV sGAIN, A
    INCW tmp0
    MOV Y, #0
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
    INCW tmp0
    MOV A, [tmp0] + Y
    MOV chptr, pathead
    MOV chptr + 1, pathead + 1
    JMP !driver_update::done
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
    INCW tmp0
    MOV A, [tmp0] + Y
    MOV X, tmp2       
    MOV sLVOL + X, A
    INCW tmp0
    MOV A, [tmp0] + Y       
    MOV sRVOL + X, A
    INCW tmp0
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