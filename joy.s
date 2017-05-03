	move	$dff00c,d2	;joy0
	bsr	readjoydir
	movem	d0-d1,(a0)
	;
	lea	$bfe001,a2
	lea	$dff016,a1
	;
	moveq	#7,d3
	move	#$4000,d4
	bset	d3,$200(a2)
	bclr	d3,(a2)
	move	#$2000,$dff034
	moveq	#6,d1
.loop	tst.b	(a2)
	tst.b	(a2)
	tst.b	(a2)
	tst.b	(a2)
	tst.b	(a2)
	tst.b	(a2)
	tst.b	(a2)
	tst.b	(a2)
	move	(a1),d2
	bset	d3,(a2)
	bclr	d3,(a2)
	and	d4,d2
	bne.s	.skip
	bset	d1,d0
.skip	dbf	d1,.loop
	move	#$3000,$dff034	;#0
	bclr	d3,$200(a2)
