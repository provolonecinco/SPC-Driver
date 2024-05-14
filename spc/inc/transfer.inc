; TODO - define transfer protocol, etc
; as of now: Bit 7 of CPU3 serves as a flag for SPC availability in transfer requests
;   
;   PORT0 - Opcode/Request
;
;   SNES Opcodes
;   $80 - Transfer Bulk Data
;       Expect 2 bytes folllowing for pointer into SPC memory
;       Port assignment during transfers:
;       P0: Unused | P1: SNES Data in | P2: SPC Mimic Data out | P3: Transfer Flags (SNES -> Bit 7: End Transfer)
;           
;   $81 - Unused
;   $82 - Unused
;   $83 - Unused
;   $84 - Unused
;   $85 - Unused
;   $86 - Unused
;   $87 - Unused
;   $88 - Unused

