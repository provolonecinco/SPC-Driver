.importzp framecounter
.import OAMDMA, CGRAMDMA, spc_transfer
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
    
    LDX framecounter    ; run update once every 256 frames
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