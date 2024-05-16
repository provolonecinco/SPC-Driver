;--------------------------------------
.setcpu "none"
.include "inc/spc.inc"
.include "inc/transfer.inc"
;--------------------------------------
.segment "ZEROPAGE"    
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

; ----- DSP Buffer ----- ;
buf_CLVOL:          .res NUM_CHANNELS
buf_CRVOL:          .res NUM_CHANNELS
buf_CFREQLO:        .res NUM_CHANNELS
buf_CFREQHI:        .res NUM_CHANNELS
buf_LVOL:           .res NUM_CHANNELS
buf_RVOL:           .res NUM_CHANNELS
buf_LECHOVOL:       .res NUM_CHANNELS
buf_RECHOVOL:       .res NUM_CHANNELS
buf_KEYON:          .res NUM_CHANNELS
buf_KEYOFF:         .res NUM_CHANNELS
;--------------------------------------
.segment "SPCDRIVER"
;--------------------------------------
spc_entrypoint:
    JMP !driver_init
main:
    MOV A, CPU0                 ; check for communication
    BMI communicate_snes

    BBC buf_CONTROL.0, main     ; don't check timer unless enabled
    MOV A, T0OUT                
    BEQ main

    CLR1 buf_CPU3.(SPC_BUSY)    ; Signal SPC is not available for communication
    MOV A, buf_CPU3
    MOV CPU3, A

    CALL !driver_update
    JMP !main
;--------------------------------------
.proc driver_init    
    CLRP                        ; Zeropage @ $00XX
    
    MOV A, #0                   ; Zero out stack
:
    MOV !$0100 + X, A
    INC X
    BNE :-
    
    MOV X, #$FF                 ; Stack pointer = $01FF
    MOV SP, X

    MOV X, #0                   ; zero out DSP regs
    MOV Y, #0      
:
    MOV DSPADDR, X  
    MOV DSPDATA, Y 
    INC X 
    BPL :-

    MOV DSPADDR, #DSP_ESA       ; Echo addr = $FF00
    MOV DSPDATA, #$FF

    MOV A, buf_CONTROL          ; Disable IPL ROM and timers
    MOV CONTROL, A

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