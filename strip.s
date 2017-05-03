
main
	move	#$4000,$dff09a
	;
	lea	lut,a0
	lea	pal,a3
	lea	dummy,a1
	moveq	#0,d4
	;
.vwait	move	#$20,$dff09c
.ll	btst	#5,$dff01f
	beq.s	.ll
	move	#$f00,$dff180
	move	#13,d7
	;
.loop	moveq	#119,d5
	lsr	#1,d5
	subq	#1,d5
	bsr	strip
	dbf	d7,.loop
	;
	move	#0,$dff180
	btst	#6,$bfe001
	bne	.vwait
	;
	rts

strip	;
	move.b	(a0,d0),d3	;lut entry
	move	(a3,d3*2),(a1) ;colour!
	addx.l	d1,d0
	add.l	d4,a1
	;
	move.b	(a0,d0),d3	;lut entry
	move	(a3,d3*2),(a1) ;colour!
	addx.l	d1,d0
	add.l	d4,a1
	;
	dbf	d5,strip
	;
	rts

lut	ds.b	512
pal	ds.w	512
dummy	ds.l	0
