.include "inc/snes.inc"
.include "inc/spc_comm.inc"

DRIVER_SIZE =   (spc_driver_end - spc_driver)

.segment "ZEROPAGE"
SPC_transfer_pointer:   .res 3
SPC_transfer_size:      .res 2
SPC_transfer_counter:   .res 1
SPC_target_addr:        .res 2

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

.proc spc_bulktransfer  ; X = Index into Song table
    setaxy8
    STZ PPUNMI      ; disable NMI/IRQ

    LDA song_bank, X
    STA SPC_transfer_pointer + 2
    TXA 
    ASL 
    TAX 
    LDA song_addr, X
    STA SPC_transfer_pointer
    INX
    LDA song_addr, X
    STA SPC_transfer_pointer + 1

    LDY #0
    LDA [SPC_transfer_pointer], Y  ; length
    TAX     

    LDA #SPC_BULK_TRANSFER      ; send opcode
    STA APU0
:
    LDA APU1                    ; Wait for SPC to mimic data (Should I add a timeout?)
    CMP #SPC_BULK_TRANSFER
    BNE :-

    INY
handshake_complete:
    LDA [SPC_transfer_pointer], Y
    STA APU0
:
    CMP [SPC_transfer_pointer], Y   ; mimic
    BNE :-
    INY 
    DEX 
    BNE handshake_complete
    LDA #SPC_ENDCOMM            ; set transfer end flag early for testing (SPC NOPS for a while)
    STA APU3
    
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
song_addr:
    .word       sample_data 
song_bank:
    .bankbytes  sample_data

sample_data:
    .byte $10       ; transfer length
    .word $0300     ; Target SPC Addr
    .repeat 16      ; test data
        .byte $88
    .endrepeat

spc_driver:
    .incbin "output/spcdriver.bin"
spc_driver_end:

