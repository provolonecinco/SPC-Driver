.global spc_boot, load_song, play_song, spc_tick
.globalzp SPC_transfer_pointer, SPC_transfer_size, SPC_target_addr

; Opcodes (For info, see "spc/inc/driver.inc")
SPC_TRANSFER = $80
SPC_PLAY     = $81
SPC_TICK     = $82

; Communication flags
SPC_ENDCOMM  = 1 << 7  ; Used on Port 3
