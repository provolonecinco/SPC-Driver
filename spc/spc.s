;--------------------------------------
.setcpu "none"
.include "inc/spc.inc"
.include "inc/driver.inc"
;--------------------------------------
.segment "ZEROPAGE"  
; General Purpose ---------------------;  
tmp0:               .res 1
tmp1:               .res 1
tmp2:               .res 1
tmp3:               .res 1
tmp4:               .res 1
tmp5:               .res 1
tmp6:               .res 1
tmp7:               .res 1
transfer_addr:      .res 2
;--------------------------------------
.segment "DRIVER"
;--------------------------------------
spc_entrypoint:         ; SPC Init
    CLRP                ; Zeropage @ $00XX
    MOV A, #0           ; Zero out stack
clrstack:
    MOV !$0100 + X, A
    INC X
    BNE clrstack
    MOV X, #$FF         ; Stack pointer = $01FF
    MOV SP, X
    MOV X, #0           ; zero out DSP regs
    MOV Y, #0      
clrdsp:
    MOV DSPADDR, X  
    MOV DSPDATA, Y 
    INC X 
    BPL clrdsp
    dmov ESA,   #$FF    ; Echo addr = $FF00
    dmov MVOLL, #$7F    ; Master Volume (L/R) = $7F
    dmov MVOLR, #$7F
    dmov FLG,   #$20    ; mute off, echo write off, LFSR noise stop
    dmov DIR,   #$04    ; Sample Directory = $04XX
    MOV CONTROL, #$00   ; Disable IPL ROM and timers
.proc main
    MOV A, CPU0                 ; check for communication
    BPL main            
    MOV A, CPU0                 ; mask upper 4bits to determine index into jump table
    AND A, #$0F                 
    ASL A
    MOV X, A
    JMP [!jump_table + X]   
.endproc  
;--------------------------------------
jump_table:
    .word bulk_transfer, song_init, driver_update
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
    MOV CPU3, #$80              ; bit 7 signals end
    MOV CPU0, #0
    MOV CPU1, #0
    MOV CPU2, #0
    MOV CPU3, #0
    JMP !main
.endproc
;--------------------------------------
.proc song_init
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    MOV counter, #1 ; Process row immediately

    MOV A, #<pat0
    MOV pathead, A

    MOV A, #>pat0
    MOV pathead + 1, A
    
    MOV A, !$0500 + 4
    MOV instptr, A
    
    MOV A, !$0500 + 5
    MOV instptr + 1, A
   

    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc 
;--------------------------------------