
	;offset 0:
	bra	initc2p

	;offset 4:
	bra	doc2p_1X1X8

	;offset 8:
	bra	doc2p_1X1X6

	;offset 12:
	dc.l	0

	;offset 16:
	dc.l	0

initc2p	;create 2 tables for Gloom
	
	;
	;a0=columns buffer to fill in (array of longs)
	;d0=how many columns (multiple of 32)
	;
	;create d0 long offsets for each column offset of chunky buffer
	;this allows for scrambling of buffer
	;
	;a1=palette remapping array (array of bytes)
	;
	;this allows for scrambled bitplanes.
	;
	;do palette remapping first...
	;
	move	#$ff,d1	;#colours
.loop	move.b	d1,0(a1,d1)
	dbf	d1,.loop
	;
	subq	#1,d0
	moveq	#0,d1
.loop2	move.l  d1,(a0)+
	addq.l	#1,d1
	dbf	d0,.loop2
	;
	rts
	
rotbits	macro	;macro for rotating/merging bits.
	;
	;rotbits	reg1,reg2,shift
	;
	move.l	\1,d4
	and.l	d6,\1
	eor.l	\1,d4
	lsl.l	#\3,\1
	;
	move.l	\2,d5
	and.l	d6,d5
	eor.l	d5,\2
	lsr.l	#\3,\2
	or.l	d4,\2
	or.l	d5,\1
	;
	endm

doc2p_1X1X8	;
	;inputs:
	;a0.l=src chunky buffer
	;a1.l=dest chipmem bitmap
	;d0.w=width (in pixels - multiple of 32) to convert
	;d1.w=height (in pixels - even)
	;d2.l=modulo from one bitplane to next (copmod-ish)
	;d3.l=modulo from start of one line to start of next (linemod)
	;
	;internal:
	;d6=current and reg.
	;d7=loop counter
	;a2=4 bit and
	;a3=2 bit and
	;a4=1 bit and
	;a5=bitplane modulo, 1 bp to next
	;a6=subtract at end of one loop
	;
	move.l	#$0f0f0f0f,a2
	move.l	#$33333333,a3
	move.l	#$5555aaaa,a4
	move.l	d2,a5	;one bp to next.
	;
	lsl.l	#3,d2	;8 bitplanes
	move.l	d2,a6
	sub.l	a5,a6	;7 * bpmod
	subq.l	#2,a6	;to next word
	;
	lsr	#4,d0	;16 pixels at a time
	move	d0,d2
	ext.l	d2
	add.l	d2,d2
	add.l	a6,d2
	sub.l	d2,d3
	move.l	d3,-(a7)
	;
	subq	#1,d1
	move	d1,d7	;hite dbf
	swap	d7
	subq	#1,d0
	move	d0,d7
	subq	#2,a7	;long align
	move	d7,-(a7)
	;
	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	bra.s	.here
	;
.loop2	swap	d7
	bra.s	.here
	;
.loop	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7
	sub.l	a6,a1	;back to start of next pixel.
	;
.here	rotbits	d0,d2,4
	rotbits	d1,d3,4
	;
	move.l	a3,d6	;2 bit and
	rotbits	d0,d1,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d0,d4
	and.l	d6,d4
	eor.l	d4,d0
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d0
	;
	move	d0,(a1)	;plane 0
	add.l	a5,a1
	;
	move.l	d1,d4
	and.l	d6,d4
	eor.l	d4,d1
	;
	swap	d0
	move	d0,(a1)
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d1
	;
	move	d1,(a1)	;plane 2
	add.l	a5,a1
	;
	move.l	a3,d6	;2 bit and
	rotbits	d2,d3,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d2,d4
	and.l	d6,d4
	eor.l	d4,d2
	;
	swap	d1
	move	d1,(a1)	;plane 3
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d2
	;
	move	d2,(a1)	;plane 4
	add.l	a5,a1
	;
	move.l	d3,d4
	and.l	d6,d4
	eor.l	d4,d3
	;
	swap	d2
	move	d2,(a1)	;plane 5
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d3,d4
	;
	move	d4,(a1)	;plane 6
	add.l	a5,a1
	;
	dbf	d7,.loop	;end of width?
	move	(a7),d7
	swap	d7
	;
	movem.l	(a0)+,d0-d3	;get next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7.
	add.l	4(a7),a1	;start of next line
	;
	dbf	d7,.loop2
	;
	list
