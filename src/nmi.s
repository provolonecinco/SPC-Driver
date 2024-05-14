.include "inc/main.inc"
.include "inc/gfx.inc"
.include "inc/spc_comm.inc"
.include "inc/snes.inc"
.export NMI, IRQ



.segment "BANK0"
.proc NMI 
    PHA         
    PHX         
    PHY         
    setaxy8  
    bit a:NMISTATUS


    JSR OAMDMA
    JSR CGRAMDMA

    INC framecounter
    
    LDX framecounter    ; run update once every 256 frames for testing
    BNE :+
    JSR spc_transfer
:
	PLY       
    PLX
    PLA         
    RTI
.endproc

.proc IRQ

.endproc