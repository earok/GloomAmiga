sfxintserver0	dc.l	0,0
	dc.b	2,0
	dc.l	0
sfxintdata	dc.l	channelinfo
sfxintcode	dc.l	sfxinterupt

sfxintserver1	dc.l	0,0
	dc.b	2,0
	dc.l	0
	dc.l	channelinfo2
	dc.l	sfxinterupt

sfxintserver2	dc.l	0,0
	dc.b	2,0
	dc.l	0
	dc.l	channelinfo2
	dc.l	sfxinterupt

sfxintserver3	dc.l	0,0
	dc.b	2,0
	dc.l	0
	dc.l	channelinfo
	dc.l	sfxinterupt

	moveq	#7,d0
	lea	sfxintserver0,a1
	jsr	-162(a6)	;setintvector
	;
	moveq	#8,d0
	lea	sfxintserver1,a1
	jsr	-162(a6)
	;
	moveq	#9,d0
	lea	sfxintserver2,a1
	jsr	-162(a6)
	;
	moveq	#10,d0
	lea	sfxintserver3,a1
	jsr	-162(a6)
	;
	move.l	4.w,a6
	moveq	#7,d0
	sub.l	a1,a1
	jsr	-162(a6)
	;
	move.l	4.w,a6
	moveq	#8,d0
	sub.l	a1,a1
	jsr	-162(a6)
	;
	move.l	4.w,a6
	moveq	#9,d0
	sub.l	a1,a1
	jsr	-162(a6)
	;
	move.l	4.w,a6
	moveq	#10,d0
	sub.l	a1,a1
	jsr	-162(a6)
	;

sfxinterupt	tst.b	2(a1)
	ble.s	.rts
	subq.b	#1,2(a1)
	bne.s	.rts
	;
	move	14(a1),$dff09a
	move	18(a1),$dff096
	;
	move.l	20(a1),a0	;leftbase
	move.l	#chipzero,(a0)
	move	#0,8(a0)	;vol off
	;
	move.l	24(a1),a0	;leftbase
	move.l	#chipzero,(a0)
	move	#0,8(a0)	;vol off
	;
.rts	move	14(a1),$dff09c
	moveq	#0,d0
	rts
