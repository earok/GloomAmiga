medat	dc.l	0
medplayer	incbin	medplay

;zalta_med	dc.l	theguardianmed
;pattern_med	dc.l	thepatternmed
guardian_med	dc.l	theguardianmed

relocate	;a0=pointer to what to relocate
	;
	move.l	(a0),d0
	beq	.rts
	move.l	d0,a1
	add.l	#32,(a0)
	lea	28(a1),a0
	move.l	(a0)+,d0
	lea	0(a0,d0.l*4),a1
	cmp.l	#$3ec,(a1)+
	bne	.rts
	move.l	(a1)+,d0
	addq	#4,a1
	move.l	a0,d2
	;
.loop	move.l	(a1)+,d1	;offset
	add.l	d2,0(a0,d1)
	subq.l	#1,d0
	bne	.loop
	;
.rts	rts

initmed	lea	medat,a0
	tst.l	(a0)
	bne	.noreloc
	;
	move.l	#medplayer,(a0)
	jsr	relocate
	;
	move.l	medat,a5
	lea	chipzero,a0
	jsr	(a5)
	;move.l	zalta_med,a0
	;jsr	4(a5)
	move.l	guardian_med,a0
	jsr	4(a5)
	;move.l	pattern_med,a0
	;jsr	4(a5)
	;
.noreloc	rts

