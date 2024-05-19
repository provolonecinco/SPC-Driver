.include "inc/spc.inc"
.include "inc/driver.inc"

NUM_CHANNELS = 1

.segment "ZEROPAGE"
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
instptr:            .res 2
.segment "DRIVER"
;-------------------------------------
.proc play_sample
    dmov (PITCHL|CH0), #$00     ; set CH0 pitch to whatever the regular samplerate is
    dmov (PITCHH|CH0), #$08
    dmov (VOLL|CH0), #$7F       ; CH0 output = max
    dmov (VOLR|CH0), #$7F
    dmov (SRCN|CH0), #0         ; sample 0

    dmov (ADSR1|CH0), #$CF
	dmov (ADSR2|CH0), #$88

    dmov KON, #1 << 0
    RET
.endproc 
;--------------------------------------
.proc play_song
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

    MOV A, !$0500        ; Set 30ms timer
    MOV T0DIV, A

    MOV CONTROL, #%00110001     ; Reset I/O Ports, Set T0
    MOV buf_CONTROL, #%00110001
    JMP !main
.endproc 
;--------------------------------------
.segment "DIR" ; $0400
directory:
    .word sample0, sample0      ; BRR Start, BRR Loop addr
;--------------------------------------
.segment "HEADER" ; 16B Song Header
song0:    
    .byte 240           ; Timer 0 Divider (15ms = 120, 30ms = 240)
    .byte NUM_CHANNELS  ; Number of channels
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
    .word $0800, $807A, $08FB, $0983, $0A14, $0AAE, $0B50, $0BFD, $0CB3, $0D74, $0E41, $0F1A
pitch_32: 
    .word $1000, $10F4, $11F6, $1307, $1429, $155C, $16A1, $17F9, $1966, $1AE9, $1C82, $1E34
;--------------------------------------
sample0:
    .incbin "samples/guitar16.brr" ; test samples
;--------------------------------------