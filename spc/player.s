.setcpu "none"
.include "inc/spc.inc"
.include "inc/driver.inc"
.include "inc/opcode.inc"
.segment "ZEROPAGE"
; DSP Buffer ------------------------ ;
sSRCN:           .res 8
sADSR1:          .res 8
sADSR2:          .res 8
sGAIN:           .res 8
sPITCHL:        .res 8
sPITCHH:        .res 8
sLVOL:          .res 8
sRVOL:          .res 8
sKON:           .res 1
sKOFF:          .res 1
; Driver-Specific --------------------;
frame:          .res 1 ; index into pattern table
patternbase:    .res 2
patternptr:     .res 2 ; pathead + frame + channel
instptr:        .res 2
tick:           .res 1
counter:        .res 1 ; Engine speed, ticks down (0=update)
chwait:         .res 8
;--------------------------------------
.segment "DRIVER"
;--------------------------------------
.proc driver_update ; unload shadow buffers
    MOV A, CPU0     ; Mimic on Port 1
    MOV CPU1, A

    DEC counter
    BNE :+
    JMP !process_channels
    JMP !done
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
    MOV X, #0
    MOV Y, #0
    MOV A, frame 
    CLRC 
    ADDW YA, patternbase
    MOVW patternptr, YA
read_row:                   ; (X=channel number)
    MOV A, chwait + X
    BEQ read_opcode
    DEC chwait + X
    BRA !next
read_opcode:
    MOV Y, #0     
    MOV A, [patternptr] + Y ; Get opcode

    MOV Y, A
    MOV A, !op_tablelo + Y
    MOV tmp0, A
    MOV A, !op_tablehi + Y
    MOV tmp1, A

    INCW patternptr
    PUSH X
    MOV X, #0
    JMP [!tmp0 + X]             ; process opcode
next:
    INC X
    MOV Y, #0
    MOV A, X
    CLRC
    ADC A, frame 
    ADDW YA, patternbase
    MOVW patternptr, YA

    CMP X, !0501            ; number of channels
    BNE read_row
done:
    MOV A, !$0500           ; Reset speed counter
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
    MOV patternbase, A

    MOV A, #>pat0
    MOV patternbase + 1, A
    
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
    .byte $02, $02 ; KON, C3
    .byte $04, $00 ; INST, 0 
    .byte $10, $7F, $7F ; VOL, L+R = max
    .byte $01, $07 ; Silence, 8 rows
    .byte $02, $12 ; KON, something
    .byte $01, $07 ; Silence, 8
    .byte $0B, $00 ; JUMP, Frame 0 (loop)
;--------------------------------------
inst0:  
    .byte 0         ; sample #
    .byte $9F, $F7  ; ADSR
    .byte 0         ; GAIN
;--------------------------------------
pitch_8:  ; pitchgen.py
    .word $43D,  $47E,  $4C2,  $50A,  $557,  $5A8,  $5FE,  $65A,  $6BA,  $721,  $78D,  $800
freq_table: ;tuned to B+21c
    .word $87A,  $8FB,  $984,  $A15,  $AAE,  $B51,  $BFD,  $CB3,  $D75,  $E41,  $F1A,  $1000
pitch_32: 
    .word $10F4,  $11F6,  $1307,  $1429,  $155C,  $16A1,  $17FA,  $1967,  $1AE9,  $1C83,  $1E35,  $2000
;--------------------------------------
sample0:
    .incbin "samples/guitar16.brr" ; test samples
;--------------------------------------