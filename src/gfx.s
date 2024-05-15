.include "inc/main.inc"
.include "inc/gfx.inc"

.segment "LORAM"
OAMbuf:         .res 512    
OAMbuf_hi:      .res 32
CGRAMbuf:       .res 512

.segment "BANK0"

.proc OAMDMA
    STZ OAMADDL
    STZ OAMADDH
    SETUPDMA 0, $00, OAMbuf, 544, OAMDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc

.proc CGRAMDMA
    SETUPDMA 0, $00, CGRAMbuf, 512, CGDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc