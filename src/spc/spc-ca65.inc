; Super Nintendo SPC-700 program assembly using ca65

;.ifndef SPC_CA65_INC ; ca65 still barfs on file second time through with this, ugh
SPC_CA65_INC = 1

.setcpu "none"

.ifndef DEFAULT_ABS
	DEFAULT_ABS = 0
.endif

.ifndef WARN_DEFAULT_ABS
	WARN_DEFAULT_ABS = 0
.endif

.if WARN_DEFAULT_ABS
	.define _op_warn_default_abs .assert 0, warning, "Defaulting to absolute addressing"
.else
	.define _op_warn_default_abs
.endif

;**** OP a, src
;**** OP dest, a

; d, !a, (X), [d+X], 
.macro _op_a op, val
	.if .xmatch (.left (1, {val}), !)
		.if .xmatch (.right (2, {val}), +X)
			.byte $15+op ; !a+X
			.word .mid (1, .tcount ({val})-3, {val})
		.elseif .xmatch (.right (2, {val}), +Y)
			.byte $16+op ; !a+Y
			.word .mid (1, .tcount ({val})-3, {val})
		.else
			.byte $05+op ; !a
			.word .right (.tcount ({val})-1, {val})
		.endif
	.elseif .xmatch (.left (1, {val}), [)
		.if .xmatch (.right (3, {val}), +X])
			.byte $07+op, .mid (1, .tcount ({val})-4, {val}) ; [d+X]
		.elseif .xmatch (.right (3, {val}), ]+Y)
			.byte $17+op, .mid (1, .tcount ({val})-4, {val}) ; [d]+Y
		.else
			.assert 0, error, "unrecognized [] addressing mode"
		.endif
	.elseif .xmatch ({val}, {(X)})
		.byte $06+op ; (X)
	.elseif ::DEFAULT_ABS && (!.xmatch (.left (1, {val}), <))
		_op_warn_default_abs
		.if .xmatch (.right (2, {val}), +X)
			.byte $15+op ; a+X
			.word .left (.tcount ({val})-2, {val})
		.elseif .xmatch (.right (2, {val}), +Y)
			.byte $16+op ; a+Y
			.word .left (.tcount ({val})-2, {val})
		.else
			.byte $05+op ; a
			.word val
		.endif
	.elseif .xmatch (.right (2, {val}), +X)
		.byte $14+op, .left (.tcount ({val})-2, {val}) ; d+X
	.else
		.byte $04+op, val ; d
	.endif
.endmacro

