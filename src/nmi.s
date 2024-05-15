.include "inc/zp.inc"
.include "inc/main.inc"
.include "inc/gfx.inc"
.include "inc/spc_comm.inc"

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

	PLY       
    PLX
    PLA         
    RTI
.endproc

.proc IRQ
    RTI
.endproc