.include "inc/zp.inc"
.include "inc/main.inc"
.include "inc/spc_comm.inc"
;--------------------------------------
.import __SPCIMAGE_RUN__, __SPCIMAGE_LOAD__, __SPCIMAGE_SIZE__
;--------------------------------------
.segment "ZEROPAGE"
SPC_transfer_pointer:   .res 3
SPC_transfer_size:      .res 2
SPC_target_addr:        .res 2
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc spc_boot
    seta8
    setxy16

    LDX APU0
    CPX #$BBAA

    LDA #1        ; write a nonzero to initiate transfer
    STA APU1
    INC A         ; set transfer address to $0200
    STZ APU2
    STA APU3

    LDA #$CC        ; IPL bootrom expects $CC
    STA APU0
:                   ; wait for SPC to mimic it
    CMP APU0 
    BNE :-
; We are ready to transfer the driver

    LDX #0
    STZ tmp0
transfer_driver:
    LDA f:__SPCIMAGE_LOAD__, X
    STA APU1
    LDA tmp0
    STA APU0        
:
    CMP APU0
    BNE :-
    INA 
    STA tmp0
    INX 
    CPX #__SPCIMAGE_SIZE__
    BNE transfer_driver
; transfer is finished, execute program
    STZ APU1
    LDX #$0200
    STX APU2
    INC A
    STA APU0

:
    CMP APU0
    BNE :-

    setxy8
    RTS 
.endproc
;--------------------------------------
.proc load_song ; X = song index
    setaxy8

    JSR spc_bulktransfer    ; pattern data
    ;JSR spc_bulktransfer    ; instrument data
    ;JSR spc_bulktransfer    ; sample directory
    ;JSR spc_bulktransfer    ; samples
    RTS
.endproc
;--------------------------------------
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
;--------------------------------------
.proc play_song ; SPC will init song
    setaxy8
    LDA #SPC_PLAY
    STA APU0
:
    LDA APU1
    CMP #SPC_PLAY
    BNE :-

    STZ APU0                ; reset ports
    STZ APU1
    RTS
.endproc 
;--------------------------------------
.proc spc_tick
    setaxy8
    LDA #SPC_TICK
    STA APU0
:
    LDA APU1
    CMP #SPC_TICK
    BNE :-

    STZ APU0        ; reset ports
    STZ APU1
    RTS
.endproc
;--------------------------------------

