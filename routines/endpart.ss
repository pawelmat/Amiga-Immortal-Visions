
;		Ending Demo / Credits Part
;		   Specialy Coded to:
;		  ' IMMORTAL VISIONS '
;		   Demo by Suspect'92
;		 Coded by Pillar 18.VI.

;lewy - szybciej, prawy - stop, oba - wyjscie

org	$20000
load	$20000

s:	move.l	(a7)+,return
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	Plane,a0
	move.l	#$5000,d0
cls:	move.b	#0,(a0)+
	dbf	d0,cls
	bsr	init
	lea	$dff000,a0
	bsr	newob

	move.l	#copper,$dff080
	clr.w	$dff088

Mloop:	bra	mloop

Plane:		dc.l	$70000
Place:		dc.l	[$70000+[32*8*80]]+25
;*------------------------------------------------------------------

Vscroll:btst	#10,$dff016
	beq.L	tup
	tst.w	Vcon
	bhi.s	MoveUp

Here:	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	#29,d7
	move.l	textpointer,a0
	move.l	Place,a2
Pline:	lea	font,a1
	move.b	(a0)+,d0
	tst.b	d0
	bne.s	Dalej
	move.l	#text,textpointer
	bra.s	Here
Dalej:	sub.b	#32,d0
	lsl.w	#3,d0
	move.l	#7,d6
letter:	move.b	0(a1,d0.w),(a2,d1.w)
	add.w	#80,d1
	addq.w	#1,d0
	dbf	d6,letter
	adda.l	#1,a2
	moveq	#0,d1
	moveq	#0,d0
	dbf	d7,PLine
	move.w	#8,Vcon
	move.l	a0,textpointer
	bra	moveup
tup:	rts

Moveup:
	move.l	plane,a0
	adda.l	#80,a0
	move.l	plane,a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	#%0100001000101000,d2	; 320x256
	bsr.s	Blit
	subq.w	#1,Vcon
	rts


;  here is the bliter copy routine !!!
; d0 = source modulo
; d1 = destination modulo
; a0 = source address
; a1 = destination address
; d2 = blitt size !!      

blit:	btst	#$e,$dff002
	bne.s	Blit
	lea	$dff000,a6
	move.w  #$09f0,$40(a6)	;bltcon0
	clr.w   $42(a6)		;bltcon1
	move.l  #$ffffffff,$44(a6)	;mask read all
	move.w	d0,$64(a6)	;source		mod
	move.w  d1,$66(a6)	;destination	mod
	move.l  a0,$50(a6)	;source		A
	move.l  a1,$54(a6)	;Destination	D
	move.w  d2,$58(a6)
	rts

Vcon:	dc.w 0
;*------------------------------------------------------------------
;	Some Datas To The Ending Part :

TextPointer:	dc.l	text

;		 123456789012345678901234567890
Text:	dc.b	"                              "
	dc.b	"  FINALY YOU REACHED THE END  "
	dc.b	"         OF THE FIRST         "
	dc.b	"    SUSPECT DEMO CALLED :     "
	dc.b	"                              "
	dc.b	"   .. IMMORTAL VISIONS ..     "
	dc.b	"                              "
	dc.b	"                              "
	dc.b	"                              "
	dc.b	"   CREDITS :                  "
	DC.B    "             XTD - MUSIC      "
	DC.B    "          KALOSZ - MUSIC      "
	DC.B	"         CRYPTON - GFX        "
	DC.B	"           ART B - GFX        "
	DC.B	"            KANE - CODE       "
	DC.B	"          PILLAR - CODE       "
	DC.B	"                              "
	DC.B	"                              "
	DC.B	"                              "
	DC.B	" THANKS ARE BEING SENT TO :   "
	DC.B	"                              "
	DC.B	" BYTEMAN - FOR HELP IN HARD   "
	DC.B	"             TIMES .          "
	DC.B	"     XXX - FOR INSPIRATION    "
	DC.B	"                              "
	DC.B	"                              "
	DC.B	"                              "
	DC.B	"                              "
	dc.b	0,0


Copper:	dc.w $0120,$0000,$0122,$0000
	dc.w $0124,$0000,$0126,$0000
	dc.w $0128,$0000,$012a,$0000
	dc.w $012c,$0000,$012e,$0000
	dc.w $0130,$0000,$0132,$0000
	dc.w $0134,$0000,$0136,$0000
	dc.w $0138,$0000,$013a,$0000
	dc.w $013c,$0000,$013e,$0000

	dc.w $008e,$0171,$0090,$37d1
	dc.w $0092,$003c,$0094,$00d4
	dc.w $0108,$0000,$010a,$0000
	dc.w $0102,$0000,$0104,$0000
scr:	dc.w $00e0,$0007,$00e2,$0000
	dc.l $e40006,$e60000
	dc.l $2c01ff00
	dc.w $0100,%1010001100000000
	dc.w $0182,$0aaa,$0180,$0000
col:
	dc.l $1840fff,$1860aaa
	dc.l $ffdffffe
	dc.l $2801ff00,$9aa000
	dc.l $2a01ff00,$9a2000
	dc.l $2c01ff00,$1000300
	dc.w $ffff,$fffe


