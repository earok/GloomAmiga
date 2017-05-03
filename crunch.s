
	;crunch stuff!
	;
	;(c) 1991, 92 by Thomas Schwarz, all rights reserved
	;
	;includes imploder/deploder/crmdecrunch
	;

	bra	_startcrunch	;0
	bra	_decrunch	;4
	bra	_crm	;8
	bra	_ppdecrunch	;12

; implode:
;
; In: a0.l=*buffer
; a1.l=*info routine (d0.l=0:break; -1:continue)
; d0.l=data length
; d1.l=crunch mode
;
; Out:  d0.l=<0:user break; 0:error; <>0:crunched length
;
;------------------------------------------------
_startcrunch:
    MOVE.l  d0,a0
    MOVE.l  d1,d0
;    LEA $100000,a0
    LEA Own(pc),a1
;    MOVE.l  #30000,d0
    MOVEQ #8,d1
;    MOVE.w  #$4000,$dff09a ; System Off
    BSR Implode
;    MOVE.w  #$c000,$dff09a ; System On
    RTS
;------------------------------------------------
Own:    MOVE.w  d1,$dff180
    BTST  #6,$bfe001
    BNE own1
    MOVEQ #0,d0
    BRA own2
own1:    MOVEQ #-1,d0
own2:    RTS
;------------------------------------------------
Implode:  MOVEM.l d2-d7/a2-a6,-(a7)
    MOVE.w  #$57,d2
im01:   CLR.w -(a7)
    DBF d2,im01
    MOVE.l  a7,a6
    MOVE.l  a5,2(a6)
    CMP.l #$40,d0
    BCS im23
    LSR.l #8,d1
    SCS (a6)
    LSR.l #8,d1
    CMP.b #12,d1
    BCS im02
    MOVEQ #0,d1
im02:   MOVE.l  a1,6(a6)
    MOVE.l  a0,10(a6)
    MOVE.l  a0,$22(a6)
    MOVE.l  a0,$26(a6)
    MOVE.l  d0,$12(a6)
    ADD.l d0,a0
    MOVE.l  a0,14(a6)
    LEA imtab0(pc),a0
    LSL.w #2,d1
    MOVE.l  0(a0,d1.w),d1
    ADDQ.l  #1,d1
    CMP.l d0,d1
    BLS im03
    MOVE.l  d0,d1
    SUBQ.l  #1,d1
im03:   MOVE.l  d1,$1A(a6)
    SUBQ.l  #1,d1
    MOVEQ #0,d0
im04:   CMP.l (a0)+,d1
    BLS im05
    ADDQ.b  #1,d0
    BRA im04
im05:   MOVE.b  d0,1(a6)
    LEA $A4(a6),a1
    MOVEQ #12,d1
    MULU  d1,d0
    LEA imtab1(pc),a0
    ADD.l d0,a0
    SUBQ.w  #1,d1
im06:   MOVE.b  (a0)+,(a1)+
    DBF d1,im06
    LEA $74(a6),a1
    LEA $A4(a6),a0
    MOVEQ #11,d1
im07:   MOVE.b  (a0)+,d0
    MOVEQ #0,d2
    BSET  d0,d2
    MOVE.l  d2,(a1)+
    DBF d1,im07
    LEA $74(a6),a0
    LEA $84(a6),a1
    MOVEQ #7,d1
im08:   MOVE.l  (a0)+,d0
    ADD.l d0,(a1)+
    DBF d1,im08
    TST.b (a6)
    BEQ im11
    LEA $74(a6),a1
    MOVEQ #7,d0
im09:   MOVE.l  (a1)+,d1
    MOVE.w  d1,(a2)+
    DBF d0,im09
    LEA $A4(a6),a1
    MOVEQ #11,d0
im10:   MOVE.b  (a1)+,(a2)+
    DBF d0,im10
im11:   MOVE.b  #7,$2D(a6)
im12:   BSR im26
    BNE im22
    BSR im28
    BEQ im15
    BSR im55
    BNE im13
    MOVE.l  $22(a6),a0
    MOVE.l  $26(a6),a1
    MOVE.b  (a0),(a1)
    ADDQ.l  #1,$22(a6)
    ADDQ.l  #1,$26(a6)
    ADDQ.l  #1,$30(a6)
    ADDQ.l  #1,$1E(a6)
    CMP.l #$4012,$30(a6)
    BCS im12
    BRA im15
im13:   MOVE.b  $5C(a6),d0
    MOVE.l  $60(a6),d1
    BSR im37
    MOVE.b  $5E(a6),d0
    MOVE.w  $66(a6),d1
    BSR im37
    MOVE.b  $5D(a6),d0
    MOVE.w  $64(a6),d1
    CMP.b #13,d0
    BNE im14
    MOVE.l  $26(a6),a0
    MOVE.b  d1,(a0)+
    MOVE.l  a0,$26(a6)
    MOVEQ #5,d0
    MOVEQ #$1F,d1
im14:   BSR im37
    MOVEQ #0,d0
    MOVE.b  $2E(a6),d0
    ADD.l d0,$22(a6)
    CLR.l $30(a6)
    BRA im12
