; Definition of the internal header and vectors at $00FFC0-$00FFFF
.include "src/snes.inc"
.include "src/defines.inc"
.smart
.p816


.segment "HEADER"
romname:
    ; The ROM name must be no longer than 21 characters.
    .byte "yoey sound           "
map_mode:
    .byte $30                                       ; LoROM, FastROM (120ns)
    .byte $00                                       ; 00: no extra RAM; 02: RAM with battery
    .byte MEMSIZE_256KB                             ; ROM size
    .byte MEMSIZE_NONE                              ; backup RAM size 
    .byte REGION_AMERICA
    .byte $33                                       ; publisher id, or $33 for see 16 bytes before header
    .byte $00                                       ; ROM revision number
    .word $0000                                     ; sum of all bytes will be poked here after linking
    .word $0000                                     ; $FFFF minus above sum will also be poked here
    .res 4                                          ; unused vectors
    .addr cop_handler, brk_handler, abort_handler   ; clcxce mode vectors
    .addr NMI_stub, $FFFF, IRQ_stub                 ; reset unused because reset switches to 6502 mode
    .res 4                                          ; more unused vectors
    ; 6502 mode vectors
    ; brk unused because 6502 mode uses irq handler and pushes the
    ; X flag clear for /IRQ or set for BRK
    .addr ecop_handler, $FFFF, eabort_handler
    .addr enmi_handler, RESET, eirq_handler

  .segment "ZEROPAGE"
framecounter:           .res 1
joy0_status:            .res 2
joy0_held:              .res 2
temp:                   .res 4
pointer:                .res 3
SPC_transfer_pointer:   .res 3
SPC_transfer_counter:   .res 1
SPC_transfer_size:      .res 2

.segment "LORAM"

.segment "HIRAM"
  
.segment "BANK0"
    .include "src/vectorstub.asm"
    .include "src/init.asm"
    .include "src/main.asm"
    .include "src/nmi.asm"
    .include "src/spc_comm.asm"

.segment "BANK1"
spc_driver:
    .incbin "src/spc/driver.bin"
spc_driver_end:
