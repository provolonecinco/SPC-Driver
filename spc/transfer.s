.export communicate_snes
.import wait_tick
.importzp tmp0, tmp1, tmp2, tmp3, buf_T0DIV, buf_CONTROL

.setcpu "none"
.include "inc/spc-65c02.inc"
.include "inc/spc_defines.inc" 
.include "inc/transfer.inc"
;--------------------------------------
.segment "SPCZEROPAGE"    
transfer_addr:      .res 2
;--------------------------------------
.segment "SPCDRIVER"
jump_table:
    .word bulk_transfer
;--------------------------------------
.proc communicate_snes
    MOV A, #0                   ; Disable timers
    MOV CONTROL, A
    
check_opcode:
    MOV A, CPU0                 ; mask upper 4bits to determine index into jump table
    AND A, #$0F                 
    ASL A
    MOV X, A
    JMP [!jump_table + X]

done:
    MOV CONTROL, #%00110000     ; Reset I/O Ports

    MOV A, buf_T0DIV            ; Reset timers
    MOV T0DIV, A
    SET1 buf_CONTROL.0
    MOV CONTROL, buf_CONTROL

    JMP wait_tick
.endproc
;--------------------------------------
.proc bulk_transfer
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

recieve:
    INC tmp1
    .repeat 25                  ; TODO - remove and put actual receiving logic in
    NOP
    .endrepeat
    
    MOV A, CPU3                 ; check if we're done
    BMI :+
    JMP recieve
:
    
    MOV A, #$80                ; signal to end communication                 
    MOV CPU3, A 

    JMP communicate_snes::done
.endproc
;--------------------------------------