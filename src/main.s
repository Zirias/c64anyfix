.import stack_push
.import stack_pushres
.import stack_pushsame
.import stack_pop1
.import stack_pop2
.import stack_printtop
.import int16_neg
.import int16_add
.import int16_mul
.import int16_equ

.import nc_string

.importzp stackptr
.importzp int16_res

.segment "LDADDR"
                .word   $c000

CHROUT		= $ffd2
GETIN		= $ffe4
STROUT		= $ab1e

lineptr		= $26
linelen		= $27
opcount		= $28
opfront		= $4b
opback		= $4c

.code

main:
		ldx	#$0
		stx	stackptr
		stx	lineptr
		stx	linelen
		stx	opcount
		stx	opfront
		stx	opback
		stx	$cc
getkey:		jsr	GETIN
		beq	getkey
		cmp	#$d
		beq	lineend
		cmp	#$20
		bmi	getkey
		ldx	linelen
		sta	linebuf,x
		jsr	CHROUT
		inc	linelen
		bne	getkey
lineend:	dec	$cc
		lda	#$20
		jsr	$ea1c
		lda	#$d
		jsr	CHROUT

evaluate:
		jsr	applyops
		jsr	getnum
		jsr	applyops
		ldx	lineptr
		cpx	linelen
		beq	ev_done
		lda	linebuf,x
		inc	lineptr
		cmp	#$20
		beq	evaluate
		cmp	#'-'
		bne	ev_noneg
		ldx	opback
		lda	#$01
		sta	opqueue,x
		bne	ev_opqinc
ev_noneg:	cmp	#'"'
		bne	ev_nodbl
		ldx	opback
		lda	#$02
		sta	opqueue,x
		bne	ev_opqinc
ev_nodbl:	cmp	#'+'
		bne	ev_noadd
		ldx	opback
		lda	#$81
		sta	opqueue,x
		bne	ev_opqinc
ev_noadd:	cmp	#'*'
		bne	ev_nomul
		ldx	opback
		lda	#$82
		sta	opqueue,x
		bne	ev_opqinc
ev_nomul:	cmp	#'='
		bne	ev_done
		ldx	opback
		lda	#$83
		sta	opqueue,x
ev_opqinc:	inc	opcount
		inc	opback
		bne	evaluate
ev_done:	jmp	stack_printtop

applyops:
		ldx	stackptr
		beq	ao_done
		ldy	opcount
		beq	ao_done
		dex
		beq	ao_unary
ao_fetchfirst:	dec	opcount
		ldx	opfront
		inc	opfront
		lda	opqueue,x
		beq	ao_fetchfirst
		bmi	ao_apply2
		tax
ao_apply1:	dex
		bne	ao_dbl
		jsr	stack_pop1
		jsr	int16_neg
		jsr	stack_pushres
		bne	applyops
ao_dbl:		jsr	stack_pushsame
		bne	applyops
ao_apply2:	and	#$f
		tax
		dex
		bne	ao_noadd
		jsr	stack_pop2
		jsr	int16_add
		jsr	stack_pushres
		bne	applyops
ao_noadd:	dex
		bne	ao_equ
		jsr	stack_pop2
		jsr	int16_mul
		jsr	stack_pushres
		bne	applyops
ao_equ:		jsr	stack_pop2
		jsr	int16_equ
		jsr	stack_pushres
		bne	applyops
ao_unary:	ldy	opfront
		lda	opqueue,y
		beq	ao_search
		bpl	ao_fetchfirst
ao_search:	iny
		cpy	opback
		beq	ao_done
		lda	opqueue,y
		beq	ao_search
		bmi	ao_search
		tax
		lda	#$0
		sta	opqueue,y
		beq	ao_apply1
ao_done:	rts

getnum:
		ldy	#$0
gn_loop:	ldx	lineptr
		cpx	linelen
		beq	gn_done
		lda	linebuf,x
		cmp	#$30
		bmi	gn_done
		cmp	#$3a
		bpl	gn_done
		inc	lineptr
		sta	nc_string,y
		iny
		cpy	#$5
		bne	gn_loop
gn_done:	cpy	#$0
		beq	gn_out
		lda	#$0
		sta	nc_string,y
		jsr	stack_push
gn_out:		rts

.bss

linebuf:	.res	$100

opqueue:	.res	$80

