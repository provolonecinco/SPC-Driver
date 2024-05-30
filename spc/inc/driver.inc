;player.s
.global driver_update
.global pat0
.globalzp frame, pathead, patptr, instptr, tick, counter, chwait, chptr

;   PORT0 - Opcode/Request
;
;   SNES Opcodes
;   $80 - Transfer Bulk Data
;       Expect 2 bytes folllowing for pointer into SPC memory
;       P0: Unused | P1: SNES Data in | P2: SPC Mimic Data out | P3: Transfer Flags (SNES -> Bit 7: End Transfer)
;           
;   $81 - Play Song
;       SPC will read the song header at $0600 and init RAM.
;
;   $82 - Engine Tick
;       SNES controls the tick rate. SPC will advance playback by 1 tick.
;
;   Valid transfer addresses are $0400 and up. 
;

HEADER_BASE = $0600
SONGSPEED   = $0600
NUM_CHAN    = $0601
PAT_HEAD    = $0602
INST_HEAD   = $0604
DIR_BASE    = $0500
