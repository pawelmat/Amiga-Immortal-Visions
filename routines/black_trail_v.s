
;		*****************************************	
;		*   'BLACK' TRAIL OVERSCREEN VECTORS	*
;		*    ------------------------------	*
;		*					*
;		*Coding on 09.05.1992, modif.on 19.05.92*
;		*	   by  KANE  of SUSPECT		*
;		*****************************************

org $30000
load $30000

s:	movem.l	a0-a6/d0-d7,-(sp)
	move.l	#ttcopper,$dff080
	move	$dff002,olddma
	ori	#$8000,olddma
	move	$dff01c,oldint
	ori	#$8000,oldint
	move	#$7fff,$dff09a
	move	#%1000001111110000,$dff096

	bsr	setup

	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	$32(a0),$dff080
	move	olddma,$dff096
	move.l	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	rts

oldint:		dc.w	0
olddma:		dc.w	0
gfxname:	dc.b	'graphics.library',0,0

ttcopper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
dc.l	$1800000,$1820f00,$1840c00,$1860f00,$1880900,$18a0f00,$18c0c00,$18e0f00
dc.l	$1900600,$1920f00,$1940c00,$1960f00,$1980900,$19a0f00,$19c0c00,$19e0f00
dc.l	$1a00300,$1a20f00,$1a40c00,$1a60f00,$1a80900,$1aa0f00,$1ac0c00,$1ae0f00
dc.l	$1b00600,$1b20f00,$1b40c00,$1b60f00,$1b80900,$1ba0f00,$1bc0c00,$1be0f00
ttscreen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$ec0007,$ee0000,$f00007,$f20000
dc.l	$1020000,$1080000,$10a0000
dc.l	$2001ff00,$01005300
dc.l	$ffdffffe
dc.l	$2001ff00,$01000300
dc.l	$fffffffe

;-------------------------------------------------------------------
scroff:		dc.l	0
scrpnt:		dc.w	0

ttheith=256
ttrow=40

ubor:	dc.w	10		;ramka,w ktorej ma byc zawarty obraz
dbor:	dc.w	250
lbor:	dc.w	10
rbor:	dc.w	310

ttzoomob=1500
ttzoom=1000

firstp:		dc.w	0
matrix:		blk.l	40,0
nierys:		dc.b	0
even
;-------------------------------------------------------------------

setup:
	lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
	lea	szescian,a6		;tu nazwe figury
ttcontrol:
	cmpi.b	#$ff,$dff006
	bne	ttcontrol
	bsr	ttchgscr
	bsr	ttvector

	btst.b	#6,$bfe001
	bne	ttcontrol
quit:	rts

ttchgscr:	move	scrpnt,d0
	bpl	ttchg2
	move	#5,scrpnt
	moveq	#5,d0
ttchg2:	move	#4,d1
	lea	ttscreen+2,a1
ttchg3:	move	d0,d2
	mulu	#[ttrow*ttheith],d2
	add.l	#$6a000,d2
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	addq	#8,a1
	addq	#1,d0
	cmpi	#6,d0
	bne	ttchg4
	clr	d0
ttchg4:	dbf	d1,ttchg3
	mulu	#[ttrow*ttheith],d0
	add.l	#$6a000,d0
	move.l	d0,scroff
	subi	#1,scrpnt

ttclear:	btst.b	#14,$2(a0)
	bne	ttclear
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[ttheith*64]+[ttrow/2],$58(a0)
	rts

ttvector:	move	6(a6),d0
	add	d0,12(a6)	
	move	8(a6),d0
	add	d0,14(a6)
	move	10(a6),d0
	add	d0,16(a6)

	lea	sinus,a1		;sinus
	lea	sinus+128,a4		;cosinus
	move.l	22(a6),a2		;tablica punktow
	lea	matrix,a3
	move	18(a6),d6		;ilosc punktow-1
tttwodim:	move	16(a6),d0
	move	4(a2),d1
	move	(a2),d2		;zxy
	neg d2
	bsr	rotate
	move	14(a6),d0
	move	d2,d3
	move	2(a2),d2	;zyx
	bsr	rotate
	move	12(a6),d0
	exg	d1,d3		;xyz
	bsr	rotate

	move	#ttzoomob,d4	;zooming wstepny
	sub	d3,d4
	muls	d4,d1
	divs	#ttzoomob,d1
	muls	d4,d2
	divs	#ttzoomob,d2

	move	4(a6),d3
	move	#ttzoom,d4	;zooming calosciowy
	sub	d3,d4
	muls	d4,d1
	divs	#ttzoom,d1
	muls	d4,d2
	divs	#ttzoom,d2

	addi	(a6),d1		;dodaj srodek x i y
	addi	2(a6),d2
	move	d1,(a3)+	;zapisz x,y w matrycy
	move	d2,(a3)+
	adda.l	#6,a2
	dbf	d6,tttwodim

ttobrysuj:move	20(a6),d7		;ilosc plaszczyzn
	lea	matrix,a4		;matr. x,y
	move.l	26(a6),a3