.check	set	*-.loop2	;loop size (<256?)
	nolist
	;
	addq	#8,a7
	;
	rts

doc2p_1X1X6	;
	;inputs:
	;a0.l=src chunky buffer
	;a1.l=dest chipmem bitmap
	;d0.w=width (in pixels - multiple of 32) to convert
	;d1.w=height (in pixels - even)
	;d2.l=modulo from one bitplane to next (copmod-ish)
	;d3.l=modulo from start of one line to start of next (linemod)
	;
	;internal:
	;d6=current and reg.
	;d7=loop counter
	;a2=4 bit and
	;a3=2 bit and
	;a4=1 bit and
	;a5=bitplane modulo, 1 bp to next
	;a6=subtract at end of one loop
	;
	move.l	#$0f0f0f0f,a2
	move.l	#$33333333,a3
	move.l	#$5555aaaa,a4
	move.l	d2,a5	;one bp to next.
	;
	lsl.l	#2,d2	;*4
	add.l	a5,d2	;*5
	move.l	d2,a6
	subq.l	#2,a6
	;
	lsr	#4,d0	;16 pixels at a time
	move	d0,d2
	ext.l	d2
	add.l	d2,d2	;bytes
	add.l	a6,d2
	sub.l	d2,d3
	move.l	d3,-(a7)
	;
	subq	#1,d1
	move	d1,d7	;hite dbf
	swap	d7
	subq	#1,d0
	move	d0,d7
	subq	#2,a7	;long align
	move	d7,-(a7)
	;
	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	bra.s	.here
	;
.loop2	swap	d7
	bra.s	.here
	;
.loop	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7
	sub.l	a6,a1	;back to start of next pixel.
	;
.here	rotbits	d0,d2,4
	rotbits	d1,d3,4
	;
	move.l	a3,d6	;2 bit and
	rotbits	d0,d1,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d0,d4
	and.l	d6,d4
	eor.l	d4,d0
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d0
	;
	move	d0,(a1)	;plane 0
	add.l	a5,a1
	;
	move.l	d1,d4
	and.l	d6,d4
	eor.l	d4,d1
	;
	swap	d0
	move	d0,(a1)	;plane 1
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d1
	;
	move	d1,(a1)	;plane 2
	add.l	a5,a1
	;
	move.l	a3,d6	;2 bit and
	rotbits	d2,d3,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d2,d4
	and.l	d6,d4
	eor.l	d4,d2
	;
	swap	d1
	move	d1,(a1)	;plane 3
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d2,d4
	;
	move	d4,(a1)	;plane 4
	add.l	a5,a1
	;
	dbf	d7,.loop	;end of width?
	move	(a7),d7
	swap	d7
	;
	movem.l	(a0)+,d0-d3	;get next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7.
	add.l	4(a7),a1	;start of next line
	;
	dbf	d7,.loop2
	;
	list
.check	set	*-.loop2	;loop size (<256?)
	nolist
	;
	addq	#8,a7
	;
	rts

; Chunky2Planar algorithm.
;
; 	Cpu only solution VERSION 2
;	Optimised for 040+fastram
;	analyse instruction offsets to check performance

;	output	five_pass.o
;	opt	l+	;Linkable code
;	opt	c+	;Case sensitive
;	opt	d-	;No debugging information
;	opt	m+	;Expand macros in listing
;	opt	o-	;No optimisation

;quad_begin:
;	cnop	0,16

;	xdef	_chunky2planar

;  a0 -> chunky pixels
;  a1 -> plane0