Font:
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;" "
dc.b	$30,$30,$30,$30,$20,$00,$20,$00	;"!"
dc.b	$CC,$44,$88,$00,$00,$00,$00,$00	;"""
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"#"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"$"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"%"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"&"
dc.b	$30,$10,$20,$00,$00,$00,$00,$00	;"'"
dc.b	$18,$30,$30,$30,$30,$30,$18,$00	;"("
dc.b	$30,$18,$18,$18,$18,$18,$30,$00	;")"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"*"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"+"
dc.b	$00,$00,$00,$00,$00,$30,$10,$20	;","
dc.b	$00,$00,$00,$FC,$00,$00,$00,$00	;"-"
dc.b	$00,$00,$00,$00,$00,$30,$30,$00	;"."
dc.b	$04,$0C,$18,$30,$60,$C0,$80,$00	;"/"
dc.b	$58,$CC,$CC,$CC,$CC,$CC,$58,$00	;"0"
dc.b	$70,$30,$30,$30,$30,$30,$78,$00	;"1"
dc.b	$58,$CC,$0C,$18,$60,$0C,$FC,$00	;"2"
dc.b	$68,$CC,$0C,$28,$0C,$CC,$68,$00	;"3"
dc.b	$0C,$2C,$4C,$8C,$FE,$0C,$1E,$00	;"4"
dc.b	$FC,$30,$80,$D8,$0C,$CC,$D8,$00	;"5"
dc.b	$58,$CC,$C0,$D8,$CC,$CC,$58,$00	;"6"
dc.b	$FC,$C0,$08,$18,$30,$30,$30,$00	;"7"
dc.b	$58,$CC,$CC,$58,$CC,$CC,$58,$00	;"8"
dc.b	$58,$CC,$CC,$5C,$0C,$CC,$58,$00	;"9"
dc.b	$00,$00,$30,$00,$00,$30,$00,$00	;":"
dc.b	$00,$00,$30,$00,$00,$30,$10,$20	;";"
dc.b	$0C,$18,$30,$60,$30,$18,$0C,$00	;"<"
dc.b	$00,$00,$FC,$00,$FC,$00,$00,$00	;"="
dc.b	$60,$30,$18,$0C,$18,$30,$60,$00	;">"
dc.b	$6C,$C6,$06,$0C,$18,$00,$18,$00	;"?"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"@"
dc.b	$0C,$0C,$2C,$26,$5E,$46,$EE,$00	;"A"
dc.b	$EC,$66,$66,$6C,$66,$66,$EC,$00	;"B"
dc.b	$2E,$62,$E0,$E0,$E0,$62,$2E,$00	;"C"
dc.b	$E8,$6C,$66,$66,$66,$6C,$E8,$00	;"D"
dc.b	$EE,$66,$60,$6C,$60,$66,$EE,$00	;"E"
dc.b	$EE,$66,$60,$6C,$60,$60,$F0,$00	;"F"
dc.b	$2E,$66,$E0,$EE,$E6,$66,$2C,$00	;"G"
dc.b	$F6,$66,$66,$6E,$66,$66,$F6,$00	;"H"
dc.b	$78,$30,$30,$30,$30,$30,$78,$00	;"I"
dc.b	$3C,$18,$18,$18,$D8,$D8,$70,$00	;"J"
dc.b	$F6,$64,$68,$6C,$6E,$66,$F6,$00	;"K"
dc.b	$F0,$60,$60,$60,$62,$66,$FE,$00	;"L"
dc.b	$C6,$EE,$7E,$B6,$86,$86,$CE,$00	;"M"
dc.b	$66,$72,$3A,$5E,$4E,$46,$E6,$00	;"N"
dc.b	$58,$CC,$CC,$CC,$CC,$CC,$58,$00	;"O"
dc.b	$EC,$66,$66,$6C,$60,$60,$F0,$00	;"P"
dc.b	$58,$CC,$CC,$CC,$CC,$58,$1C,$00	;"Q"
dc.b	$EC,$66,$66,$6C,$68,$64,$F6,$00	;"R"
dc.b	$5C,$CC,$C0,$78,$0C,$CC,$D8,$00	;"S"
dc.b	$FC,$B4,$30,$30,$30,$30,$30,$00	;"T"
dc.b	$F6,$62,$62,$62,$62,$62,$2C,$00	;"U"
dc.b	$F6,$62,$62,$62,$22,$3C,$18,$00	;"V"
dc.b	$E6,$C2,$C2,$D2,$DA,$EC,$C6,$00	;"W"
dc.b	$CE,$CC,$68,$30,$58,$4C,$CE,$00	;"X"
dc.b	$E6,$62,$34,$18,$18,$18,$3C,$00	;"Y"
dc.b	$EC,$8C,$18,$30,$60,$CC,$DC,$00	;"Z"
dc.b	$38,$30,$30,$30,$30,$30,$38,$00	;"["
dc.b	$80,$C0,$60,$30,$18,$0C,$04,$00	;"\"
dc.b	$38,$18,$18,$18,$18,$18,$38,$00	;"]"
dc.b	$10,$38,$6C,$00,$00,$00,$00,$00	;"^"
dc.b	$00,$00,$00,$00,$00,$00,$00,$FE	;"_"
dc.b	$30,$20,$10,$00,$00,$00,$00,$00	;"`"
dc.b	$0C,$0C,$2C,$26,$5E,$46,$EE,$00	;"a"
dc.b	$EC,$66,$66,$6C,$66,$66,$EC,$00	;"b"
dc.b	$2E,$62,$E0,$E0,$E0,$62,$2E,$00	;"c"
dc.b	$E8,$6C,$66,$66,$66,$6C,$E8,$00	;"d"
dc.b	$EE,$66,$60,$6C,$60,$66,$EE,$00	;"e"
dc.b	$EE,$66,$60,$6C,$60,$60,$F0,$00	;"f"
dc.b	$2E,$66,$E0,$EE,$E6,$66,$2C,$00	;"g"
dc.b	$F6,$66,$66,$6E,$66,$66,$F6,$00	;"h"
dc.b	$78,$30,$30,$30,$30,$30,$78,$00	;"i"
dc.b	$3C,$18,$18,$18,$D8,$D8,$70,$00	;"j"
dc.b	$F6,$64,$68,$6C,$6E,$66,$F6,$00	;"k"
dc.b	$F0,$60,$60,$60,$62,$66,$FE,$00	;"l"
dc.b	$C6,$EE,$7E,$B6,$86,$86,$CE,$00	;"m"
dc.b	$66,$72,$3A,$5E,$4E,$46,$E6,$00	;"n"
dc.b	$58,$CC,$CC,$CC,$CC,$CC,$58,$00	;"o"
dc.b	$EC,$66,$66,$6C,$60,$60,$F0,$00	;"p"
dc.b	$58,$CC,$CC,$CC,$CC,$58,$1C,$00	;"q"
dc.b	$EC,$66,$66,$6C,$68,$64,$F6,$00	;"r"
dc.b	$5C,$CC,$C0,$78,$0C,$CC,$D8,$00	;"s"
dc.b	$FC,$B4,$30,$30,$30,$30,$30,$00	;"t"
dc.b	$F6,$62,$62,$62,$62,$62,$2C,$00	;"u"
dc.b	$F6,$62,$62,$62,$22,$3C,$18,$00	;"v"
dc.b	$E6,$C2,$C2,$D2,$DA,$EC,$C6,$00	;"w"
dc.b	$CE,$CC,$68,$30,$58,$4C,$CE,$00	;"x"
dc.b	$E6,$62,$34,$18,$18,$18,$3C,$00	;"y"
dc.b	$EC,$8C,$18,$30,$60,$CC,$DC,$00	;"z"
dc.b	$18,$30,$30,$60,$30,$30,$18,$00	;"{"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"|"
dc.b	$30,$18,$18,$0C,$18,$18,$30,$00	;"}"
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;"~"

;------------------------------------------------------------
init:	move	$dff002,olddma
	ori	#$8000,olddma
	move	$dff01c,oldint
	ori	#$8000,oldint
	move	#$3ff,$dff096
	move	#$7fff,$dff09a
	bsr	mt_init
	clr.b	$bfde00		;muzyka pod level6
	move.b	#$82,$bfd400
	move.b	#$37,$bfd500	;timer na $3782(80) - ok. 1 frame
	move.b	#$81,$bfdd00
	move.l	$78,oldlev
	move.l	#newlev,$78
	move.b	#$11,$bfde00	;start timer at line $d0
	move	#$e000,$dff09a
	move	#%1000001111000000,$dff096
	rts

qquit:
	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	$32(a0),$dff080
	move	olddma,$dff096
	move	#$7fff,$dff09a
	move	#$4000,$dff09a
	move.b	#1,$bfdd00
	move.l	oldlev,$78
	move	#$c000,$dff09a
	bsr	mt_end
	move.l	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	move.l	return,a0
	jmp	(a0)

czyjuz:	dc.w	0

newlev:	movem.l	d0-d7/a0-a6,-(sp)
	move.b	$bfdd00,d0
	btst	#6,$bfe001
	bne	newl4
	clr	czyjuz
newl4:	tst	czyjuz
	bne	newl2
	move	#1,czyjuz
	bsr	vscroll
	bra	newl3
newl2:	clr	czyjuz
newl3:	bsr	mt_music
	move.l	#$dff000,a0
	bsr	fade
	bsr	graf
	bsr	graf
	bsr	graf
	bsr	graf
	bsr	graf
	movem.l	(sp)+,d0-d7/a0-a6
	btst	#6,$bfe001
	bne	nopress
	btst	#10,$dff016
	bne	nopress
	move	(sp)+,storee
	move.l	(sp)+,adress
	move.l	#qquit,-(sp)
	move	storee,-(sp)
nopress:move	#$2000,$dff09c
	rte

storee:		dc.w	0
adress:		dc.l	0

return:		dc.l	0
oldint:		dc.w	0
olddma:		dc.w	0
oldlev:		dc.l	0
gfxname:	dc.b	'graphics.library',0,0



mt_init	LEA	mt_data,A0
	MOVE.L	A0,mt_SongDataPtr
	LEA	250(A0),A1
	MOVE.W	#511,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.W	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ	#1,D2

	MOVE.W	D2,D3
	MULU	#128,D3
	ADD.L	#766,D3
	ADD.L	mt_SongDataPtr(PC),D3
	MOVE.L	D3,mt_LWTPtr

	LEA	mt_SampleStarts(PC),A1
	MULU	#128,D2
	ADD.L	#762,D2
	ADD.L	(A0,D2.L),D2
	ADD.L	mt_SongDataPtr(PC),D2
	ADDQ.L	#4,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ADD.L	D1,D1
	ADD.L	D1,A2
	LEA	8(A0),A0
	DBRA	D0,mtloop3

;	OR.B	#2,$BFE001
	lea	mt_speed(PC),A4
	MOVE.B	#6,(A4)
	CLR.B	mt_counter-mt_speed(A4)
	CLR.B	mt_SongPos-mt_speed(A4)
	CLR.W	mt_PatternPos-mt_speed(A4)
mt_end	LEA	$DFF096,A0
	CLR.W	$12(A0)
	CLR.W	$22(A0)
	CLR.W	$32(A0)
	CLR.W	$42(A0)
	MOVE.W	#$F,(A0)
	RTS

mt_music
	MOVEM.L	D0-D4/D7/A0-A6,-(SP)
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA.W	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA.W	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	$DFF090,A5
	LEA	mt_chan1temp-44(PC),A6
	BSR.W	mt_CheckEfx
	BSR.W	mt_CheckEfx
	BSR.W	mt_CheckEfx
	BRA.W	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	(A0),A3
	LEA	122(A0),A2	;pattpo
	LEA	762(A0),A0	;patterndata
	CLR.W	mt_DMACONtemp

	LEA	$DFF090,A5
	LEA	mt_chan1temp-44(PC),A6
	BSR.S	mt_DoVoice
	BSR.S	mt_DoVoice
	BSR	mt_DoVoice
	BSR	mt_DoVoice
	BRA.W	mt_SetDMA

mt_DoVoice
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	LEA	128(A2),A2
	MOVE.B	(A2,D0.W),D1
	MOVE.W	mt_PatternPos(PC),D2
	LSL	#7,D1
	LSR.W	#1,D2
	ADD.W	D2,D1
	LEA	$10(A5),A5
	LEA	44(A6),A6

	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR.W	mt_PerNop
mt_plvskip
	MOVE.W	(A0,D1.W),D1
	LSL.W	#2,D1
	MOVE.L	A0,-(sp)
	MOVE.L	mt_LWTPtr(PC),A0
	MOVE.L	(A0,D1.W),(A6)
	MOVE.L	(sp)+,A0
	MOVE.B	2(A6),D2
	AND.L	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	SUBQ	#1,D2
	MOVE	D2,D4
	ADD	D2,D2
	ADD	D2,D2
	LSL	#3,D4
	MOVE.L	(A1,D2.L),4(A6)
	MOVE.W	(A3,D4.W),8(A6)
	MOVE.W	(A3,D4.W),40(A6)
	MOVE.W	2(A3,D4.W),18(A6)
	MOVE.L	4(A6),D2	; Get start
	MOVE.W	4(A3,D4.W),D3	; Get repeat
	BEQ.S	mt_NoLoop
	MOVE.W	D3,D0		; Get repeat
	ADD.W	D3,D3
	ADD.L	D3,D2		; Add repeat
	ADD.W	6(A3,D4.W),D0	; Add replen
	MOVE.W	D0,8(A6)

mt_NoLoop
	MOVE.L	D2,10(A6)
	MOVE.L	D2,36(A6)
	MOVE.W	6(A3,D4.W),14(A6)	; Save replen
	MOVE.B	19(A6),9(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	mt_CheckMoreEfx	; If no note

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune

	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR.W	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR.W	mt_SetTonePorta
	BRA.W	mt_CheckMoreEfx

mt_DoSetFineTune
	BSR.W	mt_SetFineTune

mt_SetPeriod
	MOVEM.L	D1/A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1

mt_SetPeriod2
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#36,D7
mt_ftuloop
	CMP.W	(A1)+,D1
	BHS.S	mt_ftufound
	DBRA	D7,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	18(A6),D1
	LSL	#3,D1
	MOVE	D1,D0
	LSL	#3,D1
	ADD	D0,D1
	MOVE.W	-2(A1,D1.W),16(A6)

	MOVEM.L	(SP)+,D1/A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ.W	mt_CheckMoreEfx

	MOVE.W	20(A6),$DFF096
	BTST	#2,30(A6)
	BNE.S	mt_vibnoc
	CLR.B	27(A6)
mt_vibnoc
	BTST	#6,30(A6)
	BNE.S	mt_trenoc
	CLR.B	29(A6)
mt_trenoc
	MOVE.L	4(A6),(A5)	; Set start
	MOVE.W	8(A6),4(A5)	; Set length
	MOVE.W	16(A6),6(A5)	; Set period
	MOVE.W	20(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA.W	mt_CheckMoreEfx
 
mt_SetDMA
	OR.W	#$8000,mt_DMACONtemp
	bsr.w	mt_WaitDMA

	MOVE.W	mt_dmacontemp(pc),$DFF096
	bsr.w	mt_WaitDMA

	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	10(A6),(A5)
	MOVE.W	14(A6),4(A5)
	MOVE.L	54(A6),$10(A5)
	MOVE.W	58(A6),$14(A5)
	MOVE.L	98(A6),$20(A5)
	MOVE.W	102(A6),$24(A5)
	MOVE.L	142(A6),$30(A5)
	MOVE.W	146(A6),$34(A5)

mt_dskip
	lea	mt_speed(PC),A4
	ADDQ.W	#4,mt_PatternPos-mt_speed(A4)
	MOVE.B	mt_PattDelTime-mt_speed(A4),D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2-mt_speed(A4)
	CLR.B	mt_PattDelTime-mt_speed(A4)
mt_dskc	TST.B	mt_PattDelTime2-mt_speed(A4)
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2-mt_speed(A4)
	BEQ.S	mt_dska
	SUBQ.W	#4,mt_PatternPos-mt_speed(A4)
mt_dska	TST.B	mt_PBreakFlag-mt_speed(A4)
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag-mt_speed(A4)
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos-mt_speed(A4)
	LSL	#2,D0
	MOVE.W	D0,mt_PatternPos-mt_speed(A4)
mt_nnpysk
	CMP.W	#256,mt_PatternPos-mt_speed(A4)
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL	#2,D0
	MOVE.W	D0,mt_PatternPos-mt_speed(A4)
	CLR.B	mt_PBreakPos-mt_speed(A4)
	CLR.B	mt_PosJumpFlag-mt_speed(A4)
	ADDQ.B	#1,mt_SongPos-mt_speed(A4)
	AND.B	#$7F,mt_SongPos-mt_speed(A4)
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	248(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos-mt_speed(A4)
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag-mt_speed(A4)
	BNE.S	mt_NextPosition
	MOVEM.L	(SP)+,D0-D4/D7/A0-A6
	RTS

mt_CheckEfx
	LEA	$10(A5),A5
	LEA	44(A6),A6
	BSR.W	mt_UpdateFunk
	MOVE.W	2(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	2(A6),D0
	MOVEQ	#$0F,D1
	AND.L	D1,D0
	BEQ.S	mt_Arpeggio
	SUBQ	#1,D0
	BEQ.W	mt_PortaUp
	SUBQ	#1,D0
	BEQ.W	mt_PortaDown
	SUBQ	#1,D0
	BEQ.W	mt_TonePortamento
	SUBQ	#1,D0
	BEQ.W	mt_Vibrato
	SUBQ	#1,D0
	BEQ.W	mt_TonePlusVolSlide
	SUBQ	#1,D0
	BEQ.W	mt_VibratoPlusVolSlide
	SUBQ	#8,D0
	BEQ.W	mt_E_Commands
SetBack	MOVE.W	16(A6),6(A5)
	ADDQ	#7,D0
	BEQ.W	mt_Tremolo
	SUBQ	#3,D0
	BEQ.W	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	16(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	TST.W	D0
	BEQ.S	mt_Arpeggio2
	SUBQ	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	16(A6),6(A5)
	RTS

mt_Arpeggio1
	MOVE.B	3(A6),D0
	AND.W	#15,D0
mt_Arpeggio3
	ADD.W	D0,D0
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D1
	MOVE.B	18(A6),D1
	LSL	#3,D1
	MOVE	D1,D2
	LSL	#3,D1
	ADD	D2,D1
	ADD.L	D1,A0

	MOVE.W	16(A6),D1
	MOVEQ	#36,D7
mt_arploop
	CMP.W	(A0)+,D1
	BHS.S	mt_Arpeggio4
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	-2(A0,D0.W),6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,16(A6)
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,16(A6)
	OR.W	#113,16(A6)
mt_PortaUskip
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	3(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,16(A6)
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,16(A6)
	OR.W	#856,16(A6)
mt_PortaDskip
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D0
	MOVE.B	18(A6),D0
	ADD	D0,D0
	MOVE	D0,D7
	ADD	D0,D0
	ADD	D0,D0
	ADD	D0,D7
	LSL	#3,D0
	ADD	D7,D0
	ADD.L	D0,A0

	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	BTST	#3,18(A6)
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,24(A6)
	MOVE.W	16(A6),D0
	CLR.B	22(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE.W	mt_Return2
	MOVE.B	#1,22(A6)
	RTS

mt_ClearTonePorta
	CLR.W	24(A6)
	RTS

mt_TonePortamento
	MOVE.B	3(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,23(A6)
	CLR.B	3(A6)
mt_TonePortNoChange
	TST.W	24(A6)
	BEQ.W	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	23(A6),D0
	TST.B	22(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,16(A6)
	MOVE.W	24(A6),D0
	CMP.W	16(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	24(A6),16(A6)
	CLR.W	24(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,16(A6)
	MOVE.W	24(A6),D0
	CMP.W	16(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	24(A6),16(A6)
	CLR.W	24(A6)

mt_TonePortaSetPer
	MOVE.W	16(A6),D2
	MOVE.B	31(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D0
	MOVE.B	18(A6),D0
	LSL	#3,D0
	MOVE	D0,D1
	LSL	#3,D0
	ADD	D1,D0
	ADD.L	D0,A0

	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	3(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	26(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	3(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,26(A6)
mt_Vibrato2
	MOVE.B	27(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVE.B	30(A6),D2
	AND.W	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	27(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	26(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	16(A6),D0
	TST.B	27(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	26(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,27(A6)
	RTS

mt_TonePlusVolSlide
	BSR.W	mt_TonePortNoChange
	BRA.W	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA.W	mt_VolumeSlide

mt_Tremolo
	MOVE.B	3(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	28(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	3(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,28(A6)
mt_Tremolo2
	MOVE.B	29(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	30(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	27(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	28(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	19(A6),D0
	TST.B	29(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	28(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,29(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,32(A6)
mt_sononew
	MOVE.B	32(A6),D0
	LSL.W	#7,D0
	CMP.W	8(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,8(A6)
	ADD.W	D0,D0
	ADD.L	D0,4(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,8(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,19(A6)
	CMP.B	#$40,19(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,19(A6)
mt_vsuskip
	MOVE.B	19(A6),9(A5)
	RTS

mt_VolSlideDown
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,19(A6)
	BPL.S	mt_vsdskip
	CLR.B	19(A6)
mt_vsdskip
	MOVE.B	19(A6),9(A5)
	RTS

mt_PositionJump
	MOVE.B	3(A6),D0
	SUBQ	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVE.B	3(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,19(A6)
	MOVE.B	D0,9(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	MOVE.W	D0,D2
	LSR.B	#4,D0
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D0,D0
	ADD	D1,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ.W	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR.W	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	SUB.B	#9,D0
	BEQ.W	mt_SampleOffset
	SUBQ	#2,D0
	BEQ.W	mt_PositionJump
	SUBQ	#1,D0
	BEQ	mt_VolumeChange
	SUBQ	#1,D0
	BEQ.S	mt_PatternBreak
	SUBQ	#1,D0
	BEQ.S	mt_E_Commands
	SUBQ	#1,D0
	BEQ.S	mt_SetSpeed
	BRA.W	mt_PerNop

mt_E_Commands
	MOVE.B	3(A6),D0
	AND.W	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	SUBQ	#1,D0
	BEQ.W	mt_FinePortaUp
	SUBQ	#1,D0
	BEQ.W	mt_FinePortaDown
	SUBQ	#1,D0
	BEQ.S	mt_SetGlissControl
	SUBQ	#1,D0
	BEQ	mt_SetVibratoControl

	SUBQ	#1,D0
	BEQ	mt_SetFineTune
	SUBQ	#1,D0

	BEQ	mt_JumpLoop
	SUBQ	#1,D0
	BEQ.W	mt_SetTremoloControl
	SUBQ	#2,D0
	BEQ.W	mt_RetrigNote
	SUBQ	#1,D0
	BEQ.W	mt_VolumeFineUp
	SUBQ	#1,D0
	BEQ.W	mt_VolumeFineDown
	SUBQ	#1,D0
	BEQ.W	mt_NoteCut
	SUBQ	#1,D0
	BEQ.W	mt_NoteDelay
	SUBQ	#1,D0
	BEQ.W	mt_PatternDelay
	BRA.W	mt_FunkIt

mt_FilterOnOff
	MOVE.B	3(A6),D0
	AND.B	#1,D0
	ADD.B	D0,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,31(A6)
	OR.B	D0,31(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,30(A6)
	OR.B	D0,30(A6)
	RTS

mt_SetFineTune
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,18(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	34(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,34(A6)
	BEQ.W	mt_Return2
mt_jmploop 	MOVE.B	33(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,34(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR	#2,D0
	MOVE.B	D0,33(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,30(A6)
	OR.B	D0,30(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,d1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.W	20(A6),$DFF096	; Channel DMA off
	MOVE.L	4(A6),(A5)	; Set sampledata pointer
	MOVE.W	8(A6),4(A5)	; Set length
	BSR.W	mt_WaitDMA
	MOVE.W	20(A6),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	BSR.W	mt_WaitDMA
	MOVE.L	10(A6),(A5)
	MOVE.L	14(A6),4(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$F,D0
	BRA.W	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	BRA.W	mt_VolSlideDown2

mt_NoteCut
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE.W	mt_Return2
	CLR.B	19(A6)
	CLR.W	8(A5)
	RTS

mt_NoteDelay
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	CMP.B	mt_Counter(PC),D0
	BNE.W	mt_Return2
	MOVE.W	(A6),D0
	BEQ.W	mt_Return2
	MOVE.L	D1,-(SP)
	BRA.W	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE.W	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,31(A6)
	OR.B	D0,31(A6)
	TST.B	D0
	BEQ.W	mt_Return2
mt_UpdateFunk
	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	31(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,35(A6)
	BTST	#7,35(A6)
	BEQ.S	mt_funkend
	CLR.B	35(A6)

	MOVE.L	10(A6),D0
	MOVEQ	#0,D1
	MOVE.W	14(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	36(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	10(A6),A0
mt_funkok
	MOVE.L	A0,36(A6)
	NEG.B	(A0)
	SUBQ.B	#1,(A0)
mt_funkend
	MOVEM.L	(SP)+,D1/A0
	RTS

mt_WaitDMA
	MOVEQ	#3,D0
mt_WaitDMA2
	MOVE.B	$DFF006,D1
mt_WaitDMA3
	CMP.B	$DFF006,D1
	BEQ.S	mt_WaitDMA3
	DBF	D0,mt_WaitDMA2
	RTS

mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	blk.l	5
		dc.w	1
		blk.w	21
		dc.w	2
		blk.w	21
		dc.w	4
		blk.w	21
		dc.w	8
		blk.w	11

mt_SampleStarts	blk.l	31,0

mt_SongDataPtr	dc.l 0
mt_LWTPtr	dc.l 0
mt_oldirq	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0,0
mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0

mt_data=$50000
>extern	"df0:modules/mod.fco.pro",mt_data,-1

end:

;-------------------------------------------------------------------
screen=$60000

heith=256
row=80
koniec=heith*row
vmid=128
hmid=320

allobjects=15
objectnum:	dc.w	0
objecttab:	dc.l	ob1,ob15,ob3,ob4,ob5,ob6,ob7,ob8,ob9,ob10,ob11,ob12,ob13,ob14,ob2

object:		dc.l	0		;tu pierwszy obiekt
timer:		dc.w	staytime
fadetime=3
staytime=1600
andval:		dc.w	0
collicz:	dc.w	0

kr1:		dc.w	0
kr2:		dc.w	0
oldpoint:	dc.l	0
angle1:		dc.w	0
angle2:		dc.w	0
speed1:		dc.w	0
speed2:		dc.w	0
per1:		dc.w	100
per2:		dc.w	100
padd1:		dc.w	4
padd2:		dc.w	4
pe1:		dc.w	0
pe2:		dc.w	0
colstore:	dc.w	0
flag:		dc.w	0

even
;-------------------------------------------------------------------
quit:	rts

graf:
	bsr	ustal
	move	oldpoint,d2
	move	oldpoint+2,d3
	bsr	makeline
	move	d0,oldpoint

	move	d1,oldpoint+2

	move	angle1,d0
	add	speed1,d0
	btst.l	#8,d0
	beq	gr3
	addi	kr1,d0
	andi.l	#$ff,d0
	move	padd1,d1
	addi	d1,per1
	andi	#$7f,per1
	cmpi	#0,per1
	bne	gr3
	neg	padd1
	move	padd1,d1
	addi	d1,per1
	andi	#$7f,per1
gr3:	move	d0,angle1
	move	angle2,d0
	add	speed2,d0
	btst.l	#8,d0
	beq	gr4
	addi	kr2,d0
	andi.l	#$ff,d0
	move	padd2,d1
	addi	d1,per2
	andi	#$7f,per2
	cmpi	#0,per2
	bne	gr4
	neg	padd2
	move	padd2,d1
	addi	d1,per2
	andi	#$7f,per2
gr4:	move	d0,angle2
	rts
fade:
	subi	#1,timer		;sprawdz czas napisu
	bne	quit
	move	#fadetime,timer
	move	#$111,d0
	and	andval,d0
	cmpi	#0,col+2
	beq	fout1			;nie odejmij jesli kolor=0
	sub	d0,col+2
fout1:	subi	#1,collicz
	bne	quit
	move	#staytime,timer

newob:	bsr	clear			;wyczysc ekran
	move	objectnum,d0
	cmpi	#allobjects,d0
	bne	new2
	move	#1,flag
	clr	objectnum
new2:	lea	objecttab,a1
	move	objectnum,d0
	lsl	#2,d0
	move.l	(a1,d0.w),object
	move.l	object,a1		;adres danych obiektu
	move	(a1)+,andval
	move	(a1)+,col+2
	move	(a1)+,collicz
	move.l	(a1)+,angle1		;copy fr,tr
	move.l	(a1)+,speed1		;sr,ai
	move.l	(a1)+,kr1
	move.l	(a1)+,per1
	move.l	(a1)+,padd1
	addi	#1,objectnum
	bsr	ustal
	move	d0,oldpoint
	move	d1,oldpoint+2
	rts
count:
	lsl	#1,d0
	move	(a1,d0),d0
	mulu	per1,d0
	asr	#7,d0
	lsl	#1,d1
	move	(a1,d1),d1
	mulu	per2,d1
	asr	#8,d1
	rts

ustal:	clr.l	d0
	clr.l	d1
	move	angle1,d0
	move	angle2,d1
	lea	sinus,a1
	bsr	count
	addi	#hmid,d0
	addi	#vmid,d1
	rts

makeline:				;rysuj linie
	movem.l	d0-d7,-(sp)
wait2:	btst	#14,2(a0)
	bne	wait2	
	cmp.w	d1,d3
	bge	p1
	exg	d2,d0
	exg	d1,d3
p1:	addq	#1,d1
	moveq	#$f,d4	
	and.w	d2,d4
	sub.w	d3,d1
	neg.w	d1
	mulu	#row,d3		;wys. linii * szer. ekranu
	sub.w	d2,d0
	blt	p5
	cmp.w	d0,d1
	bge	p4
	moveq	#$19,d7
	bra	p9
p4:	moveq	#$5,d7 
	exg	d0,d1
	bra	p9
p5:	neg.w	d0
	cmp.w	d0,d1
	bge	p8
	moveq	#$1d,d7
	bra	p9
p8:	moveq	#$d,d7
	exg	d0,d1
p9:	asl.w	#1,d1
	asr.w	#$3,d2
	ext.l	d2
	add.l	d2,d3
	move.w	d1,d2
 	sub.w	d0,d2 
	bge	p10
	ori.w	#$40,d7
p10:	move.w	d2,d6
	move.w	d1,$62(a0)
	move.w	d2,d1	
	sub.w	d0,d1
	move.w	d1,$64(a0)
	move.w	#row,$60(a0)	;szerokosc ekranu
	addq.w	#1,d0
	asl.w	#6,d0
	addq.w	#2,d0
	ror.l	#4,d4
	or.l	d4,d7
	move.w	#$8000,$74(a0)
	ori.l	#$bca0000,d7
	add.l	#screen,d3	;rastport
	move.l	d7,$40(a0)
	move.w	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move.w	#$ffff,$72(a0)
	move.w	d0,$58(a0)
	movem.l	(a7)+,d0-d7
	rts

clear:	btst.b	#14,$2(a0)		;czyszczenie ekranu
	bne	clear
	clr.w	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#screen,$54(a0)
	move.w	#heith*64+[row/2],$58(a0)
	rts

sinus:
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0031,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0061,$0067,$006D,$0073,$0078,$007E,$0083,$0088
	dc.w	$008E,$0093,$0098,$009D,$00A2,$00A7,$00AB,$00B0
	dc.w	$00B4,$00B9,$00BD,$00C1,$00C5,$00C9,$00CD,$00D1
	dc.w	$00D4,$00D7,$00DB,$00DE,$00E1,$00E4,$00E6,$00E9
	dc.w	$00EC,$00EE,$00F0,$00F2,$00F4,$00F6,$00F7,$00F9
	dc.w	$00FA,$00FB,$00FC,$00FD,$00FD,$00FE,$00FE,$00FE
	dc.w	$00FE,$00FE,$00FE,$00FE,$00FD,$00FC,$00FB,$00FA
	dc.w	$00F9,$00F8,$00F6,$00F5,$00F3,$00F1,$00EF,$00ED
	dc.w	$00EA,$00E8,$00E5,$00E2,$00DF,$00DC,$00D9,$00D6
	dc.w	$00D2,$00CF,$00CB,$00C7,$00C3,$00BF,$00BB,$00B7
	dc.w	$00B2,$00AE,$00A9,$00A4,$009F,$009A,$0095,$0090
	dc.w	$008B,$0086,$0080,$007B,$0075,$0070,$006A,$0064
	dc.w	$005F,$0059,$0053,$004D,$0047,$0041,$003B,$0035
	dc.w	$002E,$0028,$0022,$001C,$0015,$000F,$0009,$0003
	dc.w	$FFFD,$FFF7,$FFF1,$FFEB,$FFE4,$FFDE,$FFD8,$FFD2
	dc.w	$FFCB,$FFC5,$FFBF,$FFB9,$FFB3,$FFAD,$FFA7,$FFA1
	dc.w	$FF9C,$FF96,$FF90,$FF8B,$FF85,$FF80,$FF7A,$FF75
	dc.w	$FF70,$FF6B,$FF66,$FF61,$FF5C,$FF57,$FF52,$FF4E
	dc.w	$FF49,$FF45,$FF41,$FF3D,$FF39,$FF35,$FF31,$FF2E
	dc.w	$FF2A,$FF27,$FF24,$FF21,$FF1E,$FF1B,$FF18,$FF16
	dc.w	$FF13,$FF11,$FF0F,$FF0D,$FF0B,$FF0A,$FF08,$FF07
	dc.w	$FF06,$FF05,$FF04,$FF03,$FF02,$FF02,$FF02,$FF02
	dc.w	$FF02,$FF02,$FF02,$FF03,$FF03,$FF04,$FF05,$FF06
	dc.w	$FF07,$FF09,$FF0A,$FF0C,$FF0E,$FF10,$FF12,$FF14
	dc.w	$FF17,$FF1A,$FF1C,$FF1F,$FF22,$FF25,$FF29,$FF2C
	dc.w	$FF2F,$FF33,$FF37,$FF3B,$FF3F,$FF43,$FF47,$FF4C
	dc.w	$FF50,$FF55,$FF59,$FF5E,$FF63,$FF68,$FF6D,$FF72
	dc.w	$FF78,$FF7D,$FF82,$FF88,$FF8D,$FF93,$FF99,$FF9F
	dc.w	$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCF
	dc.w	$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA,$0000


ob1:
dc.w	$ff0,$880	;maska,kolor
dc.w	$8		;czas=kolor
dc.w	128,128		;angle
dc.w	2,4		;speed
dc.w	2,4		;kr addition
dc.w	100,120		;procent powiekszenia
dc.w	4,2		;szybkosc powiekszania

ob2:	dc.w	$f0,$e0,$e,64,120,2,5,1,2,127,100,1,4
ob3:	dc.w	$f0f,$c0c,$c,128,128,3,6,2,3,100,100,-4,4
ob4:	dc.w	$ff,$ff,$f,190,0,4,4,5,4,100,100,-4,4
ob5:	dc.w	$ff0,$aa0,$a,120,64,1,3,2,4,120,64,8,4
ob6:	dc.w	$f0f,$909,$9,128,120,3,-4,4,-3,100,100,2,-2
ob7:	dc.w	$f0,$f0,$f,64,0,2,6,3,7,0,100,8,-2
ob8:	dc.w	$f,$f,$f,128,128,3,6,2,3,100,100,4,-4
ob9:	dc.w	$ff,$aa,$a,20,90,2,-4,3,-3,120,64,2,4	
ob10:	dc.w	$f0f,$e0e,$e,50,120,2,-3,4,-2,120,100,-4,-2
ob11:	dc.w	$ff0,$aa0,$a,40,30,-3,2,-4,5,100,100,-2,1
ob12:	dc.w	$ff,$dd,$d,128,60,-3,3,-4,4,100,100,2,-4
ob13:	dc.w	$f,$f,$f,20,110,3,-2,2,-1,100,64,-1,4
ob14:	dc.w	$f0f,$c0c,$c,50,40,-3,4,-4,2,64,100,2,4
ob15:	dc.w	$ff0,$cc0,$c,120,120,-3,2,-4,3,100,100,4,4