im15:   BSR im26
    BNE im22
    MOVE.l  $22(a6),a0
    MOVE.l  $26(a6),a1
    MOVE.b  (a0),(a1)
    ADDQ.l  #1,$22(a6)
    ADDQ.l  #1,$26(a6)
    ADDQ.l  #1,$30(a6)
    ADDQ.l  #1,$1E(a6)
    MOVE.l  $22(a6),d0
    CMP.l 14(a6),d0
    BNE im15
    BSR im26
    BNE im22
    TST.b (a6)
    BNE im19
    MOVE.l  $26(a6),d0
    SUB.l 10(a6),d0
    CMP.l #12,d0
    BCS im23
    MOVE.l  $12(a6),d1
    SUB.l d0,d1
    CMP.l #$36,d1
    BLS im23
    MOVE.l  10(a6),a1
    MOVE.l  $26(a6),a0
    MOVE.l  #$FF00,d7
    BTST  #0,d0
    BEQ im16
    MOVEQ #0,d7
    ADDQ.l  #1,d0
    CLR.b (a0)+
im16:   MOVE.l  (a1),8(a0)
    MOVE.l  #"IMP!",(a1)
    MOVE.l  4(a1),4(a0)
    MOVE.l  $12(a6),4(a1)
    MOVE.l  8(a1),(a0)
    MOVE.l  d0,8(a1)
    ADD.l #$2E,d0
    MOVE.l  d0,$16(a6)
    MOVE.l  $30(a6),12(a0)
    MOVE.b  $2C(a6),d1
    AND.w #$FE,d1
    MOVE.b  $2D(a6),d0
    BSET  d0,d1
    OR.w  d7,d1
    MOVE.w  d1,$10(a0)
    LEA $74(a6),a1
    ADD.w #$12,a0
    MOVEQ #7,d0
im17:   MOVE.l  (a1)+,d1
    MOVE.w  d1,(a0)+
    DBF d0,im17
    LEA $A4(a6),a1
    MOVEQ #11,d0
im18:   MOVE.b  (a1)+,(a0)+
    DBF d0,im18
    BRA im23
im19:   MOVE.l  $26(a6),d0
    SUB.l 10(a6),d0
    MOVE.l  $12(a6),d1
    SUB.l d0,d1
    CMP.l #6,d1
    BLS im23
    MOVE.b  $2C(a6),d1
    AND.b #$FE,d1
    MOVE.b  $2D(a6),d2
    BSET  d2,d1
    MOVE.l  $26(a6),a0
    BTST  #0,d0
    BEQ im20
    MOVE.b  d1,(a0)+
    MOVE.l  $30(a6),(a0)
    BRA im21
im20:   MOVE.l  $30(a6),(a0)+
    MOVE.b  d1,(a0)
im21:   ADDQ.l  #5,d0
    MOVE.l  d0,$16(a6)
    BRA im23
im22:   MOVEQ #-1,d0
    BRA im24
im23:   MOVE.l  $16(a6),d0
im24:   MOVE.w  #$57,d2
im25:   CLR.w (a7)+
    DBF d2,im25
    MOVEM.l (a7)+,d2-d7/a2-a6
    TST.l d0
    RTS
;------------------------------------------------
imtab0:   Dc.l  128,256,512,1024,1792,3328,5376,9472,20736,37376,67840,67840
imtab1:   Dc.l  $5050505,$5050505,$6060606,$5060707,$6060606,$7070606
    Dc.l  $5060707,$7070707,$8080808,$5060708,$7070808,$8080909
    Dc.l  $6070708,$7080909,$8090A0A,$6070708,$709090A,$80A0B0B
    Dc.l  $6070808,$709090A,$80A0B0C,$6070808,$709090A,$90A0C0D
    Dc.l  $6070708,$709090C,$90A0C0E,$6070809,$7090A0C,$90B0D0F
    Dc.l  $6070808,$70A0B0B,$90C0D10,$6080809,$70B0C0C,$90D0E11
imtab2:   Dc.l  $2060E,$1020304
imtab3:   Dc.l  $1010101,$2030304,$405070E
imtab4:   Dc.l  $20002,$20002,$6000A,$A0012,$16002A,$8A4012
;------------------------------------------------
im26:   MOVE.l  6(a6),d0
    BEQ im27
    MOVE.l  d0,a0
    MOVE.l  14(a6),d0
    SUB.l $22(a6),d0
    MOVE.l  $22(a6),d1
    SUB.l $26(a6),d1
    MOVEQ #0,d2
    MOVE.b  1(a6),d2
    MOVE.l  2(a6),a5
    MOVE.l  a6,-(a7)
    JSR (a0)
    MOVE.l  (a7)+,a6
    NOT.l d0
im27:   TST.l d0
    RTS
;------------------------------------------------
im28:   MOVE.l  $22(a6),a5
    MOVE.l  14(a6),d4
    MOVE.l  a5,d0
    ADDQ.l  #1,d0
    ADD.l $1A(a6),d0
    CMP.l d4,d0
    BLS im29
    MOVE.l  d4,d0
    MOVE.l  d0,d1
    SUB.l a5,d1
    CMP.l #3,d1
    BCC im29
    MOVEQ #0,d0
    RTS
;------------------------------------------------
im29:   MOVE.l  d0,d5
    MOVE.l  a5,a2
    ADDQ.l  #1,a2
    MOVE.l  a2,a4
    MOVEQ #1,d7
    MOVE.b  (a5),d3
    LEA $34(a6),a3
im30:   CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.b (a2)+,d3
    BEQ im32
    CMP.l a2,d5
    BHI im30
im31:   MOVEQ #-1,d0
    RTS
;------------------------------------------------
im32:   CMP.l a2,d5
    BLS im31
    MOVE.l  a4,a0
    MOVE.l  a2,a1
    CMPM.b  (a0)+,(a1)+
    BNE im30
    CMPM.b  (a0)+,(a1)+
    BNE im35
    CMPM.b  (a0)+,(a1)+
    BNE im34
    MOVE.w  #251,d0
