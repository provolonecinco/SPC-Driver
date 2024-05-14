.global spc_boot, spc_bulktransfer
.globalzp SPC_transfer_pointer, SPC_transfer_size, SPC_target_addr

; Communication flags
SPC_ENDCOMM     =   1 << 7  ; Used on Port 3

; Opcodes
SPC_BULK_TRANSFER   =   $80