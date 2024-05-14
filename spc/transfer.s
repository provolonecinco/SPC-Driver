.export communicate_snes
.import wait_tick
.importzp tmp0, tmp1, tmp2, tmp3, buf_T0DIV, buf_CONTROL

.setcpu "none"
.include "inc/spc-65c02.inc"
.include "inc/spc_defines.inc" 
.include "inc/transfer.inc"

.segment "SPCZEROPAGE"    
transfer_addr:      .res 2

.segment "SPCDRIVER"
.proc communicate_snes
; TODO: once handshake is confirmed read from I/O to determine request
    MOV A, #0                   ; Disable timers
    MOV CONTROL, A
    
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A
    
recieve:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOV A, CPU3                 ; check if we're done
    BMI :+
    JMP recieve
:
    MOV A, #$80
    MOV CPU3, A 

    INC tmp1

    MOV CPU0, #0                ; Reset I/O Ports
    MOV CPU1, #0
    MOV CPU2, #0
    MOV CPU3, #0 


    MOV A, buf_T0DIV            ; Reset timers
    MOV T0DIV, A
    SET1 buf_CONTROL.0
    MOV CONTROL, buf_CONTROL

    JMP wait_tick
.endproc
