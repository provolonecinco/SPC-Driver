.include "inc/spc.inc"
.include "inc/driver.inc"

.segment "ZEROPAGE"
; DSP Buffer ------------------------ ;
buf_CLVOL:          .res 8
buf_CRVOL:          .res 8
buf_CFREQLO:        .res 8
buf_CFREQHI:        .res 8
buf_LVOL:           .res 1
buf_RVOL:           .res 1
buf_LECHOVOL:       .res 1
buf_RECHOVOL:       .res 1
buf_KON:            .res 1
buf_KOFF:           .res 1
; Driver-Specific --------------------;
patternptr:         .res 2
instptr:            .res 2
tick:               .res 1
;--------------------------------------
.segment "DRIVER"
;-------------------------------------
.proc play_sample
    CMP tmp3, #24
    BNE :+
    MOV tmp3, #0
:

    dmov (PITCHL|CH0), #$7A
    dmov (PITCHH|CH0), #$08

    dmov (VOLL|CH0), #$7F       ; CH0 output = max
    dmov (VOLR|CH0), #$7F
    dmov (SRCN|CH0), #0         ; sample 0

    dmov (ADSR1|CH0), #%10011111
	dmov (ADSR2|CH0), #%11110001

    dmov (PITCHL|CH1), #$AE
    dmov (PITCHH|CH1), #$0A

    dmov (VOLL|CH1), #$7F       ; CH0 output = max
    dmov (VOLR|CH1), #$7F
    dmov (SRCN|CH1), #0         ; sample 0

    dmov (ADSR1|CH1), #%10011111
	dmov (ADSR2|CH1), #%11110001

    dmov (PITCHL|CH2), #$B3
    dmov (PITCHH|CH2), #$0C

    dmov (VOLL|CH2), #$7F       ; CH0 output = max
    dmov (VOLR|CH2), #$7F
    dmov (SRCN|CH2), #0         ; sample 0

    dmov (ADSR1|CH2), #%10011111
	dmov (ADSR2|CH2), #%11110001

    dmov KON, #7 << 0
    RET
.endproc 
;--------------------------------------
.proc play_song
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

    MOV CPU0, #0
    MOV CPU1, #0
    JMP !main
.endproc 
;--------------------------------------
.proc driver_update ; unload shadow buffers
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A
    
    INC tick
    BNE :+
    CALL !play_sample
    MOV tick, #$C0
:

    INC tmp0
    .repeat 12
        NOP
    .endrepeat
    MOV CPU0, #0
    MOV CPU1, #0
    JMP !main
.endproc
;--------------------------------------
.segment "DIR" ; $0400
directory:
    .word sample0, sample0 + 144      ; BRR Start, BRR Loop addr
;--------------------------------------
.segment "HEADER" ; 16B Song Header
song0:    
    .byte 4             ; Speed (Ticks/Row)
    .byte 1             ; Number of channels
    .word pattern_table
    .word inst_table
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;--------------------------------------
.segment "SONGDATA"
pattern_table:
    .word pat0  
inst_table:
    .word inst0
;--------------------------------------
pat0:
    .byte 0, 0, $7F, 0 ; (note=0), (inst=0), (vol=max), (length=indefinite)
;--------------------------------------
inst0:  
    .byte 0, $CF, $88 ; (sample=0), (ADSR=CF88)
;--------------------------------------
pitch_8:  ; pitchgen.py
    .word $0400, $043D, $047D, $04C2, $050A, $0557, $05A8, $05FE, $0659, $06BA, $0721, $078D
pitch_16: 
    .word $0800, $087A, $08FB, $0983, $0A14, $0AAE, $0B50, $0BFD, $0CB3, $0D74, $0E41, $0F1A
pitch_32: 
    .word $1000, $10F4, $11F6, $1307, $1429, $155C, $16A1, $17F9, $1966, $1AE9, $1C82, $1E34
;--------------------------------------
sample0:
    .incbin "samples/guitar16.brr" ; test samples
;--------------------------------------