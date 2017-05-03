
	;Display routines for planar Gloom
	;
	bsr	initdisplay
	;
loop	btst	#6,$bfe001
	bne	loop
	;
	bra	finitdisplay
	


finitdisplay	;
	move.l	grbase,a6
	move.l	oldview,a1
	jsr	-222(a6)	;load view
	jsr	-270(a6)
	jsr	-270(a6)
	move.l	38(a6),$dff080
	move	#$81a0,$dff096
	move	#0,$dff088
	;
	rts

initdisplay	;
	lea	grname,a1
	move.l	4.w,a6
	jsr	-408(a6)
	move.l	d0,grbase
	;
	move.l	d0,a6
	move.l	34(a6),oldview
	sub.l	a1,a1
	jsr	-222(a6)	;loadview
	;
	move.l	#80*2*5,d0
	moveq	#2,d1
	allocmem	chatplanes
	move.l	d0,chatmap
	;
	move	d0,chatplanes+6
	swap	d0
	move	d0,chatplanes+2
	swap	d0
	add.l	#80,d0
	move	d0,chatplanes+14
	swap	d0
	move	d0,chatplanes+10
	;
	move.l	#copinitf-copinit,d0
	moveq	#2,d1
	allocmem	copinit
	move.l	d0,coplist
	;
	move.l	d0,a1
	lea	copinit,a0
	lea	copinitf,a2
	;
.loop	cmp.l	a2,a0
	bcc.s	.done
	move.l	(a0)+,(a1)+
	bra.s	.loop
.done	;
	add.l	#sl1-copinit,d0
	move.l	d0,slice1
	add.l	#sl2-sl1,d0
	move.l	d0,slice2
	add.l	#cstop-sl2,d0
	move.l	d0,copstop
	;
	move.l	copstop,d0
	move.l	slice1,a0
	move.l	slice2,a1
	;
	move	d0,72+6(a0)
	move	d0,72+6(a1)
	swap	d0
	move	d0,72+2(a0)
	move	d0,72+2(a1)
	;
	bsr	dochatoff
	;
	jsr	-270(a6)
	move	#$81a0,$dff096
	;
	;jsr	-270(a6)
	;move.l	coplist,$dff080
	;move	#0,$dff088
	;
	pull
	rts

cols24	macro
	dc	$180,0,$182,0,$184,0,$186,0
	dc	$188,0,$18a,0,$18c,0,$18e,0
	dc	$190,0,$192,0,$194,0,$196,0
	dc	$198,0,$19a,0,$19c,0,$19e,0
	dc	$1a0,0,$1a2,0,$1a4,0,$1a6,0
	dc	$1a8,0,$1aa,0,$1ac,0,$1ae,0
	endm

copinit	;initialization for display
	;
	dc	$1fc,15,$096,$120
	;
	dc	$08e,$1e81,$090,$23c1,$1e4,$2000
	dc	$092,$38,$094,$c0,$102,0
	;
	dc	$100,$a200,$108,80,$10a,80
	dc	$106,0,$10c,0	;bank, eor
	dc	$182,$fff,$184,$f0f,$186,$ff0
	;
chatplanes	dc	$e0,0,$e2,0,$e4,0,$e6,0
	;
	dc	26<<8+1,$fffe
	;
	dc	$140,0,$142,0,$144,0,$146,0
	dc	$148,0,$14a,0,$14c,0,$14e,0
	dc	$150,0,$152,0,$154,0,$156,0
	dc	$158,0,$15a,0,$15c,0,$15e,0
	dc	$160,0,$162,0,$164,0,$166,0
	dc	$168,0,$16a,0,$16c,0,$16e,0
	dc	$170,0,$172,0,$174,0,$176,0
	dc	$178,0,$17a,0,$17c,0,$17e,0
	;
chatdispon	dc	$1fe,0 ;096,$8100
	dc	$2401,$fffe,$096,$100
	dc	$094,$a0,$100,$7200,$108,6*40,$10a,6*40
	;
	;lo colour nybs - lo bank
	dc	$106,$0200
cols1	cols24
	;
	;lo nybs - hi bank
	dc	$106,$8200
cols2	cols24
	;
	;hi colour nybs - lo bank
	dc	$106,0
cols3	cols24
	;
	;hi colour nybs - hi bank
	dc	$106,$8000
cols4	cols24
	;
	;slice...
sl1	;
	dc	$e0,0,$e2,0
	dc	$e4,0,$e6,0
	dc	$e8,0,$ea,0
	dc	$ec,0,$ee,0
	dc	$f0,0,$f2,0
	dc	$f4,0,$f6,0
	dc	$f8,0,$fa,0
	dc	$08e,$2c81,$090,$f4c1	;diw
	dc	$0001,$fffe	;wait for slice!
	dc	$096,$8100
	;
	dc	$084,0,$086,0,$08a,0
sl2	;
	dc	$e0,0,$e2,0
	dc	$e4,0,$e6,0
	dc	$e8,0,$ea,0
	dc	$ec,0,$ee,0
	dc	$f0,0,$f2,0
	dc	$f4,0,$f6,0
	dc	$f8,0,$fa,0
	;56
	dc	$08e,$2c81,$090,$f4c1	;diw
	;64
	dc	$0001,$fffe	;wait for slice!
	;68
	dc	$096,$8100
	;72
	;
	dc	$084,0,$086,0,$08a,0
	;
cstop	dc	$096,$0100	;display DMA off...
	dc	$ffff,$fffe
