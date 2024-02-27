; Definition of the internal header and vectors at $00FFC0-$00FFFF
.include "snes.inc"
.include "defines.inc"
.import RESET, NMI, IRQ
.export map_mode

.segment "HEADER"
romname:
    .res 21                                         ; <= 21 bytes
map_mode:
    .byte MAPPER_LOROM | ROMSPEED_120NS             ; LoROM, FastROM (120ns)
    .byte MEMSIZE_NONE                              ; 00: no extra RAM; 02: RAM with battery
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

.segment "BANK0"
    ; Jumping out of bank $00 is especially important if you're using
; ROMSPEED_120NS.
NMI_stub:
  jml NMI 

IRQ_stub:
  jml IRQ

; Unused exception handlers
cop_handler:
brk_handler:
abort_handler:
ecop_handler:
eabort_handler:
enmi_handler:
eirq_handler:
  rti