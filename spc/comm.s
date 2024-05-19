.setcpu "none"
.include "inc/spc.inc" 
.include "inc/comm.inc"
.include "inc/driver.inc"
;--------------------------------------
.segment "ZEROPAGE"    
transfer_addr:      .res 2
;--------------------------------------
.segment "DRIVER"
jump_table:
    .word bulk_transfer, play_song
;--------------------------------------
.proc communicate_snes
    MOV A, #0                   ; Disable timers
    MOV CONTROL, A
    MOV buf_CONTROL, A
    
check_opcode:
    MOV A, CPU0                 ; mask upper 4bits to determine index into jump table
    AND A, #$0F                 
    ASL A
    MOV X, A
    JMP [!jump_table + X]
.endproc
;--------------------------------------
.proc bulk_transfer
    MOV A, CPU0                 ; Mimic on Port 1
    MOV CPU1, A

    MOV A, CPU1                 ; get pointer
    MOV transfer_addr, A
    MOV A, CPU2
    MOV transfer_addr + 1, A

wait_index:
    MOV Y, CPU0                 ; Index (Should be 0)
    BNE wait_index
recieve:
    MOV A, CPU3                 ; check if we're done
    BMI done
    CMP Y, CPU0                 ; wait until index changes
    BNE recieve
    MOV A, CPU1                 ;get data
    MOV CPU0, Y                 ;send index
    MOV [transfer_addr] + Y, A  ;store data
    INC Y                       ;addr lsb
    BNE recieve
    INC transfer_addr + 1       ;addr msb
    BRA recieve
done:
    MOV CPU3, #END_COMM
    MOV CONTROL, #%00110000     ; Reset I/O Ports
    MOV buf_CONTROL, #%00110000
    JMP !main
.endproc
;--------------------------------------
