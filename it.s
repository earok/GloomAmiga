	;intuition routines for Gloom
	;

initintui	move.l	4.w,a6
	lea	intname(pc),a1
	jsr	-408(a6)
	move.l	d0,int
	rts

int	dc.l	0

initdisplay	
	move.l	int(pc),a6
		


newscreen	dc	0,0	;x,y
	dc	320,240	;w,h
	dc	6	;d
	dc.b	0,0	;pens
	dc	0	;viewmode
	dc	0	;type ($40=ehb?)
	dc.l	0	;font
	dc.l	0	;title
	dc.l	0	;gadgets
	dc.l	0	;bitmap
