.importzp framecounter
.import OAMDMA, CGRAMDMA
.export NMI, IRQ
.include "snes.inc"


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

.endproc