;--------------------------------------
.setcpu "none"
.include "spc/inc/spc.inc"
.include "spc/inc/driver.inc"
;--------------------------------------
.segment "SPCZEROPAGE"  
.zeropage
; General Purpose ---------------------;  
r0:               .res 1
r1:               .res 1
r2:               .res 1
r3:               .res 1
r4:               .res 1
r5:               .res 1
r6:               .res 1
r7:               .res 1
transfer_addr:    .res 2
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
.segment "SPCIMAGE"
;--------------------------------------
spc_entrypoint:         ; SPC Init
    CLRP                ; Zeropage @ $00XX
    MOV A, #0           ; Zero out stack
clrstack:
    MOV !$0100 + X, A
    INC X
    BNE clrstack
    MOV X, #$FF         ; Stack pointer = $01FF
    MOV SP, X
    MOV X, #0           ; zero out DSP regs
    MOV Y, #0      
clrdsp:
    MOV DSPADDR, X  
    MOV DSPDATA, Y 
    INC X 
    BPL clrdsp
    dmov ESA,   #$FF    ; Echo addr = $FF00
    dmov MVOLL, #$7F    ; Master Volume (L/R) = $7F
    dmov MVOLR, #$7F
    dmov FLG,   #$20    ; mute off, echo write off, LFSR noise stop
    dmov DIR,   #>DIR_BASE    ; Sample Directory = $05XX
    MOV CONTROL, #$00   ; Disable IPL ROM and timers
.proc main
    MOV A, CPU0                 ; check for communication
    BPL main            
    MOV A, CPU0                 ; mask upper 4bits to determine index into jump table
    AND A, #$0F                 
    ASL A
    MOV X, A
    JMP [!jump_table + X]   
.endproc  
;--------------------------------------
jump_table:
    .word bulk_transfer, song_init, driver_update
;--------------------------------------
.proc bulk_transfer
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

    MOV A, CPU1                 ; get pointer
    MOV transfer_addr, A
    MOV A, CPU2
    MOV transfer_addr + 1, A

wait_index:
    MOV Y, CPU0                 ; Index (Should be 0)
    BNE wait_index
recieve:
    MOV A, CPU3                 ; check if we're done
    BMI done
    CMP Y, CPU0                 ; wait until index changes
    BNE recieve
    MOV A, CPU1                 ;get data
    MOV CPU0, Y                 ;send index
    MOV [transfer_addr] + Y, A  ;store data
    INC Y                       ;addr lsb
    BNE recieve
    INC transfer_addr + 1       ;addr msb
    BRA recieve
done:
    MOV CPU3, #$80              ; bit 7 signals end
    MOV CPU0, #0
    MOV CPU1, #0
    MOV CPU2, #0
    MOV CPU3, #0
    JMP !main
.endproc
;--------------------------------------
.proc song_init
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    MOV counter, #1 ; Process row immediately

    MOV A, !PAT_HEAD
    MOV pathead, A
    MOV frame, A
    MOV A, !PAT_HEAD + 1
    MOV pathead + 1, A
    MOV frame + 1, A
    
    MOV A, !NUM_CHAN
    MOV r0, A     ; prepare chptrs
    ASL r0
    MOV Y, #0
    MOV X, #0
:
    MOV A, [pathead] + Y
    MOV chptr + X, A
    INC Y
    INC X
    DEC r0
    BNE :-

    MOV A, !INST_HEAD
    MOV instptr, A
    
    MOV A, !INST_HEAD + 1
    MOV instptr + 1, A
   

    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc 
;--------------------------------------
op_table: ; opcode jump table
    .word 0, opWait, opKON, opKOFF, opINST, opNOTE, opPORTAMENTO, opVIBRATO, opTREMOLO, opPAN, opVSLIDE, opJUMP, opNOISE
    .word opECHO, opPMOD, opNOISEFREQ, opVOL, opTICK, opNSLIDEUP, opNSLIDEDOWN, opDETUNE, opSTOP, opCHANEND, opADVFRAME
