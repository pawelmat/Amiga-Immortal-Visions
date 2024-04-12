
;		*****************************************	
;		*	   DEFORMATION BALL		*
;		*	 ----------------------		*
;		*					*
;		*  	  Coding on 06.04.1992		*
;		*	  by  KANE  of SUSPECT		*
;		*****************************************


org	$20000
load	$20000

s:
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	$32(a0),oldcop
	move	$dff002,olddma
	ori	#$8000,olddma
	move	#%1000001111100000,$dff096
	move	$dff01c,oldint
	move	#$7fff,$dff09a


	bsr	de_ball

	move	olddma,$dff096
	move.l	oldcop,$dff080
	ori	#$8000,oldint
	move	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	rts

oldint:		dc.w	0
oldcop:		dc.l	0
olddma:		dc.l	0
gfxname:	dc.b	'graphics.library',0,0

de_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
de_color:
dc.l	$1800000,$182000f,$1840f00,$18600f0
dc.l	$920038,$9400d0
de_screen:
dc.l	$e00007,$e20000,$e40007,$e60000
dc.l	$1020000,$1080000,$10a0000	;bplcon1,modulo1
dc.l	$5001ff00,$01002300
dc.l	$f001ff00,$01000300
dc.l	$fffffffe

;-------------------------------------------------------------------
scron:		dc.l	$76000
scroff:		dc.l	$76000+[2*[[de_heith+1]*40]]
de_buffer=$70000

de_heith=160
de_pointtab:
dc.w	0,64,128
dc.w	0,6,4
;-------------------------------------------------------------------

de_ball:
	move.l	#de_copper,$dff080
	clr	$dff088
	bsr	de_makeball
	lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
de_control:
	cmpi.b	#$ff,6(a0)
	bne	de_control
	bsr	de_chgscr
	bsr	de_rysuj
	btst.b	#6,$bfe001
	bne	de_control
de_quit:	rts

de_chgscr:move.l	scron,d0		;zmien ekrany
	move.l	scroff,d1
	move.l	d0,scroff
	move.l	d1,scron
	move	d1,de_screen+6
	swap	d1
	move	d1,de_screen+2
	swap	d1
	add.l	#[de_heith+1]*40,d1
	move	d1,de_screen+14
	swap	d1
	move	d1,de_screen+10
de_wait1:btst.b	#14,$2(a0)
	bne	de_wait1
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	scroff,$54(a0)
	move	#[de_heith+1]*64+40,$58(a0)
	rts

de_rysuj:	btst.b	#14,$2(a0)
	bne	de_rysuj
	lea	de_pointtab,a5
	lea	de_buffer,a1
	move.l	scroff,a2
	lea	sinus,a3
	lea	sinus+$80,a4
	move	(a1)+,d7

	move.l	#[80*40],d0
	adda.l	d0,a2
	move.l	a2,a6
	add.l	#[de_heith+1]*40,a6
	move	8(a5),d0
	addi	d0,2(a5)
	move	10(a5),d0
	addi	d0,4(a5)

	move	4(a5),d0
	move	2(a5),d6
	lsl	#1,d0
	lsl	#1,d6
	andi	#$1fe,d0
	andi	#$1fe,d6

de_narys2:	move	(a1)+,d1
	move	(a1)+,d2
	move	d1,d4
	move	d2,d5
	mulu	(a3,d0.w),d4
	mulu	(a4,d0.w),d5
	sub	d4,d5
	asr	#8,d5
	mulu	(a3,d0.w),d1
	mulu	(a4,d0.w),d2
	add	d2,d1
	asr	#8,d1
	exg	d0,d6

	move	d1,d2
	move	(a1)+,d1	
	move	d1,d4
	move	d5,d3
	mulu	(a3,d0.w),d4
	mulu	(a4,d0.w),d5
	sub	d4,d5
	asr	#8,d5
	mulu	(a3,d0.w),d1
	mulu	(a4,d0.w),d3
	add	d3,d1
	asr	#8,d1
	move	d5,d3
	exg	d0,d6

	addi	#160,d1
	mulu	#40,d2
	move	d1,d3
	lsr	#3,d1
	andi	#7,d3
	eori	#7,d3
	addi	d1,d2
	move	(a1)+,d1
	btst	#0,d1
	beq	de_nar3
	bset	d3,(a2,d2.w)
de_nar3:btst	#1,d1
	beq	de_nar4
	bset	d3,(a6,d2.w)
de_nar4:dbf	d7,de_narys2
	rts

;ilosc punktow:	 (256/Xplot) * [ (128/Zplot) - 1 ]

de_makeball:
	move	#80,d0		;Xr
	move	#80,d1		;Yr
	move	#60,d2		;Zr
	move	#4,d3		;Xplot	(najmniej 4*4)-dzielniki 128
	move	#16,d4		;Zplot