width		equ	320		; must be multiple of 32
height		equ	200
plsiz		equ	(width/8)*height


merge	MACRO in1,in2,tmp3,tmp4,mask,shift
	;		\1 = abqr
	;		\2 = ijyz
	move.l	\2,\4
	move.l	#\5,\3
	and.l	\3,\2	\2 = 0j0z
	and.l	\1,\3	\3 = 0b0r
	eor.l	\3,\1	\1 = a0q0
	eor.l	\2,\4	\4 = i0y0
	IFEQ	\6-1
	add.l	\3,\3
	ELSE
	lsl.l	#\6,\3	\3 = b0r0
	ENDC
	lsr.l	#\6,\4	\4 = 0i0y
	or.l	\3,\2	\2 = bjrz
	or.l	\4,\1	\1 = aiqy
	ENDM


_chunky2planar:
	jmp	next
next
	; round down address of c2p
	lea	c2p(pc),a0
	move.l	a0,d0
	and.b	#%11110000,d0
	move.l	d0,a1
	
	; patch jmp
	move.l	d0,_chunky2planar+2
	move.w	#(end-c2p)-1,d0
loop	move.b	(a0)+,(a1)+
	dbra	d0,loop

	;tidy cache
	movem.l	d2-d7/a2-a6,-(sp)	
	move.l	$4.w,a6
	jsr	-636(a6)
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
	cnop	0,16
c2p:
		movem.l	d2-d7/a2-a6,-(sp)

		; a0 = chunky buffer
		; a1 = output area
		
		lea	4*plsiz(a1),a1	; a1 -> plane4
		
		move.l	a0,d0
		add.l	#16,d0
		and.b	#%11110000,d0
		move.l	d0,a0
		
		move.l	a0,a2
		add.l	#8*plsiz,a2

		lea	p0(pc),a3		
		bra.s	mainloop

	cnop	0,16
mainloop:
	move.l	0(a0),d0
 	move.l	4(a0),d2
 	move.l	8(a0),d1
	move.l	12(a0),d3
	move.l	2(a0),d4
 	move.l	10(a0),d5
	move.l	6(a0),d6
	move.l	14(a0),d7

 	move.w	16(a0),d0
 	move.w	24(a0),d1
	move.w	20(a0),d2
	move.w	28(a0),d3
 	move.w	18(a0),d4
 	move.w	26(a0),d5
	move.w	22(a0),d6
	move.w	30(a0),d7
	
	adda.w	#32,a0
	move.l	d6,a5
	move.l	d7,a6

	merge	d0,d1,d6,d7,$00FF00FF,8
	merge	d2,d3,d6,d7,$00FF00FF,8

	merge	d0,d2,d6,d7,$0F0F0F0F,4	
	merge	d1,d3,d6,d7,$0F0F0F0F,4

	exg.l	d0,a5
	exg.l	d1,a6	
	
	merge	d4,d5,d6,d7,$00FF00FF,8
	merge	d0,d1,d6,d7,$00FF00FF,8
	
	merge	d4,d0,d6,d7,$0F0F0F0F,4
	merge	d5,d1,d6,d7,$0F0F0F0F,4

	merge	d2,d0,d6,d7,$33333333,2
	merge	d3,d1,d6,d7,$33333333,2	

	merge	d2,d3,d6,d7,$55555555,1
	merge	d0,d1,d6,d7,$55555555,1
	move.l	d3,2*4(a3)	;plane2
	move.l	d2,3*4(a3)	;plane3
	move.l	d1,0*4(a3)	;plane0
	move.l	d0,1*4(a3)	;plane1

	move.l	a5,d2
	move.l	a6,d3

	merge	d2,d4,d6,d7,$33333333,2
	merge	d3,d5,d6,d7,$33333333,2

	merge	d2,d3,d6,d7,$55555555,1
	merge	d4,d5,d6,d7,$55555555,1
	move.l	d3,6*4(a3)		;bitplane6
	move.l	d2,7*4(a3)		;bitplane7
	move.l	d5,4*4(a3)		;bitplane4
	move.l	d4,5*4(a3)		;bitplane5


