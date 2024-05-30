.include "inc/zp.inc"
.include "inc/main.inc"
.include "inc/gfx.inc"
.include "inc/spc_comm.inc"
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc prg_entry
    JSR spc_boot
                         
    LDA #%00010000                          ; enable OBJ layer
    STA TM
    LDA #(SPRITECHR_BASE >> 14) | OBSIZE_8_16
    STA OBSEL 

    JSR load_sprite
    JSR play_song   ; init song

    LDA #%00001111                          ; screen brightness = $F (on)
    STA INIDISP
    LDA #%10000000                          ; enable NMI at VBlank 
    STA NMITIMEN
    
    JMP main 
.endproc     
;--------------------------------------
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
;--------------------------------------