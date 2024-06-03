.align 256
directory:
    .word sample0, sample0      ; BRR Start, BRR Loop addr
    .word sample1, sample1
    .word sample2, sample2 + 2133
    .word sample3, sample3 + 891
;--------------------------------------
.align 256 ; 16B Song Header @ $0700
song0:    
    .byte 3             ; Speed (Ticks/Row)
    .byte 2             ; Number of channels
    .word pattern_table
    .word inst_table
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;--------------------------------------
pattern_table:
    .word pat0, pat1
    .word pat0, pat1
    .word pat0, pat2
    .word pat0, pat3
inst_table:
    .word kick0, snare0, hatclosed0, hatopen0, bass0, basspop0
;--------------------------------------
pat0: ; rhythm track
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
    .byte $17       ; next row

pat2:
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
    .byte $17       ; next row

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
sample0:
    .incbin "spc/samples/kick16.brr"
sample1:
    .incbin "spc/samples/snare32.brr"
sample2:
    .incbin "spc/samples/hato32.brr"
sample3:
    .incbin "spc/samples/bass32.brr"
;--------------------------------------