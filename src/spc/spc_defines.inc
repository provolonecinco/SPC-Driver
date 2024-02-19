TEST    =   $F0
CONTROL =   $F1
DSPADDR =   $F2
DSPDATA =   $F3
CPU0    =   $F4
CPU1    =   $F5
CPU2    =   $F6
CPU3    =   $F7
T0DIV   =   $F8
T1DIV   =   $F9
T2DIV   =   $FA
T0OUT   =   $FB
T1OUT   =   $FC
T2OUT   =   $FD

DSP_CLVOL    = $00
DSP_CRVOL    = $01
DSP_CFREQLO  = $02  ; Playback frequency in 7.8125 Hz units
DSP_CFREQHI  = $03  ; (ignored 
DSP_CSAMPNUM = $04  
DSP_CATTACK  = $05  ; 7: set; 6-4: decay rate; 3-0: attack rate
DSP_CSUSTAIN = $06  ; 7-5: sustain level; 4-0: sustain decay rate
DSP_CGAIN    = $07  ; Used only when attack is disabled

DSP_LVOL     = $0C
DSP_RVOL     = $1C
DSP_LECHOVOL = $2C
DSP_RECHOVOL = $3C
DSP_KEYON    = $4C
DSP_KEYOFF   = $5C
DSP_FLAGS    = $6C  ; 5: disable echo; 4-0: set LFSR rate
DSP_ECHOFBV  = $0C  ; Echo feedback volume
DSP_FMCH     = $2D  ; Modulate these channels' frequency by the amplitude before it
DSP_NOISECH  = $3D  ; Replace these channels with LFSR noise
DSP_ECHOCH   = $4D  ; Echo comes from these channels
DSP_SAMPDIR  = $5D  ; High byte of base address of sample table

.macro stya addr
    .local addr1
    addr1 = addr
      .assert addr <= $00FE, error, "stya works only in zero page"
      movw <addr, ya
    .endmacro
    
