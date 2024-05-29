.segment "DIR" ; $0400
directory:
    .word sample0, sample0 + 72      ; BRR Start, BRR Loop addr
;--------------------------------------
.segment "HEADER" ; 16B Song Header @ $0500
song0:    
    .byte 60             ; Speed (Ticks/Row)
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
    .byte $02, $02 ; KON, C3
    .byte $04, $00 ; INST, 0 
    .byte $10, $7F, $7F ; VOL, L+R = max
    .byte $01, $07 ; Silence, 8 rows
    .byte $02, $14 ; KON, something
    .byte $01, $07 ; Silence, 8
    .byte $0B, $00 ; JUMP, Frame 0 (loop)
;--------------------------------------
inst0:  
    .byte 0         ; sample #
    .byte $9F, $F7  ; ADSR
    .byte 0         ; GAIN
;--------------------------------------
freq_table: ;tuned to B+21c, pitchgen.py
    .word $87A,  $8FB,  $984,  $A15,  $AAE,  $B51,  $BFD,  $CB3,  $D75,  $E41,  $F1A,  $1000
;--------------------------------------
sample0:
    .incbin "samples/guitar16.brr" ; test samples
;--------------------------------------