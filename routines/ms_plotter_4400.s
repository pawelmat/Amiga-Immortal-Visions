
;		*****************************************	
;		*	 SINEPLOTTER HI-RES 4400	*
;		*	 -----------------------	*
;		*					*
;		*Coding on 06.04.1992, inpr.on 19.05.92	*
;		*	  by  KANE  of SUSPECT		*
;		*****************************************

org	$30000
load	$30000

raster: macro
wait?0: cmp.b	#$fe,$dff006
	bne	wait?0
	cmp.b	#$ff,$dff006
	bne	wait?0+12
	endm

s:	movem.l	a0-a6/d0-d7,-(sp)
	move	$dff002,olddma
	ori	#$8000,olddma
	move	#%1000001111100000,$dff096
	move	$dff01c,oldint
	move	#$7fff,$dff09a

	bsr	ms_megaplot

	move	olddma,$dff096
	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	$32(a0),$dff080
	ori	#$8000,oldint
	move	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	rts

oldint:		dc.w	0
olddma:		dc.l	0
gfxname:	dc.b	'graphics.library',0,0

ms_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920048,$9400c0,$8e0171,$9037d1
dc.l	$1800000,$18200f0,$18400d0,$18600f0,$18800b0,$18a00f0,$18c00d0,$18e00f0
dc.l	$1900090,$19200f0,$19400d0,$19600f0,$19800b0,$19a00f0,$19c00d0,$19e00f0
ms_screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$ec0007,$ee0000
dc.l	$102000f,$1080000,$10a0000
ms_up:
dc.l	$6a01ff00,$1800000
dc.l	$6b01ff00,$1800000
ms_start:
dc.l	$ef01ff00,$01000300
dc.l	$f001ff00,$01000300
ms_dn:
dc.l	$f501ff00,$1800000
dc.l	$f601ff00,$1800000
dc.l	$ffdffffe
ms_scr:
dc.l	$e00007,$e20000
dc.l	$1820000
dc.l	$0501ff00,$1001300
dc.l	$1501ff00,$1000300
dc.l	$fffffffe

;-------------------------------------------------------------------
ms_scrpnt:		dc.w	0

ms_heith=128
ms_row=64
ms_sine=$60000

ms_anglex:	dc.w	100
ms_angley:	dc.w	1700
ms_andval=$ffe
ms_licz:	dc.w	400
even
;-------------------------------------------------------------------

ms_megaplot:
	bsr	ms_makesine
	move.l	#$dff000,a0
	move.l	#$ffffffff,$44(a0)
	move.l	#ms_copper,$dff080
	clr	$dff088
	bsr	ms_plotter
	bsr	ms_plotter
	bsr	ms_plotter
	bsr	ms_plotter
	bsr	ms_plotter
	bsr	ms_plotter
	move	#14,d0
ms_bar1:raster
	raster
	addi	#$100,ms_up+6
	addi	#$100,ms_dn+6
	dbf	d0,ms_bar1
	move.b	#$c3,ms_start+6

ms_control:
	cmpi.b	#$ff,6(a0)
	bne	ms_control
	bsr	ms_plotter
	cmp.b	#$70,ms_start
	beq	ms_con1
	sub.b	#1,ms_start
ms_con1:subi	#1,ms_licz
	bne	ms_control
ms_cont2:cmpi.b	#$ff,6(a0)
	bne	ms_cont2
	bsr	ms_plotter
	add.b	#1,ms_start
	cmp.b	#$ef,ms_start
	bne	ms_cont2
	move.b	#3,ms_start+6

	move	#14,d0
ms_bar2:raster
	raster
	subi	#$100,ms_up+6
	subi	#$100,ms_dn+6
	dbf	d0,ms_bar2

ms_quit:rts

ms_plotter:move	ms_scrpnt,d0
	bpl	ms_chg2
	move	#5,ms_scrpnt
	moveq	#5,d0
ms_chg2:move	#3,d1
	lea	ms_screen+2,a1
ms_chg3:move	d0,d2
	mulu	#[ms_row*ms_heith],d2
	add.l	#$6a000,d2
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	addq	#8,a1
	addq	#1,d0
	cmpi	#6,d0
	bne	ms_chg4
	clr	d0
ms_chg4:dbf	d1,ms_chg3
	move	d0,d2
	mulu	#[ms_row*ms_heith],d2
	add.l	#$6a000,d2
	addq	#1,d0
	cmpi	#6,d0
	bne	ms_chg5
	clr	d0
ms_chg5:mulu	#[ms_row*ms_heith],d0
	add.l	#$6a000,d0
	move.l	d0,a2
	subi	#1,ms_scrpnt

ms_clear:btst.b	#14,$2(a0)
	bne	ms_clear
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d2,$54(a0)
	move	#[ms_heith*64]+[ms_row/2],$58(a0)

ms_wait1:lea	ms_sine,a1
	move	#64,d2
	mulu	#ms_row,d2
	adda.l	d2,a2
	addi	#8,ms_anglex		;szybkosc calosci
	addi	#6,ms_angley
	andi	#ms_andval,ms_anglex
	andi	#ms_andval,ms_angley
	move	ms_anglex,d0
	move	ms_angley,d1
	move	#1100,d7
ms_plloop:
	addi	#6,d0			;szybkosc jednostkowa
	addi	#10,d1			;tu wstaw '4'!!!
	andi	#ms_andval,d0
	andi	#ms_andval,d1
	move	(a1,d0.w),d2
	move	(a1,d1.w),d3
	lsr	#2,d3

	addi	#256,d2
	mulu	#ms_row,d3
	move	d2,d4
	lsr	#3,d2
	andi	#7,d4
	eori	#7,d4
	addi	d3,d2
	bset	d4,(a2,d2.w)
	dbf	d7,ms_plloop
	rts

ms_makesine:			;tworzenie tablicy sinusa
	lea	ms_datatab-2,a2
	lea	ms_sine,a3
ms_mloop:addq	#2,a2
	move	(a2)+,d0	;czy koniec?
	beq	ms_quit
	move	(a2)+,d1
	lea	ms_sinus,a1
ms_mloop2:move	(a1),d2
	cmpi	#$aaaa,d2	;koniec wzoru sinusa?
	beq	ms_mloop
	muls	d0,d2
	divs	d1,d2
	move	d2,(a3)+
	clr.l	d2
	move	(a2),d2
	lsl	#1,d2
	add.l	d2,a1
	bra	ms_mloop2

ms_datatab:
dc.w	11,11,1,10,11,1,9,11,1,8,11,1,7,11,1,6,11,1,5,11,1,4,11,1
dc.w	3,11,1,4,11,1,5,11,1,6,11,1,7,11,1,8,11,1,9,11,1,10,11,1,0

ms_sinus:
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
	dc.w	$FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF01,$FF01,$ff01
	dc.w	$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04,$FF05
	dc.w	$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11,$FF14
	dc.w	$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28,$FF2B
	dc.w	$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF47,$FF4B
	dc.w	$FF4F,$FF54,$FF59,$FF5E,$FF62,$FF67,$FF6D,$FF72
	dc.w	$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF93,$FF98,$FF9E
	dc.w	$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCE
	dc.w	$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA,$aaaa

