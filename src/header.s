.include "inc/main.inc"
;--------------------------------------
.segment "HEADER"
;--------------------------------------
rom_name:
    .res 21
;--------------------------------------
.segment "ROMINFO"
;--------------------------------------
map_mode:
    .byte MAPPER_LOROM | ROMSPEED_120NS ; LoROM, FastROM (120ns)
    .byte MEMSIZE_NONE                  ; 00: no extra RAM; 02: RAM with battery
    .byte MEMSIZE_256KB                 ; ROM size
    .byte MEMSIZE_NONE                  ; backup RAM size 
    .byte REGION_AMERICA
    .byte 0, 0, 0, 0, 0, 0
;--------------------------------------
.segment "VECTORS"
    .addr COP_, BRK_, 0, NMI, 0, IRQ              
    .addr 0, 0, 0, 0, 0, 0, RESET, 0
;--------------------------------------