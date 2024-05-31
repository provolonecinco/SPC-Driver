.segment "DIR" ; $0500
directory:
    .word sample0, sample0      ; BRR Start, BRR Loop addr
    .word sample1, sample1
    .word sample2, sample2 + 2133
    .word sample3, sample3 + 891
;--------------------------------------
.segment "HEADER" ; 16B Song Header @ $0600
song0:    
    .byte 3             ; Speed (Ticks/Row)
    .byte 2             ; Number of channels
    .word pattern_table
    .word inst_table
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;--------------------------------------
.segment "SONGDATA"
pattern_table:
    .word pat0, pat1
    .word pat0, pat2
    .word pat0, pat3
    .word pat0, pat4
inst_table:
    .word kick0, snare0, hatclosed0, hatopen0, bass0, basspop0
;--------------------------------------
pat0:
    .byte $02, 48   ; KON 
    .byte $04, 0    ; INST 0 
    .byte $10, $7F, $7F ; VOL
    .byte $01, 3    ; Silence 3 

    .byte $02, 74   ; KON 
    .byte $04, 2    ; INST 2
    .byte $01, 1    ; Silence 1

    .byte $02, 74   ; KON 
    .byte $01, 1    ; Silence 1

    .byte $02, 74   ; KON 
    .byte $04, 1    ; INST 1
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 3    ; INST 3
    .byte $01, 3    ; Silence 3

    .byte $02, 48   ; KON 
    .byte $04, 0    ; INST 0
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 1    ; INST 1
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 2    ; INST 2
    .byte $01, 3    ; Silence 3

    .byte $02, 48   ; KON 
    .byte $04, 0    ; INST 0
    .byte $01, 5    ; Silence 5

    .byte $02, 74   ; KON 
    .byte $04, 3    ; INST 3
    .byte $01, 1    ; Silence 1

    .byte $02, 74   ; KON 
    .byte $04, 2    ; INST 2
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 1    ; INST 1
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 2    ; INST 2
    .byte $01, 3    ; Silence 3

    .byte $02, 48   ; KON 
    .byte $04, 0    ; INST 0
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 2    ; INST 2
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 1    ; INST 1
    .byte $01, 3    ; Silence 3

    .byte $02, 74   ; KON 
    .byte $04, 3    ; INST 3
    .byte $01, 3    ; Silence 3





pat1:
    .byte $02, 30   ; KON 
    .byte $04, 4    ; INST 4 
    .byte $10, $60, $60 ; VOL
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 54   ; KON 
    .byte $04, 5    ; INST 5 
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 50   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 26   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 28   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 54   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 26   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 50   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 28   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 52   ; KON
    .byte $04, 5    ; INST 5  
    .byte $01, 2    ; Silence 2
    .byte $0B, 1    ; next row

pat2:
    .byte $02, 30   ; KON 
    .byte $04, 4    ; INST 4 
    .byte $10, $60, $60 ; VOL
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 54   ; KON 
    .byte $04, 5    ; INST 5 
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 50   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 26   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 28   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 54   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 30   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 26   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 50   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 28   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 52   ; KON
    .byte $04, 5    ; INST 5  
    .byte $01, 2    ; Silence 3
    .byte $0B, 2    ; next row

pat3:
    .byte $02, 40   ; KON 
    .byte $04, 4    ; INST 4 
    .byte $10, $60, $60 ; VOL
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 64   ; KON 
    .byte $04, 5    ; INST 5 
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 60   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 36   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 38   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 64   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 36   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 60   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 38   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 62   ; KON
    .byte $04, 5    ; INST 5  
    .byte $01, 2    ; Silence 3
    .byte $0B, 3    ; next row
pat4:
    .byte $02, 40   ; KON 
    .byte $04, 4    ; INST 4 
    .byte $10, $60, $60 ; VOL
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 64   ; KON 
    .byte $04, 5    ; INST 5 
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 60   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 36   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 38   ; KON  
    .byte $01, 3    ; Silence 3

    .byte $02, 64   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 40   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 36   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 60   ; KON  
    .byte $04, 5    ; INST 5
    .byte $01, 3    ; Silence 3

    .byte $02, 38   ; KON  
    .byte $04, 4    ; INST 4
    .byte $01, 3    ; Silence 3

    .byte $02, 62   ; KON
    .byte $04, 5    ; INST 5  
    .byte $01, 2    ; Silence 3
    .byte $0B, 0    ; next row
;--------------------------------------
kick0:
    .byte 0
    .byte $00, $00
    .byte %01111111
snare0:
    .byte 1
    .byte $00, $00
    .byte %01111111
hatclosed0:
    .byte 2
    .byte $EF, $1F
    .byte 0
hatopen0: 
    .byte 2
    .byte $AF, $11
    .byte 0
bass0:
    .byte 3
    .byte $9F, $A0
    .byte 0
basspop0:
    .byte 3
    .byte $9F, $BF
    .byte 0
;--------------------------------------
freq_table: ;tuned to B+21c, pitchgen.py
    .word $021E,  $023F,  $0261,  $0285,  $02AC,  $02D4,  $02FF,  $032D,  $035D,  $0390,  $03C7,  $0400 ; -2 Octave
    .word $043D,  $047E,  $04C2,  $050A,  $0557,  $05A8,  $05FE,  $065A,  $06BA,  $0721,  $078D,  $0800 ; -1 Octave
    .word $087A,  $08FB,  $0984,  $0A15,  $0AAE,  $0B51,  $0BFD,  $0CB3,  $0D75,  $0E41,  $0F1A,  $1000 ; native 16khz
    .word $10F4,  $11F6,  $1307,  $1429,  $155C,  $16A1,  $17FA,  $1967,  $1AE9,  $1C83,  $1E35,  $2000 ; +1 Octave
    .word $21E8,  $23EC,  $260F,  $2852,  $2AB8,  $2D42,  $2FF3,  $32CD,  $35D3,  $3906,  $3C6A,  $4000 ; +2 Octave
;--------------------------------------
sample0:
    .incbin "samples/kick16.brr"
sample1:
    .incbin "samples/snare32.brr"
sample2:
    .incbin "samples/hato32.brr"
sample3:
    .incbin "samples/bass32.brr"
;--------------------------------------