im33:   CMPM.b  (a0)+,(a1)+
    DBNE  d0,im33
im34:   CMP.l d4,a1
    BLS im35
    MOVE.l  d4,a1
im35:   MOVE.l  a1,d6
    SUB.l a2,d6
    CMP.w d6,d7
    BCC im30
    MOVE.w  d6,d7
    CMP.w #8,d6
    BHI im36
    TST.b -2(a3,d6.w)
    BNE im30
    MOVE.b  d6,-2(a3,d6.w)
    MOVE.l  a2,d0
    SUB.l a5,d0
    SUBQ.l  #2,d0
    MOVE.w  d6,d1
    LSL.w #2,d1
    MOVE.l  d0,0(a3,d1.w)
    BRA im30
im36:   MOVE.b  d6,7(a3)
    MOVE.l  a2,d0
    SUB.l a5,d0
    SUBQ.l  #2,d0
    MOVE.l  d0,$24(a3)
    CMP.b #$FF,d6
    BNE im30
    BRA im31
im37:   MOVE.b  $2C(a6),d2
    MOVE.b  $2D(a6),d3
    MOVE.l  $26(a6),a0
im38:   LSR.l #1,d1
    ROXR.b  #1,d2
    SUBQ.b  #1,d3
    BPL im39
    MOVEQ #7,d3
    MOVE.b  d2,(a0)+
    MOVEQ #0,d2
im39:   SUBQ.b  #1,d0
    BNE im38
    MOVE.l  a0,$26(a6)
    MOVE.b  d3,$2D(a6)
    MOVE.b  d2,$2C(a6)
    RTS
;------------------------------------------------
im40:   AND.l #$FF,d0
    CMP.b #13,d0
    BHI im42
    CMP.b #5,d0
    BHI im41
    LEA imtab2(pc),a0
    MOVE.b  -2(a0,d0.w),$71(a6)
    MOVE.b  2(a0,d0.w),$69(a6)
    BRA im44
im41:   SUBQ.b  #6,d0
    OR.b  #$F0,d0
    MOVE.b  d0,$71(a6)
    MOVE.b  #8,$69(a6)
    BRA im43
im42:   MOVE.b  #$1F,$70(a6)
    MOVE.b  d0,$71(a6)
    MOVE.b  #13,$69(a6)
im43:   MOVEQ #5,d0
im44:   SUBQ.b  #2,d0
    MOVE.l  $30(a6),d2
    LEA imtab3(pc),a1
    LEA imtab4(pc),a0
    ADD.l d0,a0
    ADD.l d0,a0
    CMP.w (a0),d2
    BCC im45
    MOVE.b  0(a1,d0.w),d6
    MOVE.b  d6,d3
    ADDQ.b  #1,d3
    MOVE.b  #0,$73(a6)
    MOVEQ #0,d4
    BRA im48
im45:   CMP.w 8(a0),d2
    BCC im46
    MOVE.b  4(a1,d0.w),d6
    MOVE.b  d6,d3
    ADDQ.b  #2,d3
    MOVE.b  #2,$73(a6)
    MOVE.w  (a0),d4
    BRA im48
im46:   CMP.w $10(a0),d2
    BCS im47
    MOVEQ #0,d0
    RTS
;------------------------------------------------
im47:   MOVE.b  8(a1,d0.w),d6
    MOVE.b  d6,d3
    ADDQ.b  #2,d3
    MOVE.b  #3,$73(a6)
    MOVE.w  8(a0),d4
im48:   MOVE.b  d3,$6A(a6)
    SUB.w d4,d2
    MOVEQ #$10,d5
    SUB.b d6,d5
    LSL.w d5,d2
im49:   ADD.w d2,d2
    ROXL  $72(a6)
    SUBQ.b  #1,d6
    BNE im49
    LEA $A4(a6),a1
    LEA $74(a6),a0
    ADD.w d0,a0
    ADD.w d0,a0
    ADD.w d0,a0
    ADD.w d0,a0
    CMP.l (a0),d1
    BCC im50
    MOVE.b  0(a1,d0.w),d6
    MOVE.b  d6,d3
    ADDQ.b  #1,d3
    MOVEQ #0,d7
    MOVEQ #0,d4
    BRA im53
im50:   CMP.l $10(a0),d1
    BCC im51
    MOVE.b  4(a1,d0.w),d6
    MOVE.b  d6,d3
    ADDQ.b  #2,d3
    MOVEQ #2,d7
    MOVE.l  (a0),d4
    BRA im53
im51:   CMP.l $20(a0),d1
    BCS im52
    MOVEQ #0,d0
    RTS
;------------------------------------------------
im52:   MOVE.b  8(a1,d0.w),d6
    MOVE.b  d6,d3
    ADDQ.b  #2,d3
    MOVEQ #3,d7
    MOVE.l  $10(a0),d4
im53:   MOVE.b  d3,$68(a6)
    SUB.l d4,d1
    MOVEQ #$20,d5
    SUB.b d6,d5
    LSL.l d5,d1
im54:   ADD.l d1,d1
    ADDX.l  d7,d7
    SUBQ.b  #1,d6
    BNE im54
    MOVE.l  d7,$6C(a6)
    MOVEQ #-1,d0
    RTS
