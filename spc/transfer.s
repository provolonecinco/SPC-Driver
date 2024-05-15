.setcpu "none"
.include "inc/spc.inc" 
.include "inc/transfer.inc"
;--------------------------------------
.segment "ZEROPAGE"    
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

    JMP !wait_tick
.endproc
;--------------------------------------
.proc bulk_transfer
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

recieve:
    ; TODO: Write logic to recieve data
    MOV A, CPU3                 ; check if we're done
    BMI :+
    JMP !recieve
:
    
    MOV A, #END_COMM            ; signal to end communication                 
    MOV CPU3, A 

    JMP !communicate_snes::done
.endproc
;--------------------------------------