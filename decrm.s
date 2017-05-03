
	;crunchmania decruncher....
	;

	elseif

OverlapDecrunch:
  MOVEM.l d0-d7/a0-a6,-(a7)
  ;
  MOVE.l d0,a0
  MOVE.l d0,a1
  ;
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

	elseif

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