;------------------------------------------------
im55:   CLR.w $2A(a6)
    CLR.b $2E(a6)
    LEA $34(a6),a4
    LEA $3C(a6),a5
im56:   MOVE.l  (a5)+,d1
    MOVE.b  (a4)+,d0
    BEQ im58
    BSR im40
    BEQ im58
    MOVEQ #0,d0
    MOVEQ #0,d1
    MOVE.b  -1(a4),d0
    LSL.w #3,d0
    ADD.b $69(a6),d1
    ADD.b $68(a6),d1
    ADD.b $6A(a6),d1
    SUB.w d1,d0
    BMI im58
    CMP.w $2A(a6),d0
    BCS im58
    MOVE.w  d0,$2A(a6)
    MOVE.b  -1(a4),$2E(a6)
    LEA $5C(a6),a0
    LEA $68(a6),a1
    MOVEQ #12,d1
im57:   MOVE.b  (a1)+,(a0)+
    DBF d1,im57
im58:   MOVE.l  a4,d0
    SUB.l a6,d0
    CMP.w #$3C,d0
    BNE im56
    CLR.l -(a4)
    CLR.l -(a4)
    TST.w $2E(a6)
    RTS
;------------------------------------------------



_decrunch:      ;LEA     $50000,a0
                MOVE.l  d0,a0
;**********************************
;* FILE IMPLODER DECRUNCH ROUTINE *
;*  FOR ASMONE ASSEMBLER    *
;**********************************
;
; Entry: a0 = address of crunched file
; Exit:  d0 = 0 error or d0 = -1 depack ok
;
; File structure to check:
;
; 0(a0) = 'IMP!'
; 4(a0) = len of depacked file
; 8(a0) = len of packed file-$32
; A(a0) = here start the datas
;
;
deplode:
  CMP.l #"IMP!",(a0)
  BNE I1802
  MOVEM.l d2-d5/a2-a4,-(a7)
  MOVE.l  a0,a3
  MOVE.l  a0,a4
  TST.l (a0)+
  ADD.l (a0)+,a4
  ADD.l (a0)+,a3
  MOVE.l  a3,a2
  MOVE.l  (a2)+,-(a0)
  MOVE.l  (a2)+,-(a0)
  MOVE.l  (a2)+,-(a0)
  MOVE.l  (a2)+,d2
  MOVE.w  (a2)+,d3
  BMI I17EE
  SUBQ.l  #1,a3
I17EE:
  LEA -$1C(a7),a7
  MOVE.l  a7,a1
  MOVEQ #6,d0
I17F6:
  MOVE.l  (a2)+,(a1)+
  DBF d0,I17F6
  MOVE.l  a7,a1
  BRA I1E70
I1802:
  MOVEQ #0,d0
  RTS
I1E70:
  TST.l d2
  BEQ I1E7A
I1E74:
  MOVE.b  -(a3),-(a4)
  SUBQ.l  #1,d2
  BNE I1E74
I1E7A:
  CMP.l a4,a0
  BCS I1E92
  LEA $1C(a7),a7
  MOVEQ #-$1,d0
  CMP.l a3,a0
  BEQ I1E8A
  MOVEQ #0,d0
I1E8A:
  MOVEM.l (a7)+,d2-d5/a2-a4
  TST.l d0
  RTS
I1E92:
  ADD.b d3,d3
  BNE I1E9A
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1E9A:
  BCC I1F04
  ADD.b d3,d3
  BNE I1EA4
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1EA4:
  BCC I1EFE
  ADD.b d3,d3
  BNE I1EAE
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1EAE:
  BCC I1EF8
  ADD.b d3,d3
  BNE I1EB8
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1EB8:
  BCC I1EF2
  MOVEQ #0,d4
  ADD.b d3,d3
  BNE I1EC4
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1EC4:
  BCC I1ECE
  MOVE.b  -(a3),d4
  MOVEQ #3,d0
  SUBQ.b  #1,d4
  BRA I1F08
I1ECE:
  ADD.b d3,d3
  BNE I1ED6
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1ED6:
  ADDX.b  d4,d4
  ADD.b d3,d3
  BNE I1EE0
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1EE0:
  ADDX.b  d4,d4
  ADD.b d3,d3
  BNE I1EEA
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1EEA:
  ADDX.b  d4,d4
  ADDQ.b  #5,d4
  MOVEQ #3,d0
  BRA I1F08
I1EF2:
  MOVEQ #4,d4
  MOVEQ #3,d0
  BRA I1F08
I1EF8:
  MOVEQ #3,d4
  MOVEQ #2,d0
  BRA I1F08
I1EFE:
  MOVEQ #2,d4
  MOVEQ #1,d0
  BRA I1F08
I1F04:
  MOVEQ #1,d4
  MOVEQ #0,d0
I1F08:
  MOVEQ #0,d5
  MOVE.w  d0,d1
  ADD.b d3,d3
  BNE I1F14
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1F14:
  BCC I1F2C
  ADD.b d3,d3
  BNE I1F1E
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1F1E:
  BCC I1F28
  MOVE.b  I1F8C(pc,d0.w),d5
  ADDQ.b  #8,d0
  BRA I1F2C
I1F28:
  MOVEQ #2,d5
  ADDQ.b  #4,d0
I1F2C:
  MOVE.b  I1F90(pc,d0.w),d0
