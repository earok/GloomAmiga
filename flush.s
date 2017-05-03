flushc	movem.l	a0-a1/d0-d1/a6,-(a7)
	move.l	4.w,a6
	cmp	#636,16(a6)
	bcs.s	.skip
	jsr	-636(a6)
.skip	movem.l	(a7)+,a0-a1/d0-d1/a6
	rts

