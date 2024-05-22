.include "inc/main.inc"
.include "inc/gfx.inc"
;--------------------------------------
.segment "LORAM"
OAMbuf:         .res 512    
OAMbuf_hi:      .res 32
CGRAMbuf:       .res 512
;--------------------------------------
.segment "BANK0"
;--------------------------------------
tile:
    .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;--------------------------------------
.proc OAMDMA
    STZ OAMADDL
    STZ OAMADDH
    SETDMA 0, $00, OAMbuf, 544, OAMDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc
;--------------------------------------
.proc CGRAMDMA
    SETDMA 0, $00, CGRAMbuf, 512, CGDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc
;--------------------------------------
.proc load_sprite
    LDA #$1F                                ; set color to red
    STA CGRAMbuf + ($81 * 2)

    LDA #16                                 ; load tile into vram
    STA VMADDL
    STZ VMADDH
    LDX #0
:
    LDA tile, X 
    STA PPUDATA
    INX
    LDA tile, X
    STA PPUDATAHI
    INX 
    CPX #32
    BNE :-

    LDA #128                                ; set OAM entry
    STA OAMbuf
    LDA #112
    STA OAMbuf + 1
    LDA #1
    STA OAMbuf + 2
    STZ OAMbuf + 3
    STZ OAMbuf_hi 
    RTS
.endproc
;--------------------------------------