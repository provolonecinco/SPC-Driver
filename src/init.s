.include "inc/main.inc"

.segment "BANK0"
.proc RESET
    SEI               ; turn off IRQs
    CLC
    XCE               ; turn off 6502 emulation mode
    CLD               ; turn off decimal ADC/SBC

    setaxy16             
    LDX #$01FF
    TXS                   ; set the stack pointer

    LDA #$4200            ; Initialize the CPU I/O registers to predictable values
    TAD                   ; temporarily move direct page to S-CPU I/O area
    LDA #$FF00
    STA $00
    STZ $02
    STZ $04
    STZ $06
    STZ $08
    STZ $0A
    STZ $0C

    ; Initialize the PPU registers to predictable values
    LDA #$2100            ; temporarily move direct page to PPU I/O area
    TAD                   

    ; first clear the regs that take a 16-bit write
    LDA #$0080
    STA $00               ; Enable forced blank
    STZ $02
    STZ $05
    STZ $07
    STZ $09
    STZ $0B
    STZ $16
    STZ $24
    STZ $26
    STZ $28
    STZ $2A
    STZ $2C
    STZ $2E
    STZ $81
    STZ $82
    STZ $83
    LDX #$0030
    STX $30               ; Disable color math
    LDY #$00E0
    STY $32               ; Clear red, green, and blue components of COLDATA

    ; now clear the regs that need 8-bit writes
    SEP #$20
    STZ $15               ; still $80: Inc VRAM pointer after high byte write
    STZ $1A
    STZ $21
    STZ $23
    STZ $4016

    ; The scroll registers $210D-$2114 need double 8-bit writes
    .repeat 8, I
    STZ $0D+I
    STZ $0D+I
    .endrepeat

    ; As do the mode 7 registers, which we set to the identity matrix
    ; [ $0100  $0000 ]
    ; [ $0000  $0100 ]
    LDA #$01
    STZ $1B
    STA $1B
    STZ $1C
    STZ $1C
    STZ $1D
    STZ $1D
    STZ $1E
    STA $1E
    STZ $1F
    STZ $1F
    STZ $20
    STZ $20

    LDA #$01            ; set FastROM
    STA MEMSEL

    REP #$20
    LDA #0
    TAD                 ; return direct page to real zero page

    setaxy8
    SETDMA 0, $08, null, 512, CGDATA        ; clear CGRAM on channel 0
    SETDMA 1, $09, null, 0, PPUDATA         ; clear VRAM on channel 1
    SETDMA 2, $08, null, 0, WMDATA          ; clear WRAM on channel 2
    LDA #%00000111                          ; fire away
    STA COPYSTART
    LDA #%00000100                          ; run channel 2 again to clear upper 64K of WRAM
    STA COPYSTART

    JMP prg_entry
.endproc


