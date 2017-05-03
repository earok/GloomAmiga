groundcam	dc.l	0

ground	;
	;A0=128 X 128 bitmap to map onto ground...
	;A1=address of inverse camera matrix
	;
	movem.l	d2-d7/a2-a6,-(a7)
	;
	lea	10(a0),a0
	;
	move	hite(pc),d7
	mulu	copline(pc),d7
	add.l	copx0(pc),d7
	move.l	d7,a2
	;
	moveq	#0,d6
	sub	camy(pc),d6
	ext.l	d6
	lsl.l	#focshft,d6
	move.l	d6,groundcam
	;
	move	maxy(pc),d7
	subq	#1,d7
ground_vloop	;
	;find Z on this scanline...
	;
	move.l	groundcam(pc),d6
	divs	d7,d6	;d6.w = Z
	;
	move.l	pal(pc),a5
	move	d6,d5
	lsr	#darkshft,d5
	cmp	#16,d5
	bcs.s	ground_ok
	;
	;OK, out of Z's...fill in with dark colour 0 QUICKLY!
	;
	move.l	coplinel(pc),d1
	neg.l	d1
	add.l	d1,a2
	bsr	clstherest
	bra	ground_abort
	;
ground_ok	move.l	0(a5,d5*4),a5	;palette!
	;
	;Find leftmost X...
	;
	move	minx(pc),d5
	muls	d6,d5
	asr.l	#focshft,d5
	;
	move	maxx(pc),d4
	muls	d6,d4
	asr.l	#focshft,d4
	;
	;rotate X1,Z around camera...
	;
	move	d5,d0
	move	d6,d1
	;
	move	d0,d2
	move	d1,d3
	;
	muls	(a1),d0
	add.l	d0,d0
	muls	2(a1),d3
	add.l	d3,d3
	add.l	d3,d0
	;
	muls	4(a1),d2
	add.l	d2,d2
	muls	6(a1),d1
	add.l	d1,d1
	add.l	d2,d1
	;
	;d0,d1.q = rotated x1,z
	;
	;rotate X2,Z around camera...
	;
	move	d4,d2
	move	d6,d3
	;
	muls	(a1),d4
	add.l	d4,d4
	muls	2(a1),d3
	add.l	d3,d3
	add.l	d3,d4
	;
	muls	4(a1),d2
	add.l	d2,d2
	muls	6(a1),d6
	add.l	d6,d6
	add.l	d2,d6
	;
	;d4,d6.q = rotated x2,z
	;
	move	width(pc),d5
	ext.l	d5
	sub.l	d0,d4	;Xadd
	divs.l	d5,d4
	sub.l	d1,d6	;Zadd
	divs.l	d5,d6
	add.l	camx(pc),d0
	add.l	camz(pc),d1
	;
	;d0,d1.q=x,z
	;d4,d6.q=xadd,zadd
	;
	swap	d0
	swap	d1
	swap	d4
	swap	d6
	;
	move	d7,-(a7)
	moveq	#127,d7
	moveq	#0,d2
	moveq	#0,d3
	;
	sub	copline(pc),a2
	move.l	a2,a3
	;
	move	wdiv32(pc),-(a7)
	;
ground_hloop2	moveq	#31,d5
	;
ground_hloop	tst	(a3)
	;
ground_br	bne.s	ground_skip
	;
	and	d7,d0
	and	d7,d1	;X/Z for fetch!
	move	d0,d2
	ext.l	d2
	lsl.l	#7,d2
	lea	0(a0,d2.l),a6
	move.b	0(a6,d1),d3
	move	0(a5,d3*2),(a3)
	;
ground_skip	add.l	d4,d0
	addx	d2,d0
	add.l	d6,d1
	addx	d2,d1
	addq	#4,a3
	dbf	d5,ground_hloop
	;
	addq	#4,a3
	subq	#1,(a7)
	bgt.s	ground_hloop2
	bne.s	.kl
	move	wrem32(pc),d5
	bpl.s	ground_hloop
	;
.kl	move.l	(a7)+,d7
	dbf	d7,ground_vloop
	;
ground_abort	movem.l	(a7)+,d2-d7/a2-a6
	rts

