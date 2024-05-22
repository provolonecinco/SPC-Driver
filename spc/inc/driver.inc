;player.s
.global play_sample, song_init, driver_update, process_channels

.globalzp buf_CLVOL, buf_CRVOL, buf_CFREQLO, buf_CFREQHI, buf_LVOL, buf_RVOL, buf_LECHOVOL, buf_RECHOVOL, buf_KON, buf_KOFF
.globalzp frame, patindex, patternptr, instptr, tick, counter, chanwait

;opcodes.s
.global opSilence, opKON, opKOFF, opINST, opNOTE, opPORTAMENTO, opVIBRATO, opTREMOLO, opPAN, opVSLIDE, opJUMP 
.global opNOISE, opECHO, opPMOD, opNOISEFREQ, opLVOL, opRVOL, opTICK, opNSLIDEUP, opNSLIDEDOWN, opDETUNE, opSTOP