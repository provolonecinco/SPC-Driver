.export communicate_snes

.setcpu "none"
.include "inc/spc-65c02.inc"
.include "inc/spc_defines.inc" 
.include "inc/transfer.inc"

.segment "SPCZEROPAGE"    
transfer_addr:      .res 2

.segment "SPCDRIVER"
.proc communicate_snes
; TODO: once handshake is confirmed read from I/O to determine request
    RET
.endproc