I1F30:
  ADD.b d3,d3
  BNE I1F38
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1F38:
  ADDX.w  d2,d2
  SUBQ.b  #1,d0
  BNE I1F30
  ADD.w d5,d2
  MOVEQ #0,d5
  MOVE.l  d5,a2
  MOVE.w  d1,d0
  ADD.b d3,d3
  BNE I1F4E
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1F4E:
  BCC I1F6A
  ADD.w d1,d1
  ADD.b d3,d3
  BNE I1F5A
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1F5A:
  BCC I1F64
  MOVE.w  8(a1,d1.w),a2
  ADDQ.b  #8,d0
  BRA I1F6A
I1F64:
  MOVE.w  0(a1,d1.w),a2
  ADDQ.b  #4,d0
I1F6A:
  MOVE.b  $10(a1,d0.w),d0
I1F6E:
  ADD.b d3,d3
  BNE I1F76
  MOVE.b  -(a3),d3
  ADDX.b  d3,d3
I1F76:
  ADDX.l  d5,d5
  SUBQ.b  #1,d0
  BNE I1F6E
  ADDQ.w  #1,a2
  ADD.l d5,a2
  ADD.l a4,a2
I1F82:
  MOVE.b  -(a2),-(a4)
  DBF d4,I1F82
  BRA I1E70
I1F8C:
  Dc.l  $60A0A12
I1F90:
  Dc.l  $1010101
  Dc.l  $2030304
  Dc.l  $405070E

;***------------------------------------------------------------------------
;*** This is the ultimate Data-Decrunch-Routine
;*** For Crunch-Mania V1.7
;*** (c) 1991, 92 by -;> Thomas Schwarz <+-, all rights reserved
;*** You may Use this piece of code as long as you don't claim that
;*** you have written it. In any Case the author (me) has To be
;*** mentioned someplace in your proggy.
;*** Note: Source- AND Destinationaddresses have To be always Even Addresses
;***------------------------------------------------------------------------
;*** Here is the Format of the Header:
;*** Type  Offset  Contents                   Function
;*** LONG  0       "CrM!"/"CrM2"              To recongnize crunched files
;*** WORD  4       Minimum Security Distance  To savely decrunch Data when
;***              Source AND Dest is in the same
;***              Memoryblock
;*** LONG  6       Original Len               Datalen before packing
;*** LONG  10 ($a) Crunched Len               Datalen after packing without
;***              Header
;***------------------------------------------------------------------------
;** Jump here To decrunch some Data with overlap check
;** You need some Memory directly in front of the Destination Area
;** which has To be as large as the MinSecDist
;** Load the Regs with:
;** a0: Adr of Source (with Header)  ** a1: Adr of Dest
;**-------------------------------------------------------------------------
;Test  = 0 ;set this to 1 to decrunch ram:Test
;***************************************************************************
;  ifne  Test
_crm:
  MOVE.l d0,a0
  MOVE.l d0,a1

;  MOVE.l  d0,_Data
;  LEA _Data(pc),a0
;  LEA 14(a0),a1
;  BRA NormalDecrunch
;  endc
;*-----------

OverlapDecrunch:
  MOVEM.l d0-d7/a0-a6,-(a7)
  LEA FastDecruncher(pc),a5
  MOVE.l  (a0)+,d0
  CMP.l #"CrM!",d0
  BEQ.b decr
  LEA LZHDecruncher(pc),a5
  CMP.l #"CrM2",d0
  BNE.b NotCrunched
decr:  MOVEQ #0,d0
  MOVE.w  (a0)+,d0  ;MinSecDist
  MOVE.l  (a0)+,d1  ;DestLen
  MOVE.l  (a0)+,d2  ;SrcLen
  LEA 0(a0,d0.l),a2
  CMP.l a1,a2
  BLE.b NoCopy
  MOVE.l  a0,a2
  MOVE.l  a1,a0
  SUB.l d0,a0   ;MinSecDist abziehen
  MOVE.l  a0,a3
  MOVE.l  d2,d7
  LSR.l #2,d7   ;Longs
CopyLoop:
  MOVE.l  (a2)+,(a3)+
  SUBQ.l  #1,d7
  BNE.b CopyLoop
  MOVE.l  (a2)+,(a3)+ ;in case of ...
NoCopy:
  MOVE.l  a0,a2
  JSR (a5)
NotCrunched:
  MOVEM.l (a7)+,d0-d7/a0-a6
  RTS
;**-------------------------------------------------------------------------
;** Jump here To decrunch some Data without any overlap checks
;** The Regs have To loaded with:
;** a0: Adr of Source (with Header)
;** a1: Adr of Dest
;**-------------------------------------------------------------------------
NormalDecrunch:
  MOVEM.l d0-d7/a0-a6,-(a7)
  MOVE.l  (a0)+,d0
  LEA FastDecruncher(pc),a5
  CMP.l #"CrM!",d0
  BEQ.b decr2
  LEA LZHDecruncher(pc),a5
  CMP.l #"CrM2",d0
  BNE.b NotCrunched2
decr2:  TST.w (a0)+   ;skip MinSecDist
  MOVE.l  (a0)+,d1  ;OrgLen
  MOVE.l  (a0)+,d2  ;CrLen
  MOVE.l  a0,a2
  JSR (a5)
NotCrunched2:
  MOVEM.l (a7)+,d0-d7/a0-a6
  RTS