ttobr1:	move	(a3)+,d6		;ilosc rogow pla
	subi	#2,d6
	sf	nierys
	movem	(a3),d3-d5
	lsl	#2,d3
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d3.w),d0/d1
	movem	(a4,d4.w),d2/d3
	subi	d0,d2
	subi	d1,d3			;d2,d3-wsp.wek.1
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d4/d5
	subi	d0,d4
	subi	d1,d5			;d4,d5-wsp.wek.2
	exg	d2,d3
	neg	d3			;w=[y,-x]
	muls	d2,d4
	muls	d3,d5
	add.l	d4,d5			;d5-iloczyn wektorowy
	bpl	ttobr2
	st	nierys
ttobr2:	move	(a3),firstp
ttobr3:	move	(a3)+,d4
	tst.b	nierys
	bne	ttobr5
	move	(a3),d5
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	ttldraws
ttobr5:	dbf	d6,ttobr3
	move	(a3)+,d4
	tst.b	nierys
	bne	ttobr6
	move	firstp,d5
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	ttldraws
ttobr6:	cmpi	#2,(a3)			;czy linie na plaszczyznie?
	bne	ttobr4
	move	(a3)+,d4
	move	(a3)+,d4
	move	(a3)+,d5
	tst.b	nierys
	bne	ttobr6
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	ttldraws
ttobr7:	bra	ttobr6
ttobr4:	dbf	d7,ttobr1
	rts

ttldraws:cmpi	rbor,d0		;obetnij do ramki
	bmi	ttprawo2
	cmpi	rbor,d2
	bpl	ttnoline
	move	d3,d4
	subi	d1,d4
	move	rbor,d5
	subi	d2,d5
	muls	d5,d4
	move	d0,d5
	subi	d2,d5
	divs	d5,d4
	move	rbor,d0
	move	d3,d1
	subi	d4,d1
	move	d1,d4
	bra	ttlewo
ttprawo2:	cmpi	rbor,d2
	bmi	ttlewo
	move	d1,d4
	subi	d3,d4
	move	rbor,d5
	subi	d0,d5
	muls	d5,d4
	move	d2,d5
	subi	d0,d5
	divs	d5,d4
	move	rbor,d2
	move	d1,d3
	subi	d4,d3
ttlewo:	cmpi	lbor,d0
	bpl	ttlewo2
	cmpi	lbor,d2
	bmi	ttnoline
	move	d3,d4
	subi	d1,d4
	move	d2,d5
	subi	lbor,d5
	muls	d5,d4
	move	d2,d5
	subi	d0,d5
	divs	d5,d4
	move	lbor,d0
	move	d3,d1
	subi	d4,d1
	move	d1,d4
	bra	ttgora
ttlewo2:	cmpi	lbor,d2
	bpl	ttgora
	move	d1,d4
	subi	d3,d4
	move	d0,d5
	subi	lbor,d5
	muls	d5,d4
	move	d0,d5
	subi	d2,d5
	divs	d5,d4
	move	lbor,d2
	move	d1,d3
	subi	d4,d3
ttgora:	cmpi	ubor,d1
	bpl	ttgora2
	cmpi	ubor,d3
	bmi	ttnoline
	move	d2,d4
	subi	d0,d4
	move	d3,d5
	subi	ubor,d5
	muls	d5,d4
	move	d3,d5
	subi	d1,d5
	divs	d5,d4
	move	ubor,d1
	move	d2,d0
	subi	d4,d0
	bra	ttdol
ttgora2:	cmpi	ubor,d3
	bpl	ttdol
	move	d0,d4
	subi	d2,d4
	move	d1,d5
	subi	ubor,d5
	muls	d5,d4
	move	d1,d5
	subi	d3,d5
	divs	d5,d4
	move	ubor,d3
	move	d0,d2
	subi	d4,d2
ttdol:	cmpi	dbor,d1
	bmi	ttdol2
	cmpi	dbor,d3
	bpl	ttnoline
	move	d2,d4
	subi	d0,d4
	move	dbor,d5
	subi	d3,d5
	muls	d5,d4
	move	d1,d5
	subi	d3,d5
	divs	d5,d4
	move	dbor,d1
	move	d2,d0
	subi	d4,d0
	bra	ttlindraw
ttdol2:	cmpi	dbor,d3
	bmi	ttlindraw
	move	d0,d4
	subi	d2,d4
	move	dbor,d5
	subi	d1,d5
	muls	d5,d4
	move	d3,d5
	subi	d1,d5
	divs	d5,d4
	move	dbor,d3
	move	d0,d2
	subi	d4,d2
ttlindraw:movem.l	d0-d7,-(sp)	;rys.linie
ttwait2:	btst	#14,2(a0)
	bne	ttwait2	
	cmp	d1,d3
	bge	ttp1
	exg	d2,d0
	exg	d1,d3
