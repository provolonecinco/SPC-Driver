.global spc_boot, load_song, play_song
.globalzp SPC_transfer_pointer, SPC_transfer_size, SPC_target_addr

; Opcodes
SPC_TRANSFER    =   $80
SPC_START       =   $81

; Communication flags
SPC_ENDCOMM     =   1 << 7  ; Used on Port 3
