.exportzp int16_arg1
.exportzp int16_arg2
.exportzp int16_res

.export int16_neg
.export int16_equ
.export int16_add
.export int16_mul

int16_arg1	= $fb
int16_arg2	= $fd
int16_res	= $9e

.code

int16_neg:
		lda	#$ff
		eor	int16_arg1+1
		sta	int16_res+1
		lda	#$ff
		eor	int16_arg1
		sta	int16_res
		inc	int16_res
		bne	i16n_out
		inc	int16_res+1
i16n_out:	rts

int16_equ:
		ldx	#$0
		stx	int16_res+1
		lda	int16_arg1
		cmp	int16_arg2
		bne	i16e_false
		lda	int16_arg1+1
		cmp	int16_arg2+1
		bne	i16e_false
		inx
i16e_false:	stx	int16_res
		rts
		
int16_add:
		lda	int16_arg1
		clc
		adc	int16_arg2
		sta	int16_res
		lda	int16_arg1+1
		adc	int16_arg2+1
		sta	int16_res+1
		rts

int16_mul:
		lda	#$0
		sta	int16_res
		sta	int16_res+1
		ldx	#$10
i16m_loop:	lsr	int16_arg1+1
		ror	int16_arg1
		bcc	i16m_noadd
		lda	int16_arg2
		clc
		adc	int16_res
		sta	int16_res
		lda	int16_arg2+1
		adc	int16_res+1
		sta	int16_res+1
i16m_noadd:	asl	int16_arg2
		rol	int16_arg2+1
		dex
		bpl	i16m_loop
		rts

