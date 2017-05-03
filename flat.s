
	move	#$4000,$dff09a
	;
vwait	move	#$20,$dff09c
.ll	btst	#5,$dff01f
	beq.s	.ll
	move	#$f00,$dff180
	;
	move	#99,d7
	;
	lea	lut,a0
	lea	pal,a5
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d4
	moveq	#0,d6
	moveq	#0,d7
	;
	move	#99,-(a7)
	;
.loop	bsr	flat
	subq	#1,(a7)
	bpl.s	.loop
	addq	#2,a7
	;
	move	#0,$dff180
	btst	#6,$bfe001
	bne	vwait
	;
	move	#$c000,$dff09a
	rts

flat	;
	moveq	#31,d5
	lea	dummy(pc),a3
	;
.hloop	tst	(a3)	;check destination!
	bne.s	.skip
	;
	and	d7,d0
	and	d7,d1
	move	d0,d2
	lsl	#7,d2
	add	d2,d1
	add.l	d4,d0
	move.b	0(a0,d1),d3
	addx	d2,d0
	add.l	d6,d1
	move	0(a5,d3*2),(a3)
	addx	d2,d1
	addq	#4,a3
	dbf	d5,.hloop
	rts
	;
.skip	add.l	d4,d0
	addx	d2,d0
	add.l	d6,d1
	addx	d2,d1
	addq	#4,a3
	dbf	d5,.hloop
	rts

lut	ds.b	512
pal	ds.b	512
dummy	ds.l	32
