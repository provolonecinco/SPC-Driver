.setcpu "none"
.include "spc-65c02.inc"
.include "spc_defines.inc" 

.segment "SPCZEROPAGE"    
temp:               .res 1
SPC_control_buf:    .res 1

; DSP Buffer
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
spc_entrypoint:
    jsr driver_init

wait_tick:
    inc temp
    jmp wait_tick 

;--------------------------------------

.proc driver_init    
    ldx #0                  ; zero out DSP regs
    ldy #0      
:
    stx DSPADDR  
    sty DSPDATA 
    inx 
    bpl :-

    lda SPC_control_buf     ; Disable IPL ROM and timers
    sta CONTROL

    rts 
.endproc

.proc driver_update

.endproc