.segment "DIR" ; $0400
directory:
    .word sample0, sample0 + 72      ; BRR Start, BRR Loop addr
;--------------------------------------
.segment "HEADER" ; 16B Song Header @ $0500
song0:    
    .byte 4             ; Speed (Ticks/Row)
    .byte 3             ; Number of channels
    .word pattern_table
    .word inst_table
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;--------------------------------------
.segment "SONGDATA"
pattern_table:
    .word pat0, pat1, pat2
inst_table:
    .word inst0
;--------------------------------------
pat0:
    .byte $02, 50   ; KON, native
    .byte $04, $00  ; INST, 0 
    .byte $10, $7F, $7F ; VOL, L+R = max
    .byte $01, $04  ; Silence, 5 

    .byte $02, 58   ; KON, something
    .byte $10, $50, $50 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 5

    .byte $02, 64   ; KON, something
    .byte $10, $20, $20 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 5
    
    .byte $02, 58   ; KON, something
    .byte $10, $40, $40 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 5 rows

pat1:
    .byte $02, 58   ; KON, native
    .byte $04, $00  ; INST, 0 
    .byte $10, $7F, $7F ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16 rows

    .byte $02, 64   ; KON, something
    .byte $10, $50, $50 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16

    .byte $02, 74   ; KON, something
    .byte $10, $20, $20 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16
    
    .byte $02, 64   ; KON, something
    .byte $10, $40, $40 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16


pat2:
    .byte $02, 64   ; KON, native
    .byte $04, $00  ; INST, 0 
    .byte $10, $7F, $7F ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16 rows

    .byte $02, 74   ; KON, something
    .byte $10, $50, $50 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16

    .byte $02, 82   ; KON, something
    .byte $10, $20, $20 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16
    
    .byte $02, 74   ; KON, something
    .byte $10, $40, $40 ; VOL, L+R = max
    .byte $01, $04  ; Silence, 16
;--------------------------------------
inst0:  
    .byte 0         ; sample #
    .byte $9F, $F7  ; ADSR
    .byte 0         ; GAIN
;--------------------------------------
freq_table: ;tuned to B+21c, pitchgen.py
    .word $021E,  $023F,  $0261,  $0285,  $02AC,  $02D4,  $02FF,  $032D,  $035D,  $0390,  $03C7,  $0400 ; -2 Octave
    .word $043D,  $047E,  $04C2,  $050A,  $0557,  $05A8,  $05FE,  $065A,  $06BA,  $0721,  $078D,  $0800 ; -1 Octave
    .word $087A,  $08FB,  $0984,  $0A15,  $0AAE,  $0B51,  $0BFD,  $0CB3,  $0D75,  $0E41,  $0F1A,  $1000 ; native 16khz
    .word $10F4,  $11F6,  $1307,  $1429,  $155C,  $16A1,  $17FA,  $1967,  $1AE9,  $1C83,  $1E35,  $2000 ; +1 Octave
    .word $21E8,  $23EC,  $260F,  $2852,  $2AB8,  $2D42,  $2FF3,  $32CD,  $35D3,  $3906,  $3C6A,  $4000 ; +2 Octave
;--------------------------------------
sample0:
    .incbin "samples/guitar16.brr" ; test samples
;--------------------------------------