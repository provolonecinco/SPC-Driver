.include "inc/spc.inc"
.include "inc/driver.inc"

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
.proc play_song
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

    MOV buf_T0DIV, $0500        ; Set 30ms timer
    MOV T0DIV, buf_T0DIV

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
    .byte 240   ; Timer 0 Divider (15ms = 120, 30ms = 240)
    .byte 1     ; Number of channels
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
    .byte 0, 0, #$7F, 0 ; (note=0), (inst=0), (vol=max), (length=indefinite)
;--------------------------------------
inst0:  
    .byte 0, $CF, $88 ; (sample=0), (ADSR=CF88)
;--------------------------------------
pitch_32:
    .word $1000, $1800, $2000   ; sample notes
;--------------------------------------
sample0:
    .incbin "samples/chime.brr" ; test samples
;--------------------------------------