;**-------------------------------------------------------------------------
;** This is the pure Decrunch-Routine
;** The Registers have To be loaded with the following values:
;** a1: Adr of Destination (normal)  ** a2: Adr of Source (packed)
;** d1: Len of Destination   ** d2: Len of Source
;** Leave everything below this Line in its original state!
;**-------------------------------------------------------------------------
FastDecruncher:
  MOVE.l  a1,a5     ;Decrunched Anfang (hier Ende des Decrunchens)
  ADD.l d1,a1
  ADD.l d2,a2
  MOVE.w  -(a2),d0    ;Anz Bits in letztem Wort
  MOVE.l  -(a2),d6    ;1.LW
  MOVEQ #16,d7      ;Anz Bits
  SUB.w d0,d7     ;Anz Bits, die rotiert werden m|ssen
  LSR.l d7,d6     ;1.Bits an Anfang bringen
  MOVE.w  d0,d7     ;Anz Bits, die noch im Wort sind
  MOVEQ #16,d3
  MOVEQ #0,d4
DecrLoop:
  CMP.l a5,a1
  BLE.l DecrEnd    ;a1=a5: fertig (a1<a5: eigentlich Fehler)

  BSR BitTest
  BCC.b InsertSeq    ;1.Bit 0: Sequenz
  MOVEQ #0,d4
;** einzelne Bytes einf|gen **
InsertBytes:
  MOVEQ #8,d1
  BSR GetBits
  MOVE.b  d0,-(a1)
  DBF d4,InsertBytes
  BRA DecrLoop
;*------------
SpecialInsert:
  MOVEQ #14,d4
  MOVEQ #5,d1
  BSR BitTest
  BCS.b IB1
  MOVEQ #14,d1
IB1: BSR GetBits
  ADD.w d0,d4
  BRA InsertBytes
;*------------
InsertSeq:
;** Anzahl der gleichen Bits holen **
  BSR BitTest
  BCS.b AB1
  MOVEQ #1,d1     ;Maske: 0 (1 AB)
  MOVEQ #1,d4     ;normal: Summe 1
  BRA ABGet
AB1:
  BSR BitTest
  BCS.b AB2
  MOVEQ #2,d1     ;Maske: 01 (2 ABs)
  MOVEQ #3,d4     ;ab hier: Summe mindestens 3
  BRA ABGet
AB2:
  BSR BitTest
  BCS.b AB3
  MOVEQ #4,d1     ;Maske: 011 (4 ABs)
  MOVEQ #7,d4     ;hier: Summe 11
  BRA ABGet
AB3:
  MOVEQ #8,d1     ;Maske: 111 (8 ABs)
  MOVEQ #$17,d4     ;hier: Summe 11
ABGet:
  BSR GetBits
  ADD.w d0,d4     ;d0: Ldnge der Sequenz - 1
  CMP.w #22,d4
  BEQ.b SpecialInsert
  BLT.b _Cont
  SUBQ.w  #1,d4
_Cont:
;** SequenzAnbstand holen **
  BSR BitTest
  BCS.b DB1
  MOVEQ #9,d1     ;Maske: 0 (9 DBs)
  MOVEQ #$20,d2
  BRA DBGet
DB1:
  BSR BitTest
  BCS.b DB2
  MOVEQ #5,d1     ;Maske: 01 (5 DBs)
  MOVEQ #0,d2
  BRA DBGet
DB2:
  MOVEQ #14,d1      ;Maske: 11 (12 DBs)
  MOVE.w  #$220,d2
DBGet:
  BSR GetBits
  ADD.w d2,d0
  LEA 0(a1,d0.w),a3   ;a3 auf Anf zu kopierender Seq setzten
InsSeqLoop:
  MOVE.b  -(a3),-(a1)   ;Byte kopieren
  DBF d4,InsSeqLoop

  BRA DecrLoop
;*------------
BitTest:
  SUBQ.w  #1,d7
  BNE.b BTNoLoop
  MOVEQ #16,d7      ;hier kein add notwendig: d7 vorher 0
  MOVE.w  d6,d0
  LSR.l #1,d6     ;Bit rausschieben und Flags setzen
  SWAP  d6      ;ror.l  #16,d6
  MOVE.w  -(a2),d6    ;ndchstes Wort holen
  SWAP  d6      ;rol.l  #16,d6
  LSR.w #1,d0     ;Bit rausschieben und Flags setzen
  RTS
BTNoLoop:
  LSR.l #1,d6     ;Bit rausschieben und Flags setzen
  RTS
;*----------
GetBits:       ;d1:AnzBits->d0:Bits
  MOVE.w  d6,d0     ;d6:Akt Wort
  LSR.l d1,d6     ;ndchste Bits nach vorne bringen
  SUB.w d1,d7     ;d7:Anz Bits, die noch im Wort sind
  BGT.b GBNoLoop
; add.w #16,d7      ;BitCounter korrigieren
  ADD.w d3,d7     ;BitCounter korrigieren
  ROR.l d7,d6     ;restliche Bits re rausschieben
  MOVE.w  -(a2),d6    ;ndchstes Wort holen
  ROL.l d7,d6     ;und zur|ckrotieren
GBNoLoop:
  ADD.w d1,d1     ;*2 (in Tab sind Ws)
  AND.w AndData-2(pc,d1.w),d0  ;unerw|nschte Bits rausschmei_en
  RTS
;*----------
AndData:
  Dc.w  %1,%11,%111,%1111,%11111,%111111,%1111111
  Dc.w  %11111111,%111111111,%1111111111
  Dc.w  %11111111111,%111111111111
  Dc.w  %1111111111111,%11111111111111
;*-----------
DecrEnd:
  RTS   ;a5: Start of decrunched Data
;***************************************************************************
OCmpTab   = 0
OAddTab   = 64
ORealTab  = 128
OAnzPerBits = 1182
OBufLen   = 1246+2
;******************************
LZHDecruncher:
  LEA Tabbs+2(pc),a6
