.proc mainprep
    setaxy8

    ; JML clearRAM
clear_done:
    setaxy8

    JSR spc_boot

    LDA #%10000000
    STA PPUNMI        ; $4200, enable NMI at VBlank
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


