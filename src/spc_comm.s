.include "inc/zp.inc"
.include "inc/main.inc"
.include "inc/spc_comm.inc"

DRIVER_SIZE =   (spc_driver_end - spc_driver)

.segment "ZEROPAGE"
SPC_transfer_pointer:   .res 3
SPC_transfer_size:      .res 2
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
    STZ tmp0
transfer_driver:
    LDA f:spc_driver, X
    STA APU1
    LDA tmp0
    STA APU0        
:
    CMP APU0
    BNE :-
    INA 
    STA tmp0
    INX 
    CPX #DRIVER_SIZE
    BNE transfer_driver
; transfer is finished, execute program
    LDA #$02                ; write entry point address -> $0200
    STA APU3
    STZ APU2
    LDA tmp0                ; completed
    INA
    INA 
    STA APU0
    setxy8
    RTS 
.endproc

.proc load_song ; X = song index
    setaxy8

    JSR spc_bulktransfer    ; pattern data
    ;JSR spc_bulktransfer    ; instrument data
    ;JSR spc_bulktransfer    ; sample directory
    ;JSR spc_bulktransfer    ; samples
    RTS
.endproc

.proc play_song ; SPC will start Timer 0
    setaxy8
    LDA #SPC_START
    STA APU0
:
    LDA APU1
    CMP #SPC_START
    BNE :-
    RTS
.endproc 

.proc spc_bulktransfer 
    setaxy8
    STZ PPUNMI              ; disable NMI/IRQ

    LDA SPC_target_addr     ; send transfer addr
    STA APU1
    LDA SPC_target_addr + 1
    STA APU2
    LDA #SPC_TRANSFER       ; send opcode
    STA APU0
:
    LDA APU1                ; Wait for SPC to mimic data
    CMP #SPC_TRANSFER
    BNE :-

    setxy16
    LDX #0
    TXY
    STZ tmp0
transfer:
    LDA [SPC_transfer_pointer], Y
    STA APU1
    TYA
    STA APU0        
:
    CMP APU0
    BNE :-
    INY
    INX 
    CPY SPC_transfer_size
    BNE transfer
    
    LDA #SPC_ENDCOMM        ; signal all done
    STA APU3
:    
    LDA APU3                ; wait for mimic
    BPL :-

    STZ APU0                ; reset ports
    STZ APU1
    STZ APU2 
    STZ APU3

    LDA #$80                ; reenable NMI
    STA PPUNMI
    RTS
.endproc

.segment "BANK1"
spc_driver:
    .incbin "output/spcdriver.bin"
spc_driver_end:

