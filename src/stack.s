.export stack_push
.export stack_pushres
.export stack_pushsame
.export stack_pop1
.export stack_pop2
.export stack_printtop
.exportzp stackptr

.import nc_num
.import nc_string
.import stringtonum
.import numtostring
.import int16_neg
.importzp int16_arg1
.importzp int16_arg2
.importzp int16_res
 
CHROUT		= $ffd2
STROUT		= $ab1e

stackptr	= $29

.code

stack_push:
		jsr	stringtonum
		ldx	stackptr
		lda	nc_num
		sta	stackl,x
		lda	nc_num+1
		sta	stackh,x
		inc	stackptr
		rts

stack_pushres:
		ldx	stackptr
		lda	int16_res
		sta	stackl,x
		lda	int16_res+1
		sta	stackh,x
		inc	stackptr
		rts

stack_pushsame:
		ldx	stackptr
		lda	stackl-1,x
		sta	stackl,x
		lda	stackh-1,x
		sta	stackh,x
		inc	stackptr
		rts

stack_pop2:
		dec	stackptr
		ldx	stackptr
		lda	stackl,x
		sta	int16_arg2
		lda	stackh,x
		sta	int16_arg2+1

stack_pop1:
		dec	stackptr
		ldx	stackptr
		lda	stackl,x
		sta	int16_arg1
		lda	stackh,x
		sta	int16_arg1+1
		rts

stack_printtop:
		ldx	stackptr
		lda	stackh-1,x
		bpl	spt_out
		jsr	stack_pop1
		jsr	int16_neg
		jsr	stack_pushres
		lda	#'-'
		jsr	CHROUT
		ldx	stackptr
		lda	stackh-1,x
spt_out:	sta	nc_num+1
		lda	stackl-1,x
		sta	nc_num
		jsr	numtostring
		lda	#<nc_string
		ldy	#>nc_string
		jmp	STROUT

.bss

stackl:		.res	$100
stackh:		.res	$100

