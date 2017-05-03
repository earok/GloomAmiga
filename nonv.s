myentry	dc.l	0

hiscores	dc.l	$100000,'MAK '	;score,name
	dc.l	$50000,'AXE '
	dc.l	$10000,'HAN '
	dc.l	$9000,'AND '
	dc.l	$8000,'NIX '
	;
	dc.l	$7000,'ASM '
	dc.l	$6000,'ORG '
	dc.l	$5000,'MON '
	dc.l	$2500,'WAS '
hiscoresf	dc.l	$1000,'GON '

applname	dc.b	'Guardian',0
	even
itemname	dc.b	'Heroes',0
	even

nvname	dc.b	'nonvolatile.library',0
	cnop	0,4
nv	dc.l	0

savehiscores	movem.l	d0-d7/a0-a6,-(a7)
	jsr	enableos
	;
	move.l	nv,d0
	beq.s	.done
	move.l	d0,a6
	lea	applname(pc),a0
	lea	itemname(pc),a1
	lea	hiscores(pc),a2
	moveq	#8,d0	;80 bytes
	moveq	#-1,d1
	jsr	-42(a6)	;storenv
	tst.l	d0
	bne.s	.done	;error!
	;
	lea	applname(pc),a0
	lea	itemname(pc),a1
	moveq	#-1,d1
	moveq	#1,d2
	jsr	-66(a6)	;setnvprotection
	;
.done	jsr	disableos
	movem.l	(a7)+,d0-d7/a0-a6
	rts

hisfound	dc	0

loadhiscores	move.l	nv,d0
	beq.s	.done
	;
	move.l	d0,a6
	lea	applname(pc),a0
	lea	itemname(pc),a1
	moveq	#-1,d1
	jsr	-30(a6)	;getcopnv
	tst.l	d0
	beq.s	.done
	;
	st	hisfound
	move.l	d0,a0
	lea	hiscores(pc),a1
	moveq	#19,d1
.loop	move.l	(a0)+,(a1)+
	dbf	d1,.loop
	;
	move.l	d0,a0
	jsr	-36(a6)	;freenvdata
	;
.done	rts