;--------------------------------------
.proc driver_update ; unload shadow buffers
chnum = r2

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
    MOV r0, A
    INC X
    MOV A, chptr + X
    MOV r1, A
read_opcode:
    MOV Y, #0
    MOV A, [r0] + Y
    ASL A
    MOV X, A
    JMP [!op_table + X]
next_channel:
    MOV A, chnum  ; preserve pointer state
    ASL A
    MOV X, A
    MOV A, r0
    MOV chptr + X, A
    INC X
    MOV A, r1
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
    INCW r0
    MOV A, [r0] + Y
    MOV X, r2
    MOV chwait + X, A
    INCW r0
    JMP !driver_update::next_channel
.endproc 
;--------------------------------------
.proc opKON ; $02, (None)
    INCW r0
    MOV X, r2
    SETC 
    MOV A, #0
:
    ROL A
    DEC X
    BPL :-
    EOR A, sKON
    MOV sKON, A

get_note:
    MOV A, [r0] + Y
    MOV Y, A
    MOV X, r2
    MOV A, !freq_table + Y
    MOV sPITCHL + X, A
    INC Y
    MOV A, !freq_table + Y
    MOV sPITCHH + X, A
    INCW r0
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
    INCW r0
    MOV A, [r0] + Y       ; get pointer to inst data
    ASL A
    MOV Y, A
    MOV A, [instptr] + Y
    MOV r3, A
    INC Y
    MOV A, [instptr] + Y
    MOV r4, A

    MOV X, r2
    MOV Y, #0
    MOV A, [r3] + Y
    MOV sSRCN + X, A
    INC Y
    MOV A, [r3] + Y
    MOV sADSR1 + X, A
    INC Y
    MOV A, [r3] + Y
    MOV sADSR2 + X, A
    INC Y    
    MOV A, [r3] + Y
    MOV sGAIN + X, A
    INCW r0
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
    INCW r0
    MOV A, [r0] + Y   
    MOV X, A

    MOV A, !NUM_CHAN   
    MOV r3, A
    ASL r3
    MOV r4, #0
    CLRC
    MOV A, #0
:
    DEC X
    BMI done
    ADDW YA, r3
    JMP !:-
done:
    CLRC
    ADDW YA, pathead
    MOVW frame, YA
writeptrs:
    MOV A, !NUM_CHAN
    MOV r3, A     ; prepare chptrs
    ASL r3
    MOV Y, #0
    MOV X, #0
:
    MOV A, [frame] + Y
    MOV chptr + X, A
    INC Y
    INC X
    DEC r3
    BNE :-

    JMP !driver_update::done
.endproc
;-------------------------------------- 
.proc opNOISE ; $0C, (F:$11)
    INCW r0
    JMP !driver_update::read_opcode
.endproc
;--------------------------------------
.proc opECHO ; $0D, (F:$12)
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opPMOD ; $0E, (F:$13)
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNOISEFREQ ; $0F, (F:$1D)
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opVOL ; $10, (F:$81, $82)
; XX: 00-7F
    INCW r0
    MOV A, [r0] + Y
    MOV X, r2       
    MOV sLVOL + X, A
    INCW r0
    MOV A, [r0] + Y       
    MOV sRVOL + X, A
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opTICK ; $11, (F:$CX)
; XX: 00-FF = Ticks/Second
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEUP ; $12, (F:$E1)
; XY: X = Speed, Y = Semitones
    INCW r0
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opNSLIDEDOWN ; $13, (F:$E2)
; XY: X = Speed, Y = Semitones
    INCW r0
    INCW r0
    JMP !driver_update::read_opcode
.endproc 
;--------------------------------------
.proc opDETUNE ; $14, (F:$E5)
; XX: 00 = -1 Semitone, 80 = Normal, FF = Near +1 Semitone
    INCW r0
    INCW r0
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
    MOV r3, A
    MOV r4, #0
    CLRC
    MOVW YA, frame
    ADDW YA, r3
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
.include "spc/songdata.inc"