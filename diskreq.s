askfordisk	jsr	diskreq+32
	jsr	qvwait
	move.l	d7,$dff080
	move	#0,$dff088
	;
.retry	move.l	#'GARD',d0
	move.l	diskbuff,d1
	move.l	sibdos,a0
	jsr	(a0)
	bne.s	.got
	;
	move	#199,d7
.vwloop	jsr	qvwait
	dbf	d7,.vwloop
	bra.s	.retry
	;
.got	rts

diskreq	incbin	loader
	even
