.exportzp framecounter
.include "snes.inc"
.include "defines.inc"
.import spc_boot, clearRAM, CGRAMbuf, OAMbuf
.export mainprep
.smart

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
    LDA #%00000111
    STA COPYSTART
    LDA #%00000100                          ; run channel 2 again to clear upper 64K of WRAM
    STA COPYSTART

    JSR spc_boot
                         
    LDA #%00010000                          ; enable OBJ layer
    STA TM
    LDA #(SPRITECHR_BASE >> 14) | OBSIZE_16_32
    STA OBSEL 

    LDA #%10001111                          ; enable NMI, screen brightness = $F (on)
    STA PPUNMI

load_sprite:
    LDA #$1F
    STA CGRAMbuf + ($71 * 2)

    LDA #16
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

    LDA #128
    STA OAMbuf
    STA OAMbuf + 1
    LDA #1
    STA OAMbuf + 2
    STZ OAMbuf + 3

    JMP main 
.endproc     

.proc main
    setaxy8
    LDA #$00
    TAX 
    TAY 
   

    LDA framecounter
WaitVBlank:
    CMP framecounter
    BEQ WaitVBlank    ; This exists so our loop runs only once per frame.
    JMP main
.endproc


