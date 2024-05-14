.include "inc/snes.inc"
.include "inc/spc_comm.inc"

DRIVER_SIZE =   (spc_driver_end - spc_driver)

.segment "ZEROPAGE"
SPC_transfer_pointer:   .res 3
SPC_transfer_counter:   .res 1
SPC_transfer_size:      .res 2

.segment "BANK0"
.proc spc_boot
    seta8
    setxy16
:                   ; wait for SPC to boot
    LDA APU0    
    CMP #$AA
    BNE :-
:
    LDA APU1
    CMP #$BB
    BNE :-

    LDA #$FF        ; write a nonzero to initiate transfer
    STA APU1          
    
    LDA #$02        ; set transfer address to $0200
    STA APU3
    STZ APU2

    LDA #$CC        ; IPL bootrom expects $CC
    STA APU0
:                   ; wait for SPC to mimic it
    CMP APU0 
    BNE :-

; We are ready to transfer the driver

    LDX #0
    STZ SPC_transfer_counter
transfer_driver:
    LDA f:spc_driver, X
    STA APU1

    LDA SPC_transfer_counter
    STA APU0        

:
    CMP APU0
    BNE :-
    INA 
    STA SPC_transfer_counter
    INX 
    CPX #DRIVER_SIZE
    BNE transfer_driver

; transfer is finished, execute program
 
    LDA #$02    ; write entry point address -> $0200
    STA APU3
    STZ APU2

    LDA SPC_transfer_counter    ; completed
    INA
    INA 
    STA APU0

    setxy8
    RTS 
.endproc

.proc spc_transfer
    setaxy8
    STZ PPUNMI      ; disable NMI/IRQ

    LDA #$80
    STA APU0
:
    LDA APU1        ; Wait for SPC to mimic data (Should I add a timeout?)
    CMP #$80
    BNE :-

    LDA #$80        ; set transfer end flag early for testing (SPC NOPS for a while)
    STA APU3
handshake_complete:
    LDA APU3        ; wait for SPC to finish spinning and mimic the termination
    CMP #$80
    BNE handshake_complete

    STZ APU0        ; reset ports
    STZ APU1
    STZ APU2 
    STZ APU3

    LDA #$80        ; reenable NMI
    STA PPUNMI
    RTS
.endproc

.segment "BANK1"
spc_driver:
    .incbin "output/spcdriver.bin"
spc_driver_end:

