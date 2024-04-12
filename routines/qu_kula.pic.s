
;		*****************************************	
;		*        PLOTTER VECTORPICTURE		*
;		*	 ----------------------		*
;		*					*
;		*      Coding on Prima Aprilis '92	*
;		*	  by  KANE  of SUSPECT		*
;		*****************************************

org	$30000
load	$30000

s:
	movem.l	a0-a6/d0-d7,-(sp)
	move	$dff002,olddma
	move	#$100,$dff096
	move	$dff01c,oldint
	ori	#$8000,oldint
	ori	#$8000,olddma
	move	#$7fff,$dff09a
	move	#%1000001111100000,$dff096

	bsr	qu_setup

	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	$32(a0),$dff080
	move	olddma,$dff096
	move	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	rts

olddma:		dc.w	0
oldint:		dc.w	0
gfxname:	dc.b	'graphics.library',0,0

qu_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$1800000,$18205f0,$1840a0f,$18605f0
dc.l	$920038,$9400d0,$8e0171,$9037d1
qu_screen:
dc.l	$e00007,$e25000,$e40007,$e65000
dc.l	$1020030,$1080000,$10a0000	;bplcon1,modulo1
dc.l	$4001ff00,$01001300
dc.l	$4101ff00,$01002300
qu_mir1:
dc.l	$f801ff00,$1800000,$1820280,$1840508,$1860280
dc.w	$108,-80,$10a,-80
dc.l	$ffdffffe
qu_mir2:
dc.l	$0801ff00,$1800000,$1820260,$1840506,$1860260
qu_mir3:
dc.l	$1801ff00,$1800000,$1820240,$1840504,$1860240
dc.l	$2801ff00,$1800000
dc.l	$2a01ff00,$1000300
dc.l	$fffffffe

;-------------------------------------------------------------------
scron:		dc.l	$75000
scroff:		dc.l	$75000+[qu_heith*qu_row]

qu_heith=185
qu_row=40
qu_hmid:	dc.w	-400
qu_vmid:	dc.w	138
qu_vmidd:	dc.w	138
qu_jaxid:	dc.w	0
;-------------------------------------------------------------------

qu_setup:lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
	move.l	#$75000,scron
	move.l	#$75000+[qu_heith*qu_row],scroff
qu_set2:btst.b	#14,$2(a0)
	bne	qu_set2
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$75000,$54(a0)
	move	#[qu_heith*64]+[qu_row],$58(a0)
qu_set3:btst.b	#14,$2(a0)
	bne	qu_set3
	move.l	#qu_copper,$dff080
	clr	$dff088

	bsr	qu_watt
	add.b	#1,qu_mir1+7
	add.b	#1,qu_mir2+7
	add.b	#1,qu_mir3+7
	bsr	qu_watt
	add.b	#1,qu_mir1+7
	add.b	#1,qu_mir2+7
	bsr	qu_watt
	add.b	#1,qu_mir1+7

	lea	qu_kane,a6
	bsr	qu_create
qu_control:
	bsr	qu_pass			;kane
	add.l	#[16*32],4(a6)
	bsr	qu_create
	move	#-110,qu_hmid
	bsr	qu_pass			;pillar
	add.l	#[16*32],4(a6)
	move	#120,8(a6)
	bsr	qu_create
	move	#-130,qu_hmid
	bsr	qu_pass			;artB
	add.l	#[16*32],4(a6)
	bsr	qu_create
	move	#-130,qu_hmid
	bsr	qu_pass			;crypton
	add.l	#[16*32],4(a6)
	move	#100,8(a6)
	move	#60,10(a6)
	move	#128,qu_vmidd
	bsr	qu_create
	move	#-110,qu_hmid
	move	#-6,18(a6)
	bsr	qu_pass			;xtd
	add.l	#[16*32],4(a6)
	bsr	qu_create
	move	#-110,qu_hmid
	move	#-10,18(a6)
	bsr	qu_pass			;kalosz
	rts

qu_watt:move	#6,d1
qu_mirin:cmp.b	#$fe,$dff006
	bne	qu_mirin
qu_mi1:	cmp.b	#$ff,$dfe006
	bne	qu_mi1
	dbf	d1,qu_mirin
	rts