.macro _op_imm op, val
	.if .xmatch (.left (1, {val}), #)
		.byte $08+op, .right (.tcount ({val})-1, {val}) ; #
	.else
		_op_a op, {val}
	.endif
.endmacro

.macro _arith_a op, dest, src
	.if .xmatch (.left (1, {dest}), A)
		_op_imm op, src ; a, src
	.elseif .xmatch (.left (1, {src}), #)
		.byte $18+op, .right (.tcount ({src})-1, {src}), dest ; d, #
	.elseif .xmatch ({dest}, {(x)}) && .xmatch ({src}, {(y)})
		.byte $19+op ; (x), (y)
	.else
		.byte $09+op, src, dest ; dd, ds
	.endif
.endmacro

.define or   _arith_a $00, ; dest, src
.define and_ _arith_a $20, ; dest, src
.define eor_ _arith_a $40, ; dest, src
.define adc_ _arith_a $80, ; dest, src
.define sbc_ _arith_a $A0, ; dest, src

;**** MOV dest, src

.macro _mov_a op, op_xplus, val
	.if .xmatch ({val}, {(X)+})
		.byte op_xplus ; (X)+
	.elseif .xmatch ({val}, X)
		.byte op-$63 ; x
	.elseif .xmatch ({val}, Y)
		.byte op-$03 ; y
	.else
		_op_imm op, {val}
	.endif
.endmacro

.macro _mov_y op, val
	.if .xmatch (.left (1, {val}), !)
		.byte $ec-op
		.word .right (.tcount ({val})-1, {val})
	.elseif .xmatch (.right (2, {val}), +X)
		.byte $fb-op, .left (.tcount ({val})-2, {val})
	.elseif ::DEFAULT_ABS && (!.xmatch (.left (1, {val}), <))
		_op_warn_default_abs
		.byte $ec-op
		.word val
	.else
		.byte $eb-op, val
	.endif
.endmacro

.macro _mov_x op, val
	.if .xmatch (.left (1, {val}), !)
		.byte $e9-op
		.word .right (.tcount ({val})-1, {val})
	.elseif .xmatch (.right (2, {val}), +Y)
		.byte $f9-op, .left (.tcount ({val})-2, {val})
	.elseif ::DEFAULT_ABS && (!.xmatch (.left (1, {val}), <))
		_op_warn_default_abs
		.byte $e9-op
		.word val
	.else
		.byte $f8-op, val
	.endif
.endmacro

.macro mov dest, src
	.if .xmatch ({dest}, Y)
		.if .xmatch (.left (1, {src}), #)
			.byte $8d, .right (.tcount ({src})-1, {src})
		.elseif .xmatch ({src}, A)
			.byte $fd ; a (inconsistent encoding)
		.else
			_mov_y 0, {src}
		.endif
	.elseif .xmatch ({dest}, A)
		_mov_a $e0, $BF, src ; MOV A, src
	.elseif .xmatch ({src}, A)
		_mov_a $c0, $AF, dest ; MOV dest, A
	.elseif .xmatch ({dest}, X)
		.if .xmatch (.left (1, {src}), #)
			.byte $cd, .right (.tcount ({src})-1, {src})
		.elseif .xmatch ({src}, SP)
			.byte $9d
		.else
			_mov_x 0, src
		.endif
	.elseif .xmatch ({src}, X)
		.if .xmatch ({dest}, SP)
			.byte $BD
		.else
			_mov_x $20, dest
		.endif
	.elseif .xmatch ({src}, Y)
		_mov_y $20, {dest}
	.elseif .xmatch (.left (1, {src}), #)
		.byte $8f, .right (.tcount ({src})-1, {src}), dest
	.else
		.byte $fa, src, dest
	.endif
.endmacro

;**** CMP src1, src2

.macro _cmp_xy op, immop, val
	.if .xmatch (.left (1, {val}), #)
		.byte immop, .right (.tcount ({val})-1, {val}) ; #
	.elseif .xmatch (.left (1, {val}), !)
		.byte $1e+op ; !a
		.word .right (.tcount ({val})-1, {val})
	.elseif ::DEFAULT_ABS && (!.xmatch (.left (1, {val}), <))
		_op_warn_default_abs
		.byte $1e+op ; a
		.word val
	.else
		.byte $3e+op, val ; d
	.endif
.endmacro

.macro cmp_ dest, src
	.if .xmatch ({dest}, X)
		_cmp_xy 0, $c8, {src}
	.elseif .xmatch ({dest}, Y)
		_cmp_xy $40, $ad, {src}
	.else
		_arith_a $60, dest, src
	.endif
.endmacro

;**** RMW dest

.macro _op_shift op, val
	.if .xmatch ({val}, A)
		.byte $1c+op ; A
	.elseif .xmatch (.left (1, {val}), !)
		.byte $0c+op ; !a
		.word .right (.tcount ({val})-1, {val})
	.elseif .xmatch (.right (2, {val}), +X)
		.byte $1b+op, .left (.tcount ({val})-2, {val})
	.elseif ::DEFAULT_ABS && (!.xmatch (.left (1, {val}), <))
		_op_warn_default_abs
		.byte $0c+op
		.word val
	.else
		.byte $0b+op, val
	.endif
.endmacro

.macro _inc_dec op, val
	.if .xmatch ({val}, X)
		.byte $1d+op ; x
	.elseif .xmatch ({val}, Y)
		.byte $dc+op ; y
	.else
		_op_shift $80+op, {val}
	.endif
.endmacro

.define dec_ _inc_dec  $00, ; val
.define inc_ _inc_dec  $20, ; val
.define lsr_ _op_shift $40, ; val
.define asl_ _op_shift $00, ; val
.define rol_ _op_shift $20, ; val
.define ror_ _op_shift $60, ; val

;**** PUSH/POP

.macro _push_pop op, val
	.if .xmatch ({val}, A)
		.byte $2d+op
	.elseif .xmatch ({val}, X)
		.byte $4d+op
	.elseif .xmatch ({val}, Y)
		.byte $6d+op
	.elseif .xmatch ({val}, PSW)
		.byte $0d+op
	.else
		.assert 0, error, "invalid register"
	.endif
.endmacro

.define push _push_pop $00,
.define pop  _push_pop $81,

;**** SET1/CLR1

.macro _op_bit op, bitval, val
	.local @begin
@begin:
	.repeat .tcount ({val}), i
		.if .xmatch (.mid (i, 1, {val}), .)
			.byte op + (bitval * .right (.tcount ({val})-(i+1), {val}))
			.byte .left (i, {val})
		.endif
	.endrepeat
	; TODO: report error during assembly rather than linking
	.assert (*-@begin) = 2, error, "unsupported addressing mode"
.endmacro

.define set1 _op_bit $02, $20,
.define clr1 _op_bit $12, $20,

;**** Branch

.macro _branch_offset instr, target
	.local @distance, @next
	@distance = (target) - @next
	instr
	.assert @distance >= -128 && @distance <= 127, error, "branch out of range"
	.byte <@distance
@next:
.endmacro

.macro _op_branch inst, target
	_branch_offset {.byte inst}, target
.endmacro

.macro bbs val, target
	_branch_offset {_op_bit $03, $20, val}, target
.endmacro

.macro bbc val, target
	_branch_offset {_op_bit $13, $20, val}, target
.endmacro

.macro dbnz val, target
	.if .xmatch ({val}, Y)
		_op_branch $fe, target
	.else
		_op_branch {$6e, val}, (target)
	.endif
.endmacro

.macro cbne val, target
	.if .xmatch (.right (2, {val}), +X)
		_branch_offset {.byte $de, .left (.tcount ({val})-2, {val})}, target
	.else
		_branch_offset {.byte $2e, val}, target
	.endif
.endmacro

.define bpl _op_branch $10, ; target
.define bra _op_branch $2f, ; target
.define bmi _op_branch $30, ; target
.define bvc _op_branch $50, ; target
.define bvs _op_branch $70, ; target
.define bcc _op_branch $90, ; target
.define bcs _op_branch $B0, ; target
.define bne _op_branch $D0, ; target
.define beq _op_branch $f0, ; target

;**** OP !abs

.macro _op_abs op, val; ****
	.if .xmatch (.left (1, {val}), !)
		.byte op
		.word .right (.tcount ({val})-1, {val})
	.elseif ::DEFAULT_ABS && (!.xmatch (.left (1, {val}), <))
		_op_warn_default_abs
		.byte op
		.word val
	.else
		.assert 0, error, "unsupported addressing mode"
	.endif
.endmacro

.define tset1 _op_abs $0E, ; abs
.define tclr1 _op_abs $4E, ; abs
.define call  _op_abs $3F, ; abs

.macro jmp_ val; ****
	.if .xmatch (.left (2, {val}), [!) && .xmatch (.right (3, {val}), +X])
		.byte $1f
		.word .mid (2, .tcount ({val})-5, {val})
	.elseif ::DEFAULT_ABS && .xmatch (.left (1, {val}), [) && .xmatch (.right (3, {val}), +X])
		_op_warn_default_abs
		.byte $1f
		.word .mid (1, .tcount ({val})-4, {val})
	.else
		_op_abs $5f, val
	.endif
.endmacro

;**** $1FFF.bit

.macro _op_mbit op, val
	.local @begin, @addr
@begin:
	.repeat .tcount ({val}), i
		.if .xmatch (.mid (i, 1, {val}), .)
			@addr = .left (i, {val})
			.assert 0 <= @addr && @addr <= $1FFF, error, "address exceeds 13 bits"
			.byte op
			.word (.right (.tcount ({val})-(i+1), {val}))*$2000 + @addr
		.endif
	.endrepeat
	; TODO: report error during assembly rather than linking
	.assert (*-@begin) = 3, error, "unsupported addressing mode"
.endmacro

.macro _op_mbit_c op, carry, val
	.if .xmatch (carry, C)
		_op_mbit op, val
	.else
		.assert 0, error, "destination must be C"
	.endif
.endmacro

.macro _op_mbit_inv op, carry, val
	.if .xmatch (.left (1, {val}), /)
		_op_mbit_c op+$20, carry, .right (.tcount ({val})-1, {val})
	.else
		_op_mbit_c op, carry, val
	.endif
.endmacro

.define not1 _op_mbit     $EA, ; abs.bit
.define or1  _op_mbit_inv $0A, ; abs.bit
.define and1 _op_mbit_inv $4A, ; abs.bit
.define eor1 _op_mbit_inv $8A, ; abs.bit

.macro mov1 dest, src
	.if .xmatch ({src}, C)
		_op_mbit_c $CA, src, dest
	.else
		_op_mbit_c $AA, dest, src
	.endif
.endmacro

;**** OP dp

.macro _op_dp op, dp
	.byte op, (dp)
.endmacro

.define decw _op_dp $1a, ; dp
.define incw _op_dp $3a, ; dp

;**** OP reg

.macro _op_one_reg op, reg, err, val
	.if .xmatch ({val}, reg)
		.byte op
	.else
		.assert 0, error, err
	.endif
.endmacro

.macro _op_w op, reg, val
	_op_one_reg op, YA, "only supports YA", reg
	.byte val
.endmacro

.define cmpw _op_w $5A, ; dp
.define addw _op_w $7A, ; dp
.define subw _op_w $9A, ; dp

.macro movw dest, src
	.if .xmatch ({src}, YA)
		_op_w $DA, src, dest
	.else
		_op_w $BA, dest, src
	.endif
.endmacro

.macro div dest, src
	.if .xmatch ({dest}, YA) && .xmatch ({src}, X)
		.byte $9e
	.else
		.assert 0, error, "only supports YA, X"
	.endif
.endmacro

.define xcn _op_one_reg $9f, a, "only supports A",
.define das _op_one_reg $BE, a, "only supports A",
.define daa _op_one_reg $DF, a, "only supports A",
.define mul _op_one_reg $CF, ya, "only supports YA",

;**** Unique

.macro tcall val
	.assert 0 <= (val) && (val) <= 15, error, "invalid value"
	.byte (val)*$10 + $01
.endmacro

.macro pcall val
	.byte $4f, (val)
.endmacro

;**** Implied

.macro _op_implied op
	.byte op
.endmacro

.define nop		_op_implied $00
.define brk		_op_implied $0f
.define clrp	_op_implied $20
.define setp	_op_implied $40
.define clrc	_op_implied $60
.define ret		_op_implied $6f
.define reti	_op_implied $7f
.define setc	_op_implied $80
.define ei		_op_implied $A0
.define di		_op_implied $C0
.define clrv	_op_implied $E0
.define notc	_op_implied $ED
.define sleep	_op_implied $ef
.define stop	_op_implied $ff

.ifndef CASPC_65XX
	.define and and_
	.define eor eor_
	.define adc adc_
	.define sbc sbc_
	.define cmp cmp_
	
	.define dec dec_
	.define inc inc_
	.define lsr lsr_
	.define asl asl_
	.define rol rol_
	.define ror ror_
	
	.define jmp jmp_
.endif

; add uppercase syntax
.define NOP nop		
.define BRK brk		
.define CLRP clrp	
.define SETP setp	
.define CLRC clrc	
.define RET ret		
.define RETI reti	
.define SETC setc	
.define EI ei		
.define DI di		
.define CLRV clrv	
.define NOTC notc	
.define SLEEP sleep	
.define STOP stop	
.define CMP cmp_
.define DEC dec_
.define INC inc_
.define LSR lsr_
.define ASL asl_
.define ROL rol_
.define ROR ror_
.define JMP jmp
.define MOV mov
.define XCN xcn 
.define DAS das 
.define DAA daa 
.define MUL mul 
.define OR or   
.define AND and_ 
.define EOR eor_ 
.define ADC adc_
.define SBC sbc_
.define PUSH push 
.define POP pop  
.define SET1 set1 
.define CLR1 clr1 
.define BPL bpl 
.define BRA bra
.define BMI bmi 
.define BVC bvc 
.define BVS bvs 
.define BCC bcc 
.define BCS bcs 
.define BNE bne 
.define BEQ beq
.define BBS bbs 
.define BBC bbc
.define TSET1 tset1 
.define TCLR1 tclr1 
.define CALL call 
.define NOT1 not1 
.define OR1 or1  
.define AND1 and1 
.define EOR1 eor1 
.define DECW decw 
.define INCW incw 
.define CMPW cmpw 
.define ADDW addw 
.define SUBW subw 
.define MOVW movw