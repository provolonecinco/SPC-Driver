.proc NMI 
    PHA         
    PHX         
    PHY         
    setaxy8  
    bit a:NMISTATUS


    INC framecounter
	PLY       
    PLX
    PLA         
    RTI
.endproc

.proc IRQ

.endproc