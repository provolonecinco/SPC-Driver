.setcpu "none"
.include "inc/spc.inc"
.include "inc/driver.inc"
.segment "ZEROPAGE"
; Driver-Specific --------------------;
frame:          .res 2 ; index into pattern table
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
    .word 0, opWait, opKON, opKOFF, opINST, opNOTE, opPORTAMENTO, opVIBRATO, opTREMOLO, opPAN, opVSLIDE, opJUMP, opNOISE
    .word opECHO, opPMOD, opNOISEFREQ, opVOL, opTICK, opNSLIDEUP, opNSLIDEDOWN, opDETUNE, opSTOP, opCHANEND, opADVFRAME
;--------------------------------------
.proc driver_update ; unload shadow buffers
chnum = tmp2

    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    DEC counter
    BNE write
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
    MOV Y, #0
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
    CMP A, !NUM_CHAN
    BEQ done

    INC chnum
    JMP !check_channel
done:
    MOV A, !SONGSPEED      ; Reset speed counter
    MOV counter, A
; Write DSP Registers --
write:   
    MOV A, sKON
    BEQ :+
    CALL !dspwrite
:

    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc
;--------------------------------------
.proc dspwrite
    MOV A, #0
    MOV X, #0
write:
    MOV DSPADDR, A
    MOV Y, sLVOL + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sRVOL + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sPITCHL + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sPITCHH + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sSRCN + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sADSR1 + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sADSR2 + X
    MOV DSPDATA, Y
    INC A
    MOV DSPADDR, A
    MOV Y, sGAIN + X
    MOV DSPDATA, Y

    ADC A, #$10    ; to next multiple of $10
    AND A, #$F0
    INC X
    CMP X, #8
    BNE write
    dmov (KON), sKON
    MOV sKON, #0
    RET 
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
    EOR A, sKON
    MOV sKON, A

get_note:
    MOV A, [tmp0] + Y
    MOV Y, A
    MOV X, tmp2
    MOV A, !freq_table + Y
    MOV sPITCHL + X, A
    INC Y
    MOV A, !freq_table + Y
    MOV sPITCHH + X, A
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

    MOV X, tmp2
    MOV Y, #0
    MOV A, [tmp3] + Y
    MOV sSRCN + X, A
    INC Y
    MOV A, [tmp3] + Y
    MOV sADSR1 + X, A
    INC Y
    MOV A, [tmp3] + Y
    MOV sADSR2 + X, A
    INC Y    
    MOV A, [tmp3] + Y
    MOV sGAIN + X, A
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
; XX: Order/Frame Number
    INCW tmp0
    MOV A, [tmp0] + Y   
    MOV X, A

    MOV A, !NUM_CHAN   
    MOV tmp3, A
    ASL tmp3
    MOV tmp4, #0
    CLRC
    MOV A, #0
:
    DEC X
    BMI done
    ADDW YA, tmp3
    JMP !:-
done:
    CLRC
    ADDW YA, pathead
    MOVW frame, YA
writeptrs:
    MOV A, !NUM_CHAN
    MOV tmp3, A     ; prepare chptrs
    ASL tmp3
    MOV Y, #0
    MOV X, #0
:
    MOV A, [frame] + Y
    MOV chptr + X, A
    INC Y
    INC X
    DEC tmp3
    BNE :-

    JMP !driver_update::done
.endproc
;-------------------------------------- 
.proc opNOISE ; $0C, (F:$11)
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc
;--------------------------------------
.proc opECHO ; $0D, (F:$12)
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opPMOD ; $0E, (F:$13)
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNOISEFREQ ; $0F, (F:$1D)
    INCW tmp0
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
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEUP ; $12, (F:$E1)
; XY: X = Speed, Y = Semitones
    INCW tmp0
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEDOWN ; $13, (F:$E2)
; XY: X = Speed, Y = Semitones
    INCW tmp0
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opDETUNE ; $14, (F:$E5)
; XX: 00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone
    INCW tmp0
    INCW tmp0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opSTOP ; $15, (F:$FF)
    JMP !driver_update::done
.endproc
;--------------------------------------
.proc opCHANEND ; $16, (None)
    JMP !driver_update::next_channel
.endproc 
;--------------------------------------
.proc opADVFRAME ; $17, (None) 
    MOV A, !NUM_CHAN   
    ASL A
    MOV tmp3, A
    MOV tmp4, #0
    CLRC
    MOVW YA, frame
    ADDW YA, tmp3
    MOVW frame, YA
    JMP !opJUMP::writeptrs
.endproc
;-------------------------------------- 
freq_table: ;tuned to B+21c, pitchgen.py
    .word $021E,  $023F,  $0261,  $0285,  $02AC,  $02D4,  $02FF,  $032D,  $035D,  $0390,  $03C7,  $0400 ; -2 Octave
    .word $043D,  $047E,  $04C2,  $050A,  $0557,  $05A8,  $05FE,  $065A,  $06BA,  $0721,  $078D,  $0800 ; -1 Octave
    .word $087A,  $08FB,  $0984,  $0A15,  $0AAE,  $0B51,  $0BFD,  $0CB3,  $0D75,  $0E41,  $0F1A,  $1000 ; native 16khz
    .word $10F4,  $11F6,  $1307,  $1429,  $155C,  $16A1,  $17FA,  $1967,  $1AE9,  $1C83,  $1E35,  $2000 ; +1 Octave
    .word $21E8,  $23EC,  $260F,  $2852,  $2AB8,  $2D42,  $2FF3,  $32CD,  $35D3,  $3906,  $3C6A,  $4000 ; +2 Octave
;--------------------------------------
.include "songdata.inc"