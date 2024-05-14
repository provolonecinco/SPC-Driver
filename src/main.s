.exportzp framecounter
.include "snes.inc"
.include "defines.inc"
.import spc_boot, clearRAM, CGRAMbuf, OAMbuf, OAMbuf_hi
.export mainprep

.segment "ZEROPAGE"
framecounter:           .res 1
temp:                   .res 4
pointer:                .res 3

.segment "BANK0"
null:
    .byte $00

tile:
    .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

.proc mainprep
    STZ VMADDL                              ; prep vram and wram regs                             
    STZ VMADDH
    STZ WMADDL  
    STZ WMADDM
    STZ WMADDH
    SETUPDMA 0, $08, null, 512, CGDATA      ; clear CGRAM on channel 0
    SETUPDMA 1, $09, null, 0, PPUDATA       ; clear VRAM on channel 1
    SETUPDMA 2, $08, null, 0, WMDATA        ; clear WRAM on channel 2
    LDA #%00000111                          ; fire away
    STA COPYSTART
    LDA #%00000100                          ; run channel 2 again to clear upper 64K of WRAM
    STA COPYSTART

    JSR spc_boot
                         
    LDA #%00010000                          ; enable OBJ layer
    STA TM
    LDA #(SPRITECHR_BASE >> 14) | OBSIZE_8_16
    STA OBSEL 

load_sprite:
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

    LDA #%00001111                          ; screen brightness = $F (on)
    STA INIDISP
    LDA #%10000000                          ; enable NMI at VBlank 
    STA NMITIMEN
    
    JMP main 
.endproc     

.proc main
    setaxy8
    LDA #$00
    TAX 
    TAY 
    INC OAMbuf

    LDA framecounter
WaitVBlank:
    CMP framecounter
    BEQ WaitVBlank    ; This exists so our loop runs only once per frame.
    JMP main
.endproc