inner:
	move.l	0(a0),d0
 	move.l	4(a0),d2
 	move.l	8(a0),d1
	move.l	12(a0),d3
	move.l	2(a0),d4
 	move.l	10(a0),d5
	move.l	6(a0),d6
	move.l	14(a0),d7

 	move.w	16(a0),d0
 	move.w	24(a0),d1
	move.w	20(a0),d2
	move.w	28(a0),d3
 	move.w	18(a0),d4
 	move.w	26(a0),d5
	move.w	22(a0),d6
	move.w	30(a0),d7
	
	adda.w	#32,a0
	move.l	d6,a5
	move.l	d7,a6

	; write	bitplane 7	

	move.l	2*4(a3),-2*plsiz(a1)	;plane2
	merge	d0,d1,d6,d7,$00FF00FF,8
	merge	d2,d3,d6,d7,$00FF00FF,8

	; write	
	move.l	3*4(a3),-plsiz(a1)	;plane3
	merge	d0,d2,d6,d7,$0F0F0F0F,4	
	merge	d1,d3,d6,d7,$0F0F0F0F,4

	exg.l	d0,a5
	exg.l	d1,a6	
	
	; write
	move.l	0*4(a3),-4*plsiz(a1)	;plane0
	merge	d4,d5,d6,d7,$00FF00FF,8
	merge	d0,d1,d6,d7,$00FF00FF,8
	
	; write	
	move.l	1*4(a3),-3*plsiz(a1) ;plane1
	merge	d4,d0,d6,d7,$0F0F0F0F,4
	merge	d5,d1,d6,d7,$0F0F0F0F,4

	; write	
	move.l	6*4(a3),2*plsiz(a1)	;bitplane6
	merge	d2,d0,d6,d7,$33333333,2
	merge	d3,d1,d6,d7,$33333333,2	

	; write
	move.l	7*4(a3),3*plsiz(a1)	;bitplane7
	merge	d2,d3,d6,d7,$55555555,1
	merge	d0,d1,d6,d7,$55555555,1
	move.l	d3,2*4(a3)	;plane2
	move.l	d2,3*4(a3)	;plane3
	move.l	d1,0*4(a3)	;plane0
	move.l	d0,1*4(a3)	;plane1

	move.l	a5,d2
	move.l	a6,d3

	move.l	4*4(a3),(a1)+		;bitplane4	
	merge	d2,d4,d6,d7,$33333333,2
	merge	d3,d5,d6,d7,$33333333,2

	move.l	5*4(a3),-4+1*plsiz(a1)	;bitplane5
	merge	d2,d3,d6,d7,$55555555,1
	merge	d4,d5,d6,d7,$55555555,1
	move.l	d3,6*4(a3)		;bitplane6
	move.l	d2,7*4(a3)		;bitplane7
	move.l	d5,4*4(a3)		;bitplane4
	move.l	d4,5*4(a3)		;bitplane5

	cmpa.l	a0,a2
	bne.w	inner

	move.l	2*4(a3),-2*plsiz(a1)	;plane2
	move.l	3*4(a3),-plsiz(a1)	;plane3
	move.l	0*4(a3),-4*plsiz(a1)	;plane0
	move.l	1*4(a3),-3*plsiz(a1) 	;plane1
	move.l	6*4(a3),2*plsiz(a1)	;bitplane6
	move.l	7*4(a3),3*plsiz(a1)	;bitplane7
	move.l	4*4(a3),(a1)+		;bitplane4	
	move.l	5*4(a3),-4+1*plsiz(a1)	;bitplane5

exit
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	cnop	0,4
end:
p0	dc.l	0
p1	dc.l	0
p2	dc.l	0
p3	dc.l	0
p4	dc.l	0
p5	dc.l	0
p6	dc.l	0
p7	dc.l	0
