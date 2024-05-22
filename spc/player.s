.include "inc/spc.inc"
.include "inc/driver.inc"

.segment "ZEROPAGE"
; DSP Buffer ------------------------ ;
buf_CLVOL:          .res 8
buf_CRVOL:          .res 8
buf_CFREQLO:        .res 8
buf_CFREQHI:        .res 8
buf_LVOL:           .res 1
buf_RVOL:           .res 1
buf_LECHOVOL:       .res 1
buf_RECHOVOL:       .res 1
buf_KON:            .res 1
buf_KOFF:           .res 1
; Driver-Specific --------------------;
frame:              .res 1 ; index into pattern table
patternindex:       .res 8 ; per-channel index into pattern
patternptr:         .res 2
instptr:            .res 2
tick:               .res 1
counter:            .res 1 ; Engine speed, ticks down (0=update)
;--------------------------------------
.segment "DRIVER"
opcode_table: ; opcode jump table
    .word $0000
;--------------------------------------
.proc driver_update ; unload shadow buffers
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    DEC counter
    BNE :+
    JMP !process_row
    JMP !done
:
    JMP !process_active_effects
done:
    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc
;--------------------------------------
.proc process_row
    INC tick

    MOV A, !$0500 + 0 ; Reset speed counter
    MOV counter, A

    JMP !driver_update::done
.endproc
;--------------------------------------
.proc process_active_effects
    JMP !driver_update::done
.endproc
;--------------------------------------
.proc song_init
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    MOV A, !$0500 + 0
    MOV counter, A

    MOV A, !$0500 + 2
    MOV patternptr, A

    MOV A, !$0500 + 3
    MOV patternptr + 1, A
    
    MOV A, !$0500 + 4
    MOV instptr, A
    
    MOV A, !$0500 + 5
    MOV instptr + 1, A
   

    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc 
;--------------------------------------
.segment "DIR" ; $0400
directory:
    .word sample0, sample0 + 144      ; BRR Start, BRR Loop addr
;--------------------------------------
.segment "HEADER" ; 16B Song Header
song0:    
    .byte 8             ; Speed (Ticks/Row)
    .byte 1             ; Number of channels
    .word pattern_table
    .word inst_table
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;--------------------------------------
.segment "SONGDATA"
pattern_table:
    .word pat0  
inst_table:
    .word inst0
;--------------------------------------
pat0:
    .byte 0, 0, $7F, 0 ; (note=0), (inst=0), (vol=max), (length=indefinite)
;--------------------------------------
inst0:  
    .byte 0         ; sample #
    .byte $9F, $F7  ; ADSR
;--------------------------------------
pitch_8:  ; pitchgen.py
    .word $43D,  $47E,  $4C2,  $50A,  $557,  $5A8,  $5FE,  $65A,  $6BA,  $721,  $78D,  $800
pitch_16: ;tuned to B+21c
    .word $87A,  $8FB,  $984,  $A15,  $AAE,  $B51,  $BFD,  $CB3,  $D75,  $E41,  $F1A,  $1000
pitch_32: 
    .word $10F4,  $11F6,  $1307,  $1429,  $155C,  $16A1,  $17FA,  $1967,  $1AE9,  $1C83,  $1E35,  $2000
;--------------------------------------
sample0:
    .incbin "samples/guitar16.brr" ; test samples
;--------------------------------------