ttp1:	addq	#1,d1
	moveq	#$f,d4	
	and	d2,d4
	sub	d3,d1
	neg	d1
	mulu	#ttrow,d3
	sub	d2,d0
	blt	ttp5
	cmp	d0,d1
	bge	ttp4
	moveq	#$19,d7
	bra	ttp9
ttp4:	moveq	#$5,d7 
	exg	d0,d1
	bra	ttp9
ttp5:	neg	d0
	cmp	d0,d1
	bge	ttp8
	moveq	#$1d,d7
	bra	ttp9
ttp8:	moveq	#$d,d7
	exg	d0,d1
ttp9:	asl	#1,d1
	asr	#$3,d2
	ext.l	d2
	add.l	d2,d3
	move	d1,d2
 	sub	d0,d2 
	bge	ttp10
	ori	#$40,d7
ttp10:	move	d2,d6
	move	d1,$62(a0)
	move	d2,d1	
	sub	d0,d1
	move	d1,$64(a0)
	move	#ttrow,$60(a0)
	addq	#1,d0
	asl	#6,d0
	addq	#2,d0
	ror.l	#4,d4
	or.l	d4,d7
	move	#$8000,$74(a0)
	ori.l	#$bca0000,d7		;LF itp
	add.l	scroff,d3		;rastport
	move.l	d7,$40(a0)
	move	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move	#$ffff,$72(a0)
	move	d0,$58(a0)
	movem.l	(a7)+,d0-d7
ttnoline:	rts

rotate:	andi.l	#$1fe,d0	;obroc punkty
	move	d1,d4
	move	d2,d5
	muls	(a4,d0.w),d4	; x*cos
	muls	(a1,d0.w),d5	; y*sin
	sub.l	d4,d5		;y'=y*sin-x*cos
	move.l	d5,d7
	andi.l	#$80000000,d7
	lsr.l	#8,d7
	or.l	d7,d5
	lsr.l	#8,d5
	muls	(a1,d0.w),d1
	muls	(a4,d0.w),d2
	add.l	d2,d1		;x'=x*sin+y*cos
	move.l	d1,d7
	andi.l	#$80000000,d7
	lsr.l	#8,d7
	or.l	d7,d1
	lsr.l	#8,d1
	move	d5,d2		;y' do d2
	rts	

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
	dc.w	$FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF01,$FF01,$ff01
	dc.w	$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04,$FF05
	dc.w	$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11,$FF14
	dc.w	$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28,$FF2B
	dc.w	$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF47,$FF4B
	dc.w	$FF4F,$FF54,$FF59,$FF5E,$FF62,$FF67,$FF6D,$FF72
	dc.w	$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF93,$FF98,$FF9E
	dc.w	$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCE
	dc.w	$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0032,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0062,$0068,$006D,$0073,$0079,$007E,$0084,$0089
	dc.w	$008E,$0093,$0099,$009E,$00A2,$00A7,$00AC,$00B1
	dc.w	$00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D1
	dc.w	$00D5,$00D8,$00DC,$00DF,$00E2,$00E5,$00E7,$00EA
	dc.w	$00EC,$00EF,$00F1,$00F3,$00F5,$00F7,$00F8,$00FA
	dc.w	$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF,$00FF

szescian:
dc.w	160,130,300	;xmid,ymid,zmid
dc.w	2,-2,-4		;szybkosci
dc.w	64,-64,64	;katy
dc.w	28,5		;il. punktow i plaszczyzn -1
dc.l	szdots,szline
szdots:
dc.w	-90,-90,-90	;wspolrzedne x,y,z
dc.w	90,-90,-90
dc.w	90,90,-90
dc.w	-90,90,-90
dc.w	-90,-90,90
dc.w	90,-90,90
dc.w	90,90,90
dc.w	-90,90,90

dc.w	-60,60,-90
dc.w	-60,-60,-90
dc.w	-60,0,-90
dc.w	60,60,-90
dc.w	60,-60,-90
dc.w	90,60,-60
dc.w	90,-60,-60
dc.w	90,60,60
dc.w	90,-60,60
dc.w	90,0,-60
dc.w	90,0,60
dc.w	60,-60,90
dc.w	60,60,90
dc.w	-60,-60,90
dc.w	-60,60,90
dc.w	-90,60,60
dc.w	-90,0,60
dc.w	-90,-60,60
dc.w	-90,60,-60
dc.w	-90,0,-40
dc.w	-90,-60,-60
szline:
dc.w	4,0,1,2,3,  2,8,9,2,10,11,2,10,12		;K
dc.w	4,5,6,2,1,  2,13,14,2,15,16,2,13,15,2,17,18	;A
dc.w	4,4,7,6,5,  2,19,20,2,20,21,2,21,22		;N
dc.w	4,0,3,7,4,  2,23,25,2,23,26,2,24,27,2,25,28	;E
dc.w	4,2,6,7,3
dc.w	4,5,1,0,4,0	;plaszczyzna i wtedy linie na niej (jako 2)