de_create:
	movem.l	a1-a5/d0-d7,-(a7)
	lea	de_ctab,a5
	lea	de_buffer,a1
	move.l	a1,a2
	move	#-1,(a1)+
	lea	sinus,a3
	lea	sinus+$80,a4
	clr.l	d6		;anglex
	clr.l	d7		;anglez
de_oblicz:
	addi	d4,d7
	move	d7,d5
	btst	#7,d5
	bne	de_crend
	lsl	#1,d5
	movem.l	d0-d2,-(a7)
	mulu	(a3,d5.w),d0	;x
	mulu	(a4,d5.w),d2	;z
	mulu	(a3,d5.w),d1	;y
	asr	#8,d0
	asr	#8,d1
	asr	#8,d2
de_obroc:
	move	d6,d5
	lsl	#1,d5
	movem.l	d0/d1,-(a7)
	mulu	(a3,d5.w),d0
	mulu	(a4,d5.w),d1
	asr	#8,d0
	asr	#8,d1
	move	d2,(a1)+
	move	d1,(a1)+
	move	d0,(a1)+
	move	de_pnt,d0
	move	(a5,d0.w),(a1)+
	addi	#1,(a2)
	movem.l	(a7)+,d0/d1
	addi	d3,d6
	andi	#$ff,d6
	bne	de_obroc
	movem.l	(a7)+,d0-d2	
	addi	#2,de_pnt
	bra	de_oblicz
de_crend:movem.l (a7)+,a1-a5/d0-d7
	rts


de_pnt:	dc.w	0
de_ctab:dc.w	1,2,3,3,3,2,1

sinus:
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0032,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0062,$0068,$006D,$0073,$0079,$007E,$0084,$0089
	dc.w	$008E,$0093,$0099,$009E,$00A2,$00A7,$00AC,$00B1
	dc.w	$00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D1
	dc.w	$00D5,$00D8,$00DC,$00DF,$00E2,$00E5,$00E7,$00EA
	dc.w	$00EC,$00EF,$00F1,$00F3,$00F5,$00F7,$00F8,$00FA
	dc.w	$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF,$00FF
	dc.w	$00FF,$00FF,$00FF,$00FF,$00FE,$00FD,$00FC,$00FB
	dc.w	$00FA,$00F9,$00F7,$00F6,$00F4,$00F2,$00F0,$00EE
	dc.w	$00EB,$00E9,$00E6,$00E3,$00E0,$00DD,$00DA,$00D7
	dc.w	$00D3,$00D0,$00CC,$00C8,$00C4,$00C0,$00BC,$00B7
	dc.w	$00B3,$00AE,$00AA,$00A5,$00A0,$009B,$0096,$0091
	dc.w	$008C,$0086,$0081,$007B,$0076,$0070,$006A,$0065
	dc.w	$005F,$0059,$0053,$004D,$0047,$0041,$003B,$0035
	dc.w	$002F,$0028,$0022,$001C,$0016,$000F,$0009,$0003
	dc.w	$FFFD,$FFF7,$FFF1,$FFEA,$FFE4,$FFDE,$FFD8,$FFD1
	dc.w	$FFCB,$FFC5,$FFBF,$FFB9,$FFB3,$FFAD,$FFA7,$FFA1
	dc.w	$FF9B,$FF96,$FF90,$FF8A,$FF85,$FF7F,$FF7A,$FF74
	dc.w	$FF6F,$FF6A,$FF65,$FF60,$FF5B,$FF56,$FF52,$FF4D
	dc.w	$FF49,$FF44,$FF40,$FF3C,$FF38,$FF34,$FF30,$FF2D
	dc.w	$FF29,$FF26,$FF23,$FF20,$FF1D,$FF1A,$FF17,$FF15
	dc.w	$FF12,$FF10,$FF0E,$FF0C,$FF0A,$FF09,$FF07,$FF06
	dc.w	$FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF01,$FF01
	dc.w	$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04,$FF05
	dc.w	$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11,$FF14
	dc.w	$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28,$FF2B
	dc.w	$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF47,$FF4B
	dc.w	$FF4F,$FF54,$FF59,$FF5E,$FF62,$FF67,$FF6D,$FF72
	dc.w	$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF93,$FF98,$FF9E
	dc.w	$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCE
	dc.w	$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA,$0000
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0032,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0062,$0068,$006D,$0073,$0079,$007E,$0084,$0089
	dc.w	$008E,$0093,$0099,$009E,$00A2,$00A7,$00AC,$00B1
	dc.w	$00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D1
	dc.w	$00D5,$00D8,$00DC,$00DF,$00E2,$00E5,$00E7,$00EA
	dc.w	$00EC,$00EF,$00F1,$00F3,$00F5,$00F7,$00F8,$00FA
	dc.w	$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF,$00FF

