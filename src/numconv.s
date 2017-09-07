.export numtostring
.export stringtonum
.export nc_string
.export nc_num

.code

stringtonum:
		ldx	#$ff
stn_strlen:	inx
		lda	nc_string,x
		bne	stn_strlen
		ldy	#$6
stn_copybcd:	dey
		dex
		bmi	stn_fillzero
		lda	nc_string,x
		and	#$f
		sta	nc_string,y
		bpl	stn_copybcd
stn_fillzero:	lda	#$0
		sta	nc_string,y
		dey
		bpl	stn_fillzero
		lda	#$0
		sta	nc_num
		sta	nc_num+1
		ldx	#$10
stn_loop:	ldy	#$7b
		clc
stn_rorloop:	lda	nc_string-$7a,y
		bcc	stn_skipbit
		ora	#$10
stn_skipbit:	lsr	a
		sta	nc_string-$7a,y
		iny
		bpl	stn_rorloop
		ror	nc_num+1
		ror	nc_num
		dex
		bne	stn_sub
		rts
stn_sub:	ldy	#$4
stn_subloop:	lda	nc_string+1,y
		cmp	#$8
		bmi	stn_nosub
		sbc	#$3
		sta	nc_string+1,y
stn_nosub:	dey
		bpl	stn_subloop
		bmi	stn_loop

numtostring:
		ldx	#$6
		lda	#$0
nts_fillzero:	sta	nc_string-1,x
		dex
		bne	nts_fillzero
		ldx	#$10
nts_bcdloop:	ldy	#$4
nts_addloop:	lda	nc_string+1,y
		cmp	#$5
		bmi	nts_noadd
		adc	#$2
		sta	nc_string+1,y
nts_noadd:	dey
		bpl	nts_addloop
		ldy	#$4
		asl	nc_num
		rol	nc_num+1
nts_rolloop:	lda	nc_string+1,y
		rol	a
		cmp	#$10
		and	#$f
		sta	nc_string+1,y
nts_rolnext:	dey
		bpl	nts_rolloop
		dex
		bne	nts_bcdloop
nts_scan:	cpy	#$5
		beq	nts_copydigits
		iny
		lda	nc_string,y
		beq	nts_scan
nts_copydigits:	ora	#$30
		sta	nc_string,x
		inx
		iny
		cpy	#$6
		beq	nts_done
		lda	nc_string,y
		bcc	nts_copydigits
nts_done:	lda	#$0
		sta	nc_string,x
		rts

.bss

nc_string:	.res	6
nc_num:		.res	2
