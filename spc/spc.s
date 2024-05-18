;--------------------------------------
.setcpu "none"
.include "inc/spc.inc"
.include "inc/transfer.inc"
;--------------------------------------
.segment "ZEROPAGE"  
; General Purpose ------------------- ;  
tmp0:               .res 1
tmp1:               .res 1
tmp2:               .res 1
tmp3:               .res 1
buf_T0DIV:          .res 1
buf_CONTROL:        .res 1
buf_CPU0:           .res 1
buf_CPU1:           .res 1
buf_CPU2:           .res 1
buf_CPU3:           .res 1
; DSP Buffer ------------------------ ;
buf_CLVOL:          .res NUM_CHANNELS
buf_CRVOL:          .res NUM_CHANNELS
buf_CFREQLO:        .res NUM_CHANNELS
buf_CFREQHI:        .res NUM_CHANNELS
buf_LVOL:           .res NUM_CHANNELS
buf_RVOL:           .res NUM_CHANNELS
buf_LECHOVOL:       .res NUM_CHANNELS
buf_RECHOVOL:       .res NUM_CHANNELS
buf_KON:            .res NUM_CHANNELS
buf_KOFF:           .res NUM_CHANNELS
; Driver-Specific --------------------;
patternptr:         .res 2
;--------------------------------------
.segment "SPCDRIVER"
;--------------------------------------
spc_entrypoint:
    JMP !driver_init
main:
    MOV A, CPU0                 ; check for communication
    BMI :+

    BBC buf_CONTROL.0, main     ; don't check timer unless enabled
    MOV A, T0OUT                
    BEQ main

    CLR1 buf_CPU3.(SPC_BUSY)    ; Signal SPC is not available for communication
    MOV A, buf_CPU3
    MOV CPU3, A

    CALL !driver_update
    JMP !main
:
    JMP !communicate_snes        ; normal BMI out of range
;--------------------------------------
.proc driver_init    
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
    dmov DIR,   #$04    ; Sample Directory = $03XX

    MOV A, buf_CONTROL  ; Disable IPL ROM and timers
    MOV CONTROL, A

    CALL !play_sample

    JMP !main
.endproc
;--------------------------------------
.proc driver_update ; unload shadow buffers
    INC tmp0

    SET1 buf_CPU3.(SPC_BUSY)    ; Signal SPC available for communication
    MOV A, buf_CPU3
    MOV CPU3, A

    RET
.endproc
;--------------------------------------
.proc play_sample
    dmov (PITCHL|CH0), #$00     ; set CH0 pitch to whatever the regular samplerate is
    dmov (PITCHH|CH0), #$10
    dmov (VOLL|CH0), #$7F       ; CH0 output = max
    dmov (VOLR|CH0), #$7F
    dmov (SRCN|CH0), #0         ; sample 0

    dmov (ADSR1|CH0), #$CF
	dmov (ADSR2|CH0), #$88

    dmov KON, #1 << 0
    RET
.endproc 
;--------------------------------------
.segment "DIR" ; $0400
directory:
    .word sample0, sample0      ; BRR Start, BRR Loop addr
;--------------------------------------
.segment "BRR"
sample0:
    .incbin "samples/chime.brr" ; test samples