; addq.l  #2,a6
  ADD.l d1,a1
  ADD.l d2,a2

  MOVE.w  -(a2),d0    ;Anz Bits in letztem Wort
  MOVE.l  -(a2),d6    ;1.LW
  MOVEQ #16,d7      ;Anz Bits
  SUB.w d0,d7     ;Anz Bits, die rotiert werden m|ssen
  LSR.l d7,d6     ;1.Bits an Anfang bringen
  MOVE.w  d0,d7     ;Anz Bits, die noch im Wort sind
  MOVEQ #16,d3

BufLoop:
  LEA OAnzPerBits(a6),a0
  MOVEQ #16-1,d2
clear: CLR.l (a0)+
  DBF d2,clear

  LEA OAnzPerBits+32(a6),a0
  LEA ORealTab+30(a6),a4
  MOVEQ #9,d2
  BSR ReadTab
  LEA OAnzPerBits(a6),a0
  LEA ORealTab(a6),a4
  MOVEQ #4,d2
  BSR ReadTab

  LEA OAnzPerBits+32(a6),a3
  LEA OCmpTab-2(a6),a4
  BSR CalcCmpTab
  LEA OAnzPerBits(a6),a3
  LEA OCmpTab+30(a6),a4
  BSR CalcCmpTab

  MOVEQ #16,d1
  BSR GetBits2
  MOVE.w  d0,d5
  LEA ORealTab+30(a6),a0
  LEA -30(a0),a5
decrloop2:  ;** tabu: d3/d6/d7/a0-a2/a4
  MOVE.l  a6,a4
  BSR ReadIt
  BTST  #8,d0
  BNE.b skip
  MOVE.w  d0,d4

  LEA OCmpTab+32(a6),a4
  EXG a0,a5
  BSR ReadIt
  EXG a0,a5
  MOVE.w  d0,d1
  MOVE.w  d0,d2
  BNE.b sc1
  MOVEQ #1,d1
  MOVEQ #16,d2
sc1: BSR GetBits2
  BSET  d2,d0
sc2: LEA 1(a1,d0.w),a3
sloop: MOVE.b  -(a3),-(a1)
  DBF d4,sloop

  MOVE.b  -(a3),-(a1)
  MOVE.b  -(a3),d0
skip:  MOVE.b  d0,-(a1)
  DBF d5,decrloop2
  MOVEQ #1,d1
  BSR GetBits2
  BNE.w BufLoop
  BRA LZHDecrEnd
;*-----------*******************
ReadIt:
  MOVEQ #0,d1     ;Nr Byte
RIloop:
  SUBQ.w  #1,d7
  BEQ.b BTLoop
  LSR.l #1,d6     ;Bit rausschieben und Flags setzen
  BRA BTEnd
BTLoop:
  MOVEQ #16,d7      ;hier kein add notwendig: d7 vorher 0
  MOVE.w  d6,d0
  LSR.l #1,d6     ;Bit rausschieben und Flags setzen
  SWAP  d6      ;ror.l  #16,d6
  MOVE.w  -(a2),d6    ;ndchstes Wort holen
  SWAP  d6      ;rol.l  #16,d6
  LSR.w #1,d0     ;Bit rausschieben und Flags setzen
BTEnd:
  ROXL.w  #1,d1
  MOVE.w  (a4)+,d0
  CMP.w d1,d0
  BLS.b RIloop

  ADD.w 62(a4),d1
  ADD.w d1,d1
  MOVE.w  0(a0,d1.w),d0
  RTS
;*-------------------------------------
GetBits2:       ;d1:AnzBits->d0:Bits
  MOVE.w  d6,d0     ;d6:Akt Wort
  LSR.l d1,d6     ;ndchste Bits nach vorne bringen
  SUB.w d1,d7     ;d7:Anz Bits, die noch im Wort sind
  BGT.b GBNoLoop2
  ADD.w d3,d7     ;BitCounter korrigieren
  ROR.l d7,d6     ;restliche Bits re rausschieben
  MOVE.w  -(a2),d6    ;ndchstes Wort holen
  ROL.l d7,d6     ;und zur|ckrotieren
GBNoLoop2:
  ADD.w d1,d1     ;*2 (in Tab sind Ws)
  AND.w AndData2-2(pc,d1.w),d0  ;unerw|nschte Bits rausschmei_en
  RTS
;*----------
AndData2:
  Dc.w  %1,%11,%111,%1111,%11111,%111111,%1111111
  Dc.w  %11111111,%111111111,%1111111111
  Dc.w  %11111111111,%111111111111
  Dc.w  %1111111111111,%11111111111111
  Dc.w  %111111111111111,%1111111111111111
;*---------------------------------------
ReadTab:
  MOVEM.l d1-d5/a3,-(a7)
  MOVEQ #4,d1
  BSR GetBits2    ;Anz AnzPerBits
  MOVE.w  d0,d5
  SUBQ.w  #1,d5
  MOVEQ #0,d4
  SUB.l a3,a3
RTlop: ADDQ.w  #1,d4
  MOVE.w  d4,d1
  CMP.w d2,d1
  BLE.b c1
  MOVE.w  d2,d1
c1:  BSR GetBits2
  MOVE.w  d0,(a0)+
  ADD.w d0,a3
  DBF d5,RTlop

  MOVE.w  a3,d5
  SUBQ.w  #1,d5
