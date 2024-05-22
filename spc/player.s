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
patindex:           .res 8 ; per-channel index into pattern
patternptr:         .res 2
instptr:            .res 2
tick:               .res 1
counter:            .res 1 ; Engine speed, ticks down (0=update)
chanwait:           .res 8
;--------------------------------------
.segment "DRIVER"
op_tablelo: ; opcode jump table
    .byte 0, <opSilence, <opKON, <opKOFF, <opINST, <opNOTE, <opPORTAMENTO, <opVIBRATO, <opTREMOLO, <opPAN, <opVSLIDE, <opJUMP
    .byte <opNOISE, <opECHO, <opPMOD, <opNOISEFREQ, <opLVOL, <opRVOL, <opTICK, <opNSLIDEUP, <opNSLIDEDOWN, <opDETUNE, <opSTOP
op_tablehi:
    .byte 0, >opSilence, >opKON, >opKOFF, >opINST, >opNOTE, >opPORTAMENTO, >opVIBRATO, >opTREMOLO, >opPAN, >opVSLIDE, >opJUMP
    .byte >opNOISE, >opECHO, >opPMOD, >opNOISEFREQ, >opLVOL, >opRVOL, >opTICK, >opNSLIDEUP, >opNSLIDEDOWN, >opDETUNE, >opSTOP
;--------------------------------------
.proc driver_update ; unload shadow buffers
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    DEC counter
    BNE :+
    BRA !process_channels
    BRA !done
:
    JMP !process_active_effects
done:
    CALL !write_dsp
    MOV CPU0, #0    ; Reset I/O Ports
    MOV CPU1, #0
    JMP !main
.endproc
;--------------------------------------
.proc process_channels
    INC tick
    MOV Y, #0
read_row:                   ; (Y=channel number)
    CMP #0, chanwait + Y
    BEQ read_opcode
    DEC chanwait + Y
    BRA !next
read_opcode:
    MOV X, patindex + Y        
    MOV A, [patternptr + X] ; Get opcode

    MOV X, A
    MOV A, !op_tablelo + X
    MOV tmp0, A
    MOV A, !op_tablehi + X
    MOV tmp1, A

    INC patindex + Y
    MOV X, patindex + Y
    JMP [!tmp0]             ; process opcode
next:
    INC Y
    CMP Y, !0501            ; number of channels
    BNE read_opcode
done:
    MOV A, !$0500 + 0 ; Reset speed counter
    MOV counter, A

    JMP !driver_update::done
.endproc
;--------------------------------------
.proc process_active_effects
    JMP !driver_update::done
.endproc
;--------------------------------------
.proc write_dsp
    RET
.endproc
;--------------------------------------
.proc song_init
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    MOV counter, #1 ; Process row immediately

    MOV A, #<pat0
    MOV patternptr, A

    MOV A, #>pat0
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
    .byte $02, $30 ; KON, C3
    .byte $04, $00 ; INST, 0 
    .byte $10, $7F ; LVOL, max
    .byte $11, $7F ; RVOL, max
    .byte $01, $08 ; Silence, 8 rows
    .byte $02, $20 ; KON, C2
    .byte $01, $08 ; Silence, 4 rows
    .byte $0B, $00 ; JUMP, Frame 0 (loop)
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