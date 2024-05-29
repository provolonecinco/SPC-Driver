.globalzp tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7
.global main

.include "spc-ca65.inc"

TEST    = $F0 ; Testing functions (W)
CONTROL = $F1 ; Timer, I/O and ROM Control (W
DSPADDR = $F2 ; DSP Register Index (R/W)
DSPDATA = $F3 ; DSP Register Data (R/W)                 
CPU0    = $F4 ; CPU Input and Output Register 0 (R and W)
CPU1    = $F5 ; CPU Input and Output Register 1 (R and W)
CPU2    = $F6 ; CPU Input and Output Register 2 (R and W)
CPU3    = $F7 ; CPU Input and Output Register 3 (R and W)
AUX4    = $F8 ; External I/O Port P4 (S-SMP Pins 34-27) (R/W) (unused)
AUX5    = $F9 ; External I/O Port P5 (S-SMP Pins 25-18) (R/W) (unused)
T0DIV   = $FA ; Timer 0 Divider (for 8000Hz clock source) (W)
T1DIV   = $FB ; Timer 1 Divider (for 8000Hz clock source) (W)
T2DIV   = $FC ; Timer 2 Divider (for 64000Hz clock source) (W)
T0OUT   = $FD ; Timer 0 Output (R)
T1OUT   = $FE ; Timer 1 Output (R)
T2OUT   = $FF ; Timer 2 Output (R)

VOLL    = $00 ; Left volume for Voice 0..7 (R/W)
VOLR    = $01 ; Right volume for Voice 0..7 (R/W)
PITCHL  = $02 ; Pitch scaler for Voice 0..7, lower 8bit (R/W)
PITCHH  = $03 ; Pitch scaler for Voice 0..7, upper 6bit (R/W)
SRCN    = $04 ; Source number for Voice 0..7 (R/W)
ADSR1   = $05 ; ADSR settings for Voice 0..7, lower 8bit (R/W)
ADSR2   = $06 ; ADSR settings for Voice 0..7, upper 8bit (R/W)
GAIN    = $07 ; Gain settings for Voice 0..7 (R/W)
ENVX    = $08 ; Current envelope value for Voice 0..7 (R)
OUTX    = $09 ; Current sample value for Voice 0..7 (R)
;NA      = $0A ; Unused (8 bytes of general-purpose RAM) (R/W)
;NA      = $0B ; Unused (8 bytes of general-purpose RAM) (R/W)
MVOLL   = $0C ; Left channel master volume (R/W)
MVOLR   = $1C ; Right channel master volume (R/W)
EVOLL   = $2C ; Left channel echo volume (R/W)
EVOLR   = $3C ; Right channel echo volume (R/W)
KON     = $4C ; Key On Flags for Voice 0..7 (W)
KOFF    = $5C ; Key Off Flags for Voice 0..7 (R/W)
FLG     = $6C ; Reset, Mute, Echo-Write flags and Noise Clock (R/W)
ENDX    = $7C ; Voice End Flags for Voice 0..7 (R) (W=Ack)
EFB     = $0D ; Echo feedback volume (R/W)
;NA      = $1D ; Unused (1 byte of general-purpose RAM) (R/W)
PMON    = $2D ; Pitch Modulation Enable Flags for Voice 1..7 (R/W)
NON     = $3D ; Noise Enable Flags for Voice 0..7 (R/W)
EON     = $4D ; Echo Enable Flags for Voice 0..7 (R/W)
DIR     = $5D ; Sample table address (R/W)
ESA     = $6D ; Echo ring buffer address (R/W)
EDL     = $7D ; Echo delay (ring buffer size) (R/W)
;NA      = $0E ; Unused (8 bytes of general-purpose RAM) (R/W)
FIRx    = $0F ; Echo FIR filter coefficient 0..7 (R/W)

CH0     = $00 ; AND table for readability
CH1     = $10
CH2     = $20
CH3     = $30
CH4     = $40
CH5     = $50
CH6     = $60
CH7     = $70

.macro stya addr
    .local addr1
    addr1 = addr
      .assert addr <= $00FE, error, "stya works only in zero page"
      movw <addr, ya
    .endmacro

.macro dmov reg, data
	mov DSPADDR, #reg
	mov DSPDATA, data
.endmacro
 
SPC_BUSY        = 7 ; used on CPU3