RTlp2: MOVE.w  d2,d1
  BSR GetBits2
  MOVE.w  d0,(a4)+
  DBF d5,RTlp2
  MOVEM.l (a7)+,d1-d5/a3
  RTS
;**************************************************************
CalcCmpTab:
  MOVEM.l d0-d7,-(a7)
  CLR.w (a4)+
  MOVEQ #15-1,d7
  MOVEQ #-1,d4
  MOVEQ #0,d2
  MOVEQ #0,d3
  MOVEQ #1,d1
CClop: MOVE.w  (a3)+,d6
  MOVE.w  d3,64(a4)
  MOVE.w  -2(a4),d0
  ADD.w d0,d0
  SUB.w d0,64(a4)
  ADD.w d6,d3
  MULU  d1,d6
  ADD.w d6,d2
  MOVE.w  d2,(a4)+
cont2:
  LSL.w #1,d2
  DBF d7,CClop
  MOVEM.l (a7)+,d0-d7
  RTS
;*********************************************
LZHDecrEnd:
;LZHDecrLen  equ *-LZHDecruncher

  RTS
;***********************************
Tabbs:  Dc.w  0   ;unbedingt!!!!!!!
CmpTab: Ds.w 16    ;Len
  Ds.w 16    ;Dist
AddTab: Ds.w 16    ;Len
  Ds.w 16    ;Dist
RealTab:
  Ds.w 527   ;Dist+Len
AnzPerBits:
  Ds.w 32    ;Dist+Len
;***************************************************************************
;** Leave everything above this Line in its original state!
;  ifne  Test
_Data: Dc.l 0

;IncBin work:decruncher.s
;  Ds.l 10000
;  endc

;A0 : Start des gecr. Files
;A1 : Ende des gecr. Files
;A2 : Zieladresse an die decruncht werden soll

_ppdecrunch:
  MOVEM.l d0-d7/a0-a6,-(a7)
  MOVE.l  d0,a0
  MOVE.l  d1,a1
  MOVE.l  d2,a2
  bsr dec
  MOVEM.l (a7)+,d0-d7/a0-a6
  RTS

dec:  CMP.l #"PP20",(a0)
  BNE.b nopower
  LEA 4(a0),a5        ;Effiziens
  MOVE.l a1,a0
  MOVE.l a2,a3
  MOVEQ #3,d6
  MOVEQ #7,d7
  MOVEQ #1,d5
  MOVE.l a3,a2        ; remember start of file
  MOVE.l -(a0),d1       ; get file length and empty bits
  TST.b d1
  BEQ.b NoEmptyBits
  BSR ReadBit       ; this will always get the next long (D5 = 1)
  SUBQ.b #1,d1
  LSR.l d1,d5       ; get rid of empty bits
NoEmptyBits:
  LSR.l #8,d1
  ADD.l d1,a3       ; a3 = endfile
LoopCheckCrunch:
  BSR ReadBit       ; check if crunch or normal
  BCS.b CrunchedBytes
NormalBytes:
  MOVEQ #0,d2
_Read2BitsRow:
  MOVEQ #1,d0
  BSR ReadD1
  ADD.w d1,d2
  CMP.w d6,d1
  BEQ.b _Read2BitsRow
ReadNormalByte:
  MOVEQ #7,d0
  BSR ReadD1
  MOVE.b d1,-(a3)
  DBF d2,ReadNormalByte
  CMP.l a3,a2
  BCS.b CrunchedBytes
nopower:RTS


ReadBit:
  LSR.l #1,d5       ; this will also set X if d5 becomes zero
  BEQ.b GetNextLong
  RTS
GetNextLong:
  MOVE.l -(a0),d5
  ROXR.l #1,d5        ; X-bit set by lsr above
  RTS
ReadD1_SUB:
  SUBQ.w #1,d0
ReadD1:
  MOVEQ #0,d1
ReadBits:
  LSR.l #1,d5       ; this will also set X if d5 becomes zero
  BEQ.b GetNext
RotX:
  ROXL.l #1,d1
  DBF d0,ReadBits
  RTS
GetNext:
  MOVE.l -(a0),d5
  ROXR.l #1,d5        ; X-bit set by lsr above
  BRA RotX
CrunchedBytes:
  MOVEQ #1,d0
  BSR ReadD1        ; read code
  MOVEQ #0,d0
  MOVE.b 0(a5,d1.w),d0      ; get number of bits of offset
  MOVE.w d1,d2        ; d2 = code = length-2
  CMP.w d6,d2       ; if d2 = 3 check offset bit and read length
  BNE.b ReadOffset
  BSR ReadBit       ; read offset bit (long/short)
  BCS.b LongBlockOffset
  MOVEQ #7,d0
LongBlockOffset:
  BSR ReadD1_SUB
  MOVE.w d1,d3        ; d3 = offset
_Read3BitsRow:
  MOVEQ #2,d0
  BSR ReadD1
  ADD.w d1,d2       ; d2 = length-1
  CMP.w d7,d1       ; cmp with #7
  BEQ.b _Read3BitsRow
  BRA DecrunchBlock
ReadOffset:
  BSR ReadD1_SUB       ; read offset
  MOVE.w d1,d3        ; d3 = offset
DecrunchBlock:
  ADDQ.w #1,d2
DecrunchBlockLoop:
  MOVE.b 0(a3,d3.w),-(a3)
  DBF d2,DecrunchBlockLoop
EndOfLoop:
  CMP.l a3,a2
  BCS.l LoopCheckCrunch
  RTS
