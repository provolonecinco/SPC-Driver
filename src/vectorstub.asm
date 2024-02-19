; Jumping out of bank $00 is especially important if you're using
; ROMSPEED_120NS.
NMI_stub:
  jml NMI 

IRQ_stub:
  jml IRQ

; Unused exception handlers
cop_handler:
brk_handler:
abort_handler:
ecop_handler:
eabort_handler:
enmi_handler:
eirq_handler:
  rti