qu_pass:
	cmpi.b	#$ff,6(a0)
	bne	qu_pass
	lea	sinus,a1
	addi	#12,qu_jaxid
	move	qu_jaxid,d0
	andi	#$fe,d0
	move	(a1,d0.w),d0
	lsr	#2,d0
	move	qu_vmidd,d1
	subi	d0,d1
	move	d1,qu_vmid
	addi	#4,qu_hmid
	bsr	qu_ball
	cmpi	#520,qu_hmid
	bgt	qu_quit
	btst.b	#6,$bfe001
	bne	qu_pass
qu_quit:rts


qu_ball:move.l	scron,d0		;zmien ekrany
	move.l	scroff,d1
	move.l	d0,scroff
	move.l	d1,scron
	move	d1,qu_screen+6
	move	d1,qu_screen+14
	swap	d1
	move	d1,qu_screen+2
	move	d1,qu_screen+10
qu_wait1:btst.b	#14,$2(a0)
	bne	qu_wait1
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	scroff,$54(a0)
	move	#[qu_heith*64]+[qu_row/2],$58(a0)

qu_rysuj:btst.b	#14,$2(a0)
	bne	qu_rysuj
	move.l	(a6),a1
	move.l	scroff,a2
	lea	sinus,a3
	lea	sinus+$80,a4
	move	(a1)+,d7

	move	18(a6),d4
	addi	d4,16(a6)
	move	16(a6),d4
	andi	#$1fe,d4
qu_narys2:	movem	(a1)+,d0-d2
	move	d1,d3
	addi	d4,d0
	andi	#$1fe,d0
	mulu	(a3,d0.w),d1
	mulu	(a4,d0.w),d3
	asr	#8,d1
	asr	#8,d3

	bmi	qu_tejnie

	addi	qu_hmid,d1
	bmi	qu_tejnie
	cmpi	#319,d1
	bgt	qu_tejnie
	addi	qu_vmid,d2
	mulu	#qu_row,d2
	move	d1,d3
	lsr	#3,d1
	andi	#7,d3
	eori	#7,d3
	addi	d1,d2
	bset.b	d3,(a2,d2.w)
	addi	#40,d2
	bset.b	d3,(a2,d2.w)
qu_tejnie:	dbf	d7,qu_narys2
	rts

qu_create:	movem.l	a1-a6/d0-d7,-(a7)
	movem.l	(a6)+,a1/a5
	movem	(a6)+,d0-d3
	move.l	a1,a2
	move	#-1,(a1)+
	lea	sinus,a3
	lea	sinus+$80,a4
	clr	qu_anglex
	move	#128,qu_anglez
	clr.l	d6
	moveq	#7,d7
qu_oblicz:	subi	d3,qu_anglez
	move	qu_anglez,d5
	tst	d5
	beq	qu_crend
	lsl	#1,d5
	movem.l	d0/d1,-(a7)
	mulu	(a3,d5.w),d0	;x
	mulu	(a4,d5.w),d1	;z
	asr	#8,d0
	asr	#8,d1
qu_obroc:
	btst	d7,(a5,d6.w)
	beq	qu_nietu	
	move	qu_anglex,d5
	lsl	#1,d5
	move	d5,(a1)+
	move	d0,(a1)+
	move	d1,(a1)+
	addi	#1,(a2)
qu_nietu:	subi	#1,d7
	bpl	qu_dalej
	moveq	#7,d7
	addq	#1,d6
qu_dalej:	addi	d2,qu_anglex
	andi	#$ff,qu_anglex
	bne	qu_obroc
	movem.l	(a7)+,d0/d1
	bra	qu_oblicz
qu_crend:	movem.l	(a7)+,a1-a6/d0-d7
	rts

qu_anglex:	dc.w	0
qu_anglez:	dc.w	0

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

qu_rysunek=$70000
;>extern	"df0:.store/plotball.pic",qu_rysunek,-1
>extern	"df0:kula_pic.raw",qu_rysunek,-1

qu_kane:
dc.l	qu_kanedata,qu_rysunek		;adres obrazka (tu 64*32)
dc.w	80,50,2,4	;promienie krzywizn i gestosc punktow
dc.w	128
dc.w	-10
qu_kanedata:
ds.w	3*1000,0		;obszar na wspolrzedne

end:
