;		*****************************************	
;		*	  Immortal Visions code		*
;		*    ------------------------------	*
;		*					*
;		*  Coding on 22.05.1992 to .....1992	*
;		*	  by  KANE  of SUSPECT		*
;		*****************************************

org $20000
load $20000
nolist
raster: macro
wait?0:	cmpi.b	#$fe,$dff006
	bne	wait?0
	cmpi.b	#$ff,$dff006
	bne	wait?0+12
	endm

s:	move.l	(sp)+,return	;aby umozliwic wyjscie z przerwania
	movem.l	a0-a6/d0-d7,-(sp)
	move	$dff002,olddma
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
	move.l	$6c,oldlev3
	move.l	#newlev3,$6c
	move.b	#$11,$bfde00	;start timer at line $d0
	move	#$e020,$dff09a
	move	#%1000011111110000,$dff096
	move.l	#copper,$dff080
	clr	$dff088

	bsr	setup

quitt:	move.l	4,a6
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
	move.l	oldlev3,$6c
	move	#$c000,$dff09a
	bsr	mt_end
	move	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	move.l	return,a0
	jmp	(a0)		;jak mowi Pillar 'fajrant'

newlev3:move	#$20,$dff09c
	rte

newlev:	movem.l	d0-d7/a0-a6,-(sp)
	move.b	$bfdd00,d0
	subi	#1,counter
	bsr	mt_music
	movem.l	(sp)+,d0-d7/a0-a6
	tst	pl_nomouse
	bne	nopress
	btst	#6,$bfe001
	bne	nopress
	move	(sp)+,storee
	move.l	(sp)+,adress
	move.l	#quitt,-(sp)
	move	storee,-(sp)
nopress:move	#$2000,$dff09c
	rte

storee:		dc.w	0
adress:		dc.l	0
counter:	dc.w	3

return:		dc.l	0
oldint:		dc.w	0
olddma:		dc.w	0
oldlev:		dc.l	0
oldlev3:	dc.l	0
gfxname:	dc.b	'graphics.library',0,0

copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
colors:
dc.l	$1800000,$1820000,$1840000,$1860000,$1880000,$18a0000,$18c0000,$18e0000
dc.l	$1900000,$1920000,$1940000,$1960000,$1980000,$19a0000,$19c0000,$19e0000
dc.l	$1a00000,$1a20000,$1a40000,$1a60000,$1a80000,$1aa0000,$1ac0000,$1ae0000
dc.l	$1b00000,$1b20000,$1b40000,$1b60000,$1b80000,$1ba0000,$1bc0000,$1be0000
screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$ec0007,$ee0000,$f00007,$f20000
dc.l	$1020000,$1080000,$10a0000
scrcol:
dc.l	$2c01ff00,$01000300
ttkreg:
dc.l	$3901ff00,$1800000
dc.l	$3a01ff00,$1800000
ttcol:
dc.l	$3b01ff00,$1800000
lo_tutaj
dc.l	$7801ff00,$01005300
dc.l	$ce01ff00,$01002300

dc.l	$e801ff00,$9aa000
dc.l	$ef01ff00,$9a2000
dc.l	$fb01ff00,$1800000
ttkred:
dc.l	$fc01ff00,$1800000
dc.l	$fd01ff00,$1800000
dc.l	$ffdffffe
dc.l	$0c01ff00,$01003300
tp_scr:
dc.l	$e80007,$ea0000
dc.l	$1880000
dc.l	$1c01ff00,$01002300
dc.l	$1880000
dc.l	$2c01ff00,$01000300
dc.l	$fffffffe

;-------------------------------------------------------------------
scron:		dc.l	$70000
scroff:		dc.l	$70000+[2*heith*row]
heith=256
row=40

ubor:	dc.w	0		;ramka,w ktorej ma byc zawarty obraz
dbor:	dc.w	255
lbor:	dc.w	1
rbor:	dc.w	319

zoomob=3000			;zooming wstepny obiektow
zoom=1000			;zooming perspektywiczny calosci

pkol:	dc.w	0
firstp:	dc.w	0
prpnt:	dc.w	0
lepnt:	dc.w	0
prtab:	blk.l	20,0
letab:	blk.l	20,0
even
matrix:	blk.l	50,0
;-------------------------------------------------------------------

setup:
	lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
	bsr	tp_initfnt
	lea	tp_scr,a1
	bsr	tp_init
clear:	btst.b	#14,$2(a0)
	bne	clear
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$70000,$54(a0)
	move	#[4*heith*64]+[row/2],$58(a0)
clear2:	btst.b	#14,$2(a0)
	bne	clear2
;bra	qu_credits
;bra	ve_odlot
jmp	pl_plasm
;bra	an_animation
	bsr	init_logos
	move.b	#$23,scrcol+6		;wlacz obraz
	lea	osmioscian,a6		;tu nazwe figury
	bsr	speed

control:bsr	waitvbl
	cmpi	#160,(a6)
	beq	contr3
	addi	#2,(a6)
	addi	#1,2(a6)
contr3:	subi	#2,4(a6)
	bsr	chgscr
	bsr	vector
	cmpi	#835,4(a6)
	beq	contr4
	bra	control

contr4:	move	#48,d0
contr5:	move	d0,-(sp)
	bsr	waitvbl
	bsr	chgscr
	bsr	vector
	move	(sp)+,d0
	dbf	d0,contr5

contr2:	move.l	#$1200000,lo_tutaj
	move.l	#$1200000,lo_tutaj+4
	move.l	#$1200000,lo_tutaj+8
	move.l	#$1200000,lo_tutaj+12
	bra	ttwire

waitvbl:cmpi.b	#$ff,$dff006
	bne	waitvbl
	move	counter,d0
	bpl	waitvbl
	move	#1,counter
	rts

chgscr:	btst.b	#14,$2(a0)
	bne	chgscr
	move.l	scron,d0		;zmien ekrany
	move.l	scroff,d1
	move.l	d0,scroff
	move.l	d1,scron
	move	d1,screen+6
	swap	d1
	move	d1,screen+2
	swap	d1
	add.l	#[heith*row],d1
	move	d1,screen+14
	swap	d1
	move	d1,screen+10
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[2*heith*64]+[row/2],$58(a0)
	rts

vector:	move	20(a6),d7		;ilosc plaszczyzn
	lea	matrix,a4
	move.l	26(a6),a3
obr1:	move	(a3)+,pkol
	move	(a3)+,d6
	movem	(a3),d3-d5
	lsl	#2,d3
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d3.w),d0/d1
	movem	(a4,d4.w),d2/d3
	subi	d0,d2
	subi	d1,d3			;d2,d3-wsp.wek.B
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d4/d5
	subi	d0,d4
	subi	d1,d5			;d4,d5-wsp.wek.A
	muls	d4,d3
	muls	d5,d2
	sub.l	d2,d3
	bmi	obr2
	lsl	#1,d6
	addi	d6,a3
	bra	pomin
obr2:	subi	#2,d6
	move	(a3),firstp
	clr.l	prpnt
obr3:	move	(a3)+,d4
	move	(a3),d5
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	ldraws
	dbf	d6,obr3
	move	(a3)+,d4
	move	firstp,d5
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	ldraws
koryg:	lea	prtab,a2	;wykresl dod.linie z lewej i prawej
	move	prpnt,d4
	bsr	korygm
	lea	letab,a2
	move	lepnt,d4
	bsr	korygm
pomin:	dbf	d7,obr1

fill:	btst.b	#14,$2(a0)
	bne	fill
	clr.l	$64(a0)
	move.l	#$09f00012,$40(a0)
	move.l	scroff,d4
	add.l	#[2*heith*row]-2,d4
	move.l	d4,$54(a0)
	move.l	d4,$50(a0)
	move	#[2*heith*64]+[row/2],$58(a0)

speed:	move	6(a6),d0
	add	d0,12(a6)	
	move	8(a6),d0
	add	d0,14(a6)
	move	10(a6),d0
	add	d0,16(a6)
	lea	sinus,a1
	lea	sinus+128,a4		;cosinus
	move.l	22(a6),a2		;tablica punktow
	lea	matrix,a3
	move	18(a6),d6		;ilosc punktow-1
twodim:	move	16(a6),d0
	move	4(a2),d1
	move	(a2),d2		;zxy
	bsr	rotate
	move	14(a6),d0
	move	d2,d3
	move	2(a2),d2	;zyx
	bsr	rotate
	move	12(a6),d0
	exg	d1,d3		;xyz
	bsr	rotate

	move	#zoomob,d4	;zooming wstepny
	sub	d3,d4
	muls	d4,d1
	divs	#zoomob,d1
	muls	d4,d2
	divs	#zoomob,d2
	move	4(a6),d3	;dod.srodek z
	move	#zoom,d4	;zooming calosciowy
	sub	d3,d4
	muls	d4,d1
	divs	#zoom,d1
	muls	d4,d2
	divs	#zoom,d2
	addi	(a6),d1		;dodaj srodek
	addi	2(a6),d2
	move	d1,(a3)+
	move	d2,(a3)+
	adda.l	#6,a2
	dbf	d6,twodim
wait2:	btst.b	#14,$2(a0)
	bne	wait2
	rts

korygm:	beq	korend			;koryguj linie z lew. i pra.
	movem	(a2)+,d0-d3
	cmpi	ubor,d1
	bpl	kor1
	cmpi	ubor,d3
	bmi	nokor
	move	ubor,d1
	bra	kord
kor1:	cmpi	ubor,d3
	bpl	kord
	move	ubor,d3
kord:	cmpi	dbor,d1
	bmi	kor2
	cmpi	dbor,d3
	bpl	nokor
	move	dbor,d1
	bra	kor3
kor2:	cmpi	dbor,d3
	bmi	kor3
	move	dbor,d3
kor3:	bsr	lindraw
nokor:	subi	#8,d4
	bra	korygm
korend:	rts

ldraws:	cmpi	rbor,d0		;obetnij do ramki
	bmi	prawo2
	cmpi	rbor,d2
	bpl	noline
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
prdory:	move.l	a1,-(sp)
	lea	prtab,a1
	move	prpnt,d5
	move	rbor,(a1,d5.w)
	move	d4,2(a1,d5.w)
	addi	#4,d5
	move	d5,prpnt
	move.l	(sp)+,a1
	bra	lewo
prawo2:	cmpi	rbor,d2
	bmi	lewo
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
	move	d3,d4
	bra	prdory
lewo:	cmpi	lbor,d0
	bpl	lewo2
	cmpi	lbor,d2
	bmi	noline
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
ldorys:	move.l	a1,-(sp)
	lea	letab,a1
	move	lepnt,d5
	move	lbor,(a1,d5.w)
	move	d4,2(a1,d5.w)
	addi	#4,d5
	move	d5,lepnt
	move.l	(sp)+,a1
	bra	gora
lewo2:	cmpi	lbor,d2
	bpl	gora
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
	move	d3,d4
	bra	ldorys
gora:	cmpi	ubor,d1
	bpl	gora2
	cmpi	ubor,d3
	bmi	noline
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
	bra	dol
gora2:	cmpi	ubor,d3
	bpl	dol
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
dol:	cmpi	dbor,d1
	bmi	dol2
	cmpi	dbor,d3
	bpl	noline
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
	bra	lindraw
dol2:	cmpi	dbor,d3
	bmi	lindraw
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
lindraw:cmpi	d1,d3
	beq	noline
	move.l	scroff,a5
	move	pkol,d5
	btst	#0,d5
	beq	lin1
	bsr	line
lin1:	adda.l	#[heith*row],a5
	btst	#1,d5
	beq	noline
	bsr	line
noline:	rts

ld_row:	dc.w	0
ld_addr:dc.l	0
ld_texture:dc.w	0

line:	movem.l	d0-d7,-(sp)	;rys.linie
wait3:	btst	#14,2(a0)
	bne	wait3	
	cmp	d1,d3
	bge	p1
	exg	d2,d0
	exg	d1,d3
p1:	addq	#1,d1
	moveq	#$f,d4	
	and	d2,d4
	sub	d3,d1
	neg	d1
	mulu	#row,d3		;wys. linii * szer. ekranu
	sub	d2,d0
	blt	p5
	cmp	d0,d1
	bge	p4
	moveq	#$19,d7
	bra	p9
p4:	moveq	#$5,d7 
	exg	d0,d1
	bra	p9
p5:	neg	d0
	cmp	d0,d1
	bge	p8
	moveq	#$1d,d7
	bra	p9
p8:	moveq	#$d,d7
	exg	d0,d1
p9:	asl	#1,d1
	asr	#$3,d2
	ext.l	d2
	add.l	d2,d3
	move	d1,d2
 	sub	d0,d2 
	bge	p10
	ori	#$40,d7
p10:	move	d2,d6
	move	d1,$62(a0)
	move	d2,d1	
	sub	d0,d1
	move	d1,$64(a0)
	move	#row,$60(a0)
	addq	#1,d0
	asl	#6,d0
	addq	#2,d0
	ror.l	#4,d4
	or.l	d4,d7
	move	#$8000,$74(a0)
	ori.l	#$b4a0002,d7		;LF itp
	add.l	a5,d3			;rastport
	move.l	d7,$40(a0)
	move	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move	#$ffff,$72(a0)
	move	d0,$58(a0)
	movem.l	(a7)+,d0-d7
	rts

rotate:	andi.l	#$1fe,d0	;obroc punkty
	cmpi	#128,d0
	beq	norot
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
norot:	rts	

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

osmioscian:
dc.w	-10,30,995
dc.w	2,6,-4
dc.w	128,128,128
dc.w	7,5
dc.l	f1dots,f1pla
f1dots:
dc.w	-1000,-550,-200
dc.w	1000,-550,-200
dc.w	1000,550,-200
dc.w	-1000,550,-200
dc.w	-1000,-550,200
dc.w	1000,-550,200
dc.w	1000,550,200
dc.w	-1000,550,200

f1pla:
dc.w	1,4,0,1,2,3
dc.w	1,4,4,7,6,5
dc.w	2,4,1,5,6,2
dc.w	2,4,0,3,7,4
dc.w	3,4,2,6,7,3
dc.w	3,4,1,0,4,5

;-------------------------------------------------------------


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

	OR.B	#2,$BFE001
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

;--------------tu wchodzi I.V logos------------------------

lo_heigth=86
lo_row=40


init_logos:
 	move	#2,d0
	lea	screen+16,a1
	move.l	#logos,d1
lo_set:	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[lo_heigth*lo_row],d1
	addq	#8,a1
	dbf	d0,lo_set

	move	#7,d0
	lea	colors+4,a1
lo_veccol:move	#4,2(a1)
	move	#$b,6(a1)
	move	#$e,10(a1)
	adda	#16,a1
	dbf	d0,lo_veccol

	move	#90,d0
lo_wt1:	raster
	dbf	d0,lo_wt1

	move	#14,d0
lo_zad:	lea	colors+16,a1
	move	#6,d3
lo_zad1:addi	#$111,2(a1)
	adda	#16,a1
	dbf	d3,lo_zad1
lo_zad2:cmpi.b	#$ff,$dff006
	bne	lo_zad2
	dbf	d0,lo_zad

	move	#15,d0
lo_fad:	lea	colors,a1
	lea	logos+[3*lo_heigth*lo_row],a2
	move	#7,d3
lo_fad1:move	2(a1),d1
	move	(a2),d2
	andi	#$f,d1
	andi	#$f,d2
	cmpi	d1,d2
	beq	lo_fad2
	subi	#1,2(a1)
lo_fad2:move	2(a1),d1
	move	(a2),d2
	andi	#$f0,d1
	andi	#$f0,d2
	cmpi	d1,d2
	beq	lo_fad3
	subi	#$10,2(a1)
lo_fad3:move	2(a1),d1
	move	(a2),d2
	andi	#$f00,d1
	andi	#$f00,d2
	cmpi	d1,d2
	beq	lo_fad4
	subi	#$100,2(a1)
lo_fad4:adda	#16,a1
	adda	#2,a2
	dbf	d3,lo_fad1
	move	#$1a00,d3
lo_wait:muls	d1,d1
	dbf	d3,lo_wait
	dbf	d0,lo_fad

	move	#230,d0
lo_wt9:	raster
	dbf	d0,lo_wt9
	rts

;************************wire trail vectors routine*******************

scrpnt:		dc.w	0
ttheith=256
ttrow=40
ttzoomob=1500
ttzoom=1000
nierys:		dc.b	0
even
tty:		dc.w	0
ttaxid:		dc.w	0
ttcoltab:	dc.b	0,$f,$d,$f,$b,$f,$d,$f,9,$f,$d,$f,$b,$f,$d,$f
		dc.b	7,$f,$d,$f,$b,$f,$d,$f,9,$f,$d,$f,$b,$f,$d,$f
even
;-------------------------------------------------------------------

ttwire:
	bsr	waitvbl
	move	#$100,$96(a0)
;	move.b	#$3,scrcol+6
	move.b	#4,ttcol+7
	lea	szescian,a6		;tu nazwe figury
	move	2(a6),tty
	lea	ttcoltab,a1
	lea	colors,a2
	move	#31,d0
ttcolc:	move.b	(a1)+,2(a2)
	clr.b	3(a2)
	addi	#4,a2
	dbf	d0,ttcolc
	move	#14,d1
ttbarin:bsr	waitvbl
	addi.b	#$10,ttkreg+7
	addi.b	#$10,ttkred+7
	dbf	d1,ttbarin
	move	#15,ubor
	move	#207,dbor

ttclr:	btst.b	#14,$2(a0)
	bne	ttclr
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$6a000,$54(a0)
	move	#[5*ttheith*64]+[ttrow],$58(a0)
ttclr2:	btst.b	#14,$2(a0)
	bne	ttclr2
	move	#3,d7
ttekkr:	bsr	waitvbl
	bsr	ttchgscr
	dbf	d7,ttekkr
	move.b	#$53,scrcol+6		;wlacz obraz
	move	#$8100,$96(a0)
	lea	tp_scr,a1
	lea	text1,a2
	bsr	tp_print

	move	#120,d0
tt_wt1:	raster
	dbf	d0,tt_wt1

;--------------------animacja trailvectors----------------------
ttcontrol:
	cmpi.b	#$ff,$dff006
	bne	ttcontrol
	addi	#1,(a6)
	addi	#4,ttaxid
	move	ttaxid,d0
	andi	#$ff,d0
	lea	sinus,a1
	move	(a1,d0.w),d0
	lsr	#1,d0
	move	tty,d1
	subi	d0,d1
	move	d1,2(a6)
	bsr	ttchgscr
	bsr	ttvector
	cmpi	#70,(a6)
	bne	ttcon2
	lea	tp_scr,a1
	lea	text2,a2
	bsr	tp_print
ttcon2:	cmpi	#440,(a6)
	bne	ttcontrol

;-----------------------przelatujaca pelna kostka---------------

	move.l	#$70000,scron
	move.l	#$70000+[2*heith*row],scroff
	move	#$cc,colors+6
	move	#$99,colors+10
	move	#$66,colors+14
	move	#$cc,colors+22
	move	#$99,colors+26
	move	#$66,colors+30
	bsr	waitvbl
	move.b	#$23,scrcol+6
	lea	kostka,a6
	bsr	speed

ttcontr1:bsr	waitvbl
	subi	#5,(a6)
	subi	#4,2(a6)
	bsr	chgscr
	bsr	vector
	cmpi	#-70,2(a6)
	bpl	ttcontr1

	move	#80,(a6)
	move	#255,dbor
	move	#128,12(a6)
	move	#128,14(a6)
	move	#128,16(a6)
	move	#4,6(a6)
	move	#6,8(a6)
	move	#-6,10(a6)
	move	#850,4(a6)
	lea	tp_scr,a1
	lea	text3,a2
	bsr	tp_print
ttcontr2:bsr	waitvbl
	addi	#1,(a6)
	addi	#3,2(a6)
;	subi	#1,4(a6)
	bsr	chgscr
	bsr	vector
	cmpi	#440,2(a6)
	bmi	ttcontr2

	move	#4,colors+6
	move	#$b,colors+10
	move	#4,colors+14
	move	#4,colors+22
	move	#$b,colors+26
	move	#4,colors+30
	clr	ubor
	lea	prostopad,a6
	bsr	speed
	bsr	waitvbl
	bsr	chgscr
	bsr	vector
	bsr	waitvbl
	bsr	chgscr
	bsr	vector
	bsr	waitvbl
	bsr	chgscr
	bsr	vector
	move	#3,d0
ttloop0:move.b	d0,ttcol+7
	raster
	raster
	dbf	d0,ttloop0
	move	#9,d0
ttloop1:addi	#1,colors+14
	addi	#1,colors+30
	raster
	raster
	raster
	dbf	d0,ttloop1

	move	#100,d0
ttloop2:raster
	dbf	d0,ttloop2
	lea	tp_scr,a1
	lea	text4,a2
	bsr	tp_print
	move	#80,d0
ttloop3:raster
	dbf	d0,ttloop3

	move	#-6,6(a6)
	move	#2,8(a6)
	move	#4,10(a6)

	move	#90,d0
ttconr5:move	d0,-(sp)
	bsr	waitvbl
	bsr	chgscr
	bsr	vector
	move	(sp)+,d0
	dbf	d0,ttconr5

ttconr3:bsr	waitvbl
	bsr	chgscr
	bsr	vector
	addi	#1,4(a6)
	cmpi	#999,4(a6)
	bne	ttconr3

	clr	colors+6
	clr	colors+10
	clr	colors+14
	clr	colors+22
	clr	colors+26
	clr	colors+30
	move	#60,d0
ttloop8:raster
	dbf	d0,ttloop8
	move	#14,d0
ttloop7:sub.b	#$10,ttkreg+7
	sub.b	#$10,ttkred+7
	raster
	raster
	dbf	d0,ttloop7
	move	#40,d0
ttloop9:raster
	dbf	d0,ttloop9

ttconr4:bra	tl_trailinit

;---------procedury wektorowe dla trailvectors-------------

ttchgscr:	move	scrpnt,d0
	bpl	ttchg2
	move	#5,scrpnt
	moveq	#5,d0
ttchg2:	move	#4,d1
	lea	screen+2,a1
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

ttlindraw:move	#$ffff,ld_texture
	move.l	scroff,ld_addr
	move	#ttrow,ld_row

ld_line:movem.l	d0-d7,-(sp)	;rys.linie
ttwait2:btst	#14,2(a0)
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
	mulu	ld_row,d3
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
	move	ld_row,$60(a0)
	addq	#1,d0
	asl	#6,d0
	addq	#2,d0
	ror.l	#4,d4
	or.l	d4,d7
	move	#$8000,$74(a0)
	ori.l	#$bca0000,d7		;LF itp
	add.l	ld_addr,d3		;rastport
	move.l	d7,$40(a0)
	move	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move	ld_texture,$72(a0)
	move	d0,$58(a0)
	movem.l	(a7)+,d0-d7
ttnoline:rts

szescian:
dc.w	-130,140,400	;xmid,ymid,zmid
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

kostka:
dc.w	360,250,920
dc.w	-8,6,8
dc.w	128,128,128
dc.w	7,5
dc.l	kodots,kopla
kodots:
dc.w	-500,-500,-500
dc.w	500,-500,-500
dc.w	500,500,-500
dc.w	-500,500,-500
dc.w	-500,-500,500
dc.w	500,-500,500
dc.w	500,500,500
dc.w	-500,500,500
kopla:
dc.w	1,4,0,1,2,3
dc.w	1,4,4,7,6,5
dc.w	2,4,1,5,6,2
dc.w	2,4,0,3,7,4
dc.w	3,4,2,6,7,3
dc.w	3,4,1,0,4,5


prostopad:
dc.w	150,110,835
dc.w	0,0,0
dc.w	128,128,128
dc.w	29,9
dc.l	prodots,propla
prodots:
dc.w	-1000,-550,-200
dc.w	1000,-550,-200
dc.w	1000,550,-200
dc.w	-1000,550,-200
dc.w	-1000,-550,200
dc.w	1000,-550,200
dc.w	1000,550,200
dc.w	-1000,550,200

dc.w	-500,300,-200
dc.w	-600,-400,-200
dc.w	-300,100,-200
dc.w	-200,-400,-200
dc.w	-300,300,-200
dc.w	-500,-100,-200

dc.w	200,0,-200
dc.w	0,300,-200
dc.w	-200,0,-200
dc.w	0,-400,-200

dc.w	100,0,-200
dc.w	0,200,-200
dc.w	-100,0,-200
dc.w	0,-200,-200

dc.w	800,-400,-200
dc.w	600,300,-200
dc.w	500,-100,-200
dc.w	400,300,-200
dc.w	200,-400,-200
dc.w	400,0,-200
dc.w	500,-300,-200
dc.w	600,0,-200

propla:
dc.w	1,4,0,1,2,3
dc.w	1,4,4,7,6,5
dc.w	2,4,1,5,6,2
dc.w	2,4,0,3,7,4
dc.w	3,4,2,6,7,3
dc.w	3,4,1,0,4,5

dc.w	2,6,8,9,10,11,12,13
dc.w	2,4,14,15,16,17
dc.w	2,4,18,19,20,21
dc.w	2,8,22,23,24,25,26,27,28,29

;-----------------------typer----------------------
;	    '					     '
text1:	dc.b"        ...THE TIME HAS COME...         ",0,200,0
text2:	dc.b"      FINALLY SUSPECT WELCOMES YOU      ",0,100,255
	dc.b"        TO A RELATIVELY NEW DEMO        ",0,100,255
	dc.b"        CALLED 'IMMORTAL VISIONS'       ",0,100,0
text3:	dc.b"             AS YOU'VE SEEN             ",0,100,255
	dc.b" WE'VE STARTED WITH TRAILED WIREVECTORS ",0,140,0
text4:	dc.b"                 ENJOY                  ",0,120,255
	dc.b"        SOME OLD BUT STILL GOOD         ",0,120,255
	dc.b"              SHADE TRAILS              ",0,140,0
qu_text:dc.b"     NOW SOME SHORT GENERAL CREDITS     ",0,120,0
qu_txt1:dc.b"                 CODING                 ",0,255,0
qu_txt2:dc.b"                GRAPHICS                ",0,255,0
qu_txt3:dc.b"                 MUSIC                  ",0,255,0
ve_txt1:dc.b"      WHAT ARE WE GOING TO DO NOW ?     ",0,230,255
	dc.b"                  YEAH !                ",0,220,0
ve_txt2:dc.b"WE'RE IN FOR A SHORT RAYTRACED ANIMATION",0,200,0
aa_txt1:dc.b"     DID YOU LIKE THE COLOURS DUDE ?    ",0,130,0
even

tp_scarea:	ds.b	[16*40],0
tp_fntarea:	ds.b	1024,0
tp_scaddr:	dc.l	0
tp_txtpoint:	dc.l	0
tp_counter:	dc.b	0
tp_in:		dc.b	0
tp_iocount:	dc.b	2
even

;a1-ekran+kolor w copperliscie
;a2-pocz tekstu

tp_init:move.l	#tp_scarea,d0
	move	d0,6(a1)
	swap	d0
	move	d0,2(a1)
	rts

tp_print:move.l	a1,tp_scaddr
	bsr	tp_insert
	move	#$4000,$dff09a
	move.l	$6c,tp_jump+2
	move.l	#tp_level3,$6c
	move	#$c000,$dff09a
	rts

tp_insert:movem.l d0-d2/a3,-(sp)
	lea	tp_scarea,a1
tp_loop:clr.l	d0
	move.b	(a2)+,d0
	beq	tp_end
	subi	#32,d0
	mulu	#16,d0
	add.l	#tp_fntarea,d0
	move.l	d0,a3
	move	#15,d1
	clr	d2
tp_lo1:	move.b	(a3)+,(a1,d2.w)
	addi	#40,d2
	dbf	d1,tp_lo1
	addi	#1,a1
	bra	tp_loop
tp_end:	move.b	(a2)+,tp_counter
	move.l	a2,tp_txtpoint
	movem.l	(sp)+,d0-d2/a3
	rts

tp_level3:
	movem.l	d0/a1/a2,-(sp)
	move	#$20,$dff09c
	move.l	tp_scaddr,a1
	btst.b	#0,tp_in
	bne	tp_lev1
	addi	#$111,10(a1)
	cmpi	#$fff,10(a1)
	bne	tp_quit
	move.b	#3,tp_in
	bra	tp_quit
tp_lev1:btst.b	#1,tp_in
	beq	tp_lev2
	sub.b	#1,tp_iocount
	bne	tp_quit
	move.b	#2,tp_iocount
	subi	#$111,10(a1)
	cmpi	#$ccc,10(a1)
	bne	tp_quit
	move.b	#5,tp_in
	bra	tp_quit
tp_lev2:btst.b	#2,tp_in
	beq	tp_lev3
	sub.b	#1,tp_counter
	bne	tp_quit
	move.b	#9,tp_in
	bra	tp_quit
tp_lev3:btst.b	#3,tp_in
	subi	#$111,10(a1)
	bne	tp_quit
	move.l	tp_txtpoint,a2
	move.b	(a2)+,d0
	cmp.b	#255,d0
	bne	tp_lev4
	sf	tp_in
	clr	10(a1)
	bsr	tp_insert
	bra	tp_quit
tp_lev4:move.l	tp_jump+2,$6c
	clr	10(a1)
	sf	tp_in
tp_quit:movem.l	(sp)+,d0/a1/a2
tp_jump:jmp	0

tp_initfnt:
	movem.l	a1/a2/d0/d1,-(sp)
	lea	tp_fonts,a1
	lea	tp_fntarea,a2
	move	#15,d0
	bsr	tp_fnt1
	addi	#16,a2
	move	#14,d0
	bsr	tp_fnt1
	movem.l	(sp)+,a1/a2/d0/d1
	rts
tp_fnt1:move	#15,d1
tp_fnt2:move.b	(a1)+,(a2)
	move.b	(a1)+,16(a2)
	addi	#1,a2
	dbf	d1,tp_fnt2
	addi	#16,a2
	dbf	d0,tp_fnt1
	rts

;-------------------decruncher----------------------------

Decrunch:
	lea costam(pc),a2
	move.l 4(a0),(a2)
	add.l d0,a0
	bsr.s	lbC000EAE
	rts
lbC000EAE
	move.l a1,a2
	lea costam(pc),a5
	move.l -(a0),d5
	moveq.l	#0,d1
	move.b d5,d1
	lsr.l #8,d5
	add.l d5,a1
	move.l -(a0),d5
	lsr.l d1,d5
	moveq.b	#$20,d7
	sub.b d1,d7
lbC000EC8
	bsr.s lbC000F3A
	tst.b d1
	bne.s lbC000EEE
	moveq #0,d2
lbC000ED0
	moveq.l #2,d0
	bsr.s lbC000F3C
	add.w d1,d2
	cmp.w #3,d1
	beq.s lbC000ED0
lbC000EDC
	moveq #8,d0
	bsr.s lbC000F3C
	move.b	d1,-(a1)
	dbf d2,lbC000EDC
	cmp.l	a1,a2
	bcs.s	lbC000EEE
	rts
lbC000EEE
	moveq.l #2,d0
	bsr.s	lbC000F3C
	moveq.l	#0,d0
	move.b	0(a5,d1.w),d0
	move.l	d0,d4
	move.w	d1,d2
	addq.w	#1,d2
	cmp.w	#4,d2
	bne.s lbC000F20
	bsr.s lbC000F3A
	move.l d4,d0
	tst.b d1
	bne.s lbC000F0E
	moveq.l	#7,d0
lbC000F0E
	bsr.s	lbC000F3C
	move.w	d1,d3
lbC000F12
	moveq.l #3,d0
	bsr.s lbC000F3C
	add.w	d1,d2
	cmp.w	#7,d1
	beq.s	lbC000F12
	bra.s	lbC000F24
lbC000F20
	bsr.s	lbC000F3C
	move.w	d1,d3
lbC000F24
	move.b	0(a1,d3.w),d0
	move.b	d0,-(a1)
	dbf d2,lbC000F24
	cmp.l	a1,a2
	bcs.s	lbC000EC8
	rts
lbC000F3A
	moveq.l	#1,d0
lbC000F3C
	moveq.l	#0,d1
	subq.w	#1,d0
lbC000F40
	lsr.l	#1,d5
	roxl.l	#1,d1
	subq.b	#1,d7
	bne.s	lbC000F4E
	moveq.b	#$20,d7
	move.l	-(a0),d5
lbC000F4E
	dbf d0,lbC000F40
	rts

costam	dc.l	$090A0B0B

;-----------------------TRAIL PART----------------------------

tl_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920028,$9400d8,$8e0000,$90ffff
tl_cols:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
tl_scrn:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$1020000,$1080000,$10a0000
dc.l	$4a01ff00,$01003200
dc.l	$8001ff00,$9aa000
dc.l	$8801ff00,$9a2000
dc.l	$fe01ff00,$01000200
dc.l	$fffffffe

;-------------------------------------------------------------------
tl_screen=$70000
tl_row=46				;wymiary ekranu
tl_heith=180

tl_objectnum:	dc.w	0
tl_objecttab:	dc.l	tl_ob1,tl_ob5,tl_ob3,tl_ob4,tl_ob2,0

tl_speedxa:	dc.w	0	;szybkosc calosci (tylko parzyste)
tl_speedya:	dc.w	0
tl_speedxb:	dc.w	0
tl_speedyb:	dc.w	0
tl_speed1a:	dc.w	0	;szybkosc poszczegolnych kresek
tl_speed2a:	dc.w	0
tl_speed1b:	dc.w	0
tl_speed2b:	dc.w	0

tl_angle1a:	dc.w	0	;poczatkowe katy
tl_angle2a:	dc.w	0
tl_angle1b:	dc.w	0
tl_angle2b:	dc.w	0

tl_drawaddr:	dc.l	0
tl_brflag:		dc.b	1
tl_ilval:		dc.b	0
tl_timer:		dc.w	1	;licznik czasu
tl_timval:		dc.w	0
tl_andcol:		dc.w	0
tl_colnum:		dc.w	0
tl_coltab:		blk.w	8,0	;tablica kolorow
;-------------------------------------------------------------------

tl_trailinit:
	move.l	#tl_copper,$dff080
	clr	$dff088
	move.l	#tl_screen,scron
	move.l	#tl_screen+[3*tl_heith*tl_row],scroff
	move.l	#$ffffffff,$44(a0)	
	bsr	tl_newobject
tl_control:
	cmpi.b	#$ff,$dff006
	bne	tl_control
	bsr	tl_trail
	cmpi	#$aaaa,tl_timval
	bne	tl_control
	move	#70,d0
ttlop1:	raster
	dbf	d0,ttlop1
	bra	qu_credits

tl_trail:btst.b	#14,$2(a0)
	bne	tl_trail
	move.l	scron,d0		;zmien ekrany
	move.l	scroff,d1
	move.l	d0,scroff
	move.l	d1,scron
	move	d1,tl_scrn+6
	swap	d1
	move	d1,tl_scrn+2
	swap	d1
	add.l	#[tl_heith*tl_row],d1
	move	d1,tl_scrn+14
	swap	d1
	move	d1,tl_scrn+10
	swap	d1
	add.l	#[tl_heith*tl_row],d1
	move	d1,tl_scrn+22
	swap	d1
	move	d1,tl_scrn+18
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[3*tl_heith*64]+[tl_row/2],$58(a0)

	lea	tl_sinus,a1
	move	tl_angle1a,d0
	move	tl_angle2a,d1
	move	tl_angle1b,d2
	move	tl_angle2b,d3
	add	tl_speedxa,d0
	add	tl_speedya,d1
	add	tl_speedxb,d2
	add	tl_speedyb,d3
	andi.l	#$3fe,d0	;sinus ma 1 Kb
	andi.l	#$3fe,d1
	andi.l	#$3fe,d2
	andi.l	#$3fe,d3
	move	d0,tl_angle1a
	move	d1,tl_angle2a
	move	d2,tl_angle1b
	move	d3,tl_angle2b
	move	#7,d6		;il.kolorow
tl_trlop1:	move.w	tl_colnum,d7
	subi	#1,d7
tl_trloop:	move.l	scroff,tl_drawaddr
	movem.l	d0-d7,-(sp)
	move	(a1,d0.w),d0
	move	(a1,d1.w),d1
	move	(a1,d2.w),d2
	move	(a1,d3.w),d3
	asr	#1,d1
	asr	#1,d3
	asr	#1,d2		;ograniczenia ekranu
	addi	#180,d0
	addi	#180,d2
	addi	#90,d1
	addi	#90,d3
	move	#$ffff,ld_texture
	btst	#0,d6
	bne	tl_tr1
	move.w	#0,ld_texture
tl_tr1:	bsr	tl_makeline
	add.l	#8280,tl_drawaddr
	move.w	#$ffff,ld_texture
	btst	#1,d6
	bne	tl_tr2
	move.w	#0,ld_texture
tl_tr2:	bsr	tl_makeline
	add.l	#8280,tl_drawaddr
	move.w	#$ffff,ld_texture
	btst	#2,d6
	bne	tl_tr3
	move.w	#0,ld_texture
tl_tr3:	bsr	tl_makeline
	movem.l	(sp)+,d0-d7
	add.w	tl_speed1a,d0
	add.w	tl_speed2a,d1
	add.w	tl_speed1b,d2
	add.w	tl_speed2b,d3
	andi.l	#$3fe,d0
	andi.l	#$3fe,d1
	andi.l	#$3fe,d2
	andi.l	#$3fe,d3
	dbf	d7,tl_trloop
	subq	#1,d6
	bne	tl_trlop1

tl_cktime:sub	#1,tl_timer
	bne	tl_quit
	move	#1,tl_timer	;colin speed
	lea	tl_cols,a1
	lea	tl_coltab,a2
	moveq	#6,d0
	cmpi.b	#1,tl_brflag
	beq	tl_bright
	subi.b	#1,tl_ilval
tl_ck1:	move	(a1,d0.w),d1	;powoli wygas...
	beq	tl_ck2
	move	#$111,d2
	andi	tl_andcol,d2
	subi	d2,(a1,d0.w)
tl_ck2:	addq	#4,d0
	cmpi	#34,d0
	bne	tl_ck1
	cmpi.b	#0,tl_ilval
	bne	tl_quit
	bsr	tl_newobject
	move.b	#1,tl_brflag
	move	#10,tl_timer
tl_quit:	rts

tl_bright:	addi.b	#1,tl_ilval
tl_br1:	move	(a1,d0.w),d2
	cmpi	(a2)+,d2
	beq	tl_br2
	move	#$111,d2
	andi	tl_andcol,d2
	addi	d2,(a1,d0.w)
tl_br2:	addq	#4,d0
	cmpi	#34,d0
	bne	tl_br1
	cmpi.b	#15,tl_ilval
	bne	tl_quit
	clr.b	tl_brflag
	move	tl_timval,tl_timer
	rts

tl_makeline:			;rysuj linie
	move.l	tl_drawaddr,ld_addr
	move	#tl_row,ld_row
	bra	ld_line

tl_newobject:			;wstaw nowe dane
	lea	tl_objecttab,a1
	clr.l	d0
	move	tl_objectnum,d0
	lsl	#2,d0
	move.l	(a1,d0.w),a1
	cmpa.l	#0,a1
	beq	tl_nomore
	move	(a1)+,d0
	divu	#7,d0
	move	d0,tl_colnum
	move	(a1)+,tl_timval
	move	(a1)+,tl_andcol
	lea	tl_coltab,a2
	move	#6,d0
tl_new3:move	(a1)+,(a2)+
	dbf	d0,tl_new3
	move.l	(a1)+,tl_angle1a
	move.l	(a1)+,tl_angle1b
	move.l	(a1)+,tl_speedxa
	move.l	(a1)+,tl_speedxb
	move.l	(a1)+,tl_speed1a
	move.l	(a1)+,tl_speed1b
	addi	#1,tl_objectnum
	rts
tl_nomore:move	#$aaaa,tl_timval
	rts

;----------------------------obiekty-----------------------------

tl_ob1:
dc.w	63		;il. linii
dc.w	60		;czas
dc.w	$0ff		;ktore kol. uzywane
dc.w	$ee,$cc,$aa,$88,$66,$44,$22	;kolory
dc.w	20,250,760,800	;pocz.katy
dc.w	34,-18,20,-28	;sz. calosci
dc.w	8,-6,4,-10	;sz.linii

tl_ob2:
dc.w	63
dc.w	60
dc.w	$f0f
dc.w	$f0f,$d0d,$b0b,$909,$707,$505,$303
dc.w	200,26,60,900
dc.w	30,-10,20,-16
dc.w	10,-4,8,-12

tl_ob3:
dc.w	70
dc.w	60
dc.w	$f00
dc.w	$f00,$e00,$d00,$b00,$900,$700,$400
dc.w	200,526,960,340
dc.w	16,-18,36,-6
dc.w	10,-14,18,-2

tl_ob4:
dc.w	77
dc.w	60
dc.w	$f0
dc.w	$f0,$d0,$b0,$90,$70,$50,$30
dc.w	2,100,600,700
dc.w	10,-28,46,-16
dc.w	6,-4,8,-12

tl_ob5:
dc.w	70
dc.w	60
dc.w	$fff
dc.w	$eee,$ccc,$aaa,$888,$666,$444,$222
dc.w	20,960,300,460
dc.w	-10,18,-16,8
dc.w	-18,24,-22,16

tl_sinus:
	dc.w	$0000,$0002,$0004,$0006,$0008,$000B,$000D,$000F
	dc.w	$0011,$0013,$0016,$0018,$001A,$001C,$001E,$0021
	dc.w	$0023,$0025,$0027,$0029,$002B,$002D,$0030,$0032
	dc.w	$0034,$0036,$0038,$003A,$003C,$003E,$0040,$0042
	dc.w	$0045,$0047,$0049,$004B,$004D,$004F,$0051,$0053
	dc.w	$0055,$0056,$0058,$005A,$005C,$005E,$0060,$0062
	dc.w	$0064,$0066,$0067,$0069,$006B,$006D,$006E,$0070
	dc.w	$0072,$0074,$0075,$0077,$0079,$007A,$007C,$007D
	dc.w	$007F,$0081,$0082,$0084,$0085,$0087,$0088,$0089
	dc.w	$008B,$008C,$008E,$008F,$0090,$0092,$0093,$0094
	dc.w	$0095,$0097,$0098,$0099,$009A,$009B,$009C,$009D
	dc.w	$009E,$009F,$00A0,$00A1,$00A2,$00A3,$00A4,$00A5
	dc.w	$00A6,$00A7,$00A8,$00A8,$00A9,$00AA,$00AB,$00AB
	dc.w	$00AC,$00AD,$00AD,$00AE,$00AE,$00AF,$00AF,$00B0
	dc.w	$00B0,$00B1,$00B1,$00B1,$00B2,$00B2,$00B2,$00B2
	dc.w	$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3
	dc.w	$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3,$00B3
	dc.w	$00B3,$00B2,$00B2,$00B2,$00B1,$00B1,$00B1,$00B0
	dc.w	$00B0,$00AF,$00AF,$00AE,$00AE,$00AD,$00AD,$00AC
	dc.w	$00AC,$00AB,$00AA,$00A9,$00A9,$00A8,$00A7,$00A6
	dc.w	$00A6,$00A5,$00A4,$00A3,$00A2,$00A1,$00A0,$009F
	dc.w	$009E,$009D,$009C,$009B,$009A,$0098,$0097,$0096
	dc.w	$0095,$0093,$0092,$0091,$0090,$008E,$008D,$008C
	dc.w	$008A,$0089,$0087,$0086,$0084,$0083,$0081,$0080
	dc.w	$007E,$007D,$007B,$0079,$0078,$0076,$0074,$0073
	dc.w	$0071,$006F,$006E,$006C,$006A,$0068,$0066,$0065
	dc.w	$0063,$0061,$005F,$005D,$005B,$0059,$0057,$0055
	dc.w	$0054,$0052,$0050,$004E,$004C,$004A,$0048,$0046
	dc.w	$0043,$0041,$003F,$003D,$003B,$0039,$0037,$0035
	dc.w	$0033,$0031,$002F,$002C,$002A,$0028,$0026,$0024
	dc.w	$0022,$001F,$001D,$001B,$0019,$0017,$0014,$0012
	dc.w	$0010,$000E,$000C,$0009,$0007,$0005,$0003,$0001
	dc.w	$FFFF,$FFFD,$FFFB,$FFF9,$FFF7,$FFF4,$FFF2,$FFF0
	dc.w	$FFEE,$FFEC,$FFE9,$FFE7,$FFE5,$FFE3,$FFE1,$FFDE
	dc.w	$FFDC,$FFDA,$FFD8,$FFD6,$FFD4,$FFD1,$FFCF,$FFCD
	dc.w	$FFCB,$FFC9,$FFC7,$FFC5,$FFC3,$FFC1,$FFBF,$FFBD
	dc.w	$FFBA,$FFB8,$FFB6,$FFB4,$FFB2,$FFB0,$FFAE,$FFAC
	dc.w	$FFAB,$FFA9,$FFA7,$FFA5,$FFA3,$FFA1,$FF9F,$FF9D
	dc.w	$FF9B,$FF9A,$FF98,$FF96,$FF94,$FF92,$FF91,$FF8F
	dc.w	$FF8D,$FF8C,$FF8A,$FF88,$FF87,$FF85,$FF83,$FF82
	dc.w	$FF80,$FF7F,$FF7D,$FF7C,$FF7A,$FF79,$FF77,$FF76
	dc.w	$FF74,$FF73,$FF72,$FF70,$FF6F,$FF6E,$FF6D,$FF6B
	dc.w	$FF6A,$FF69,$FF68,$FF66,$FF65,$FF64,$FF63,$FF62
	dc.w	$FF61,$FF60,$FF5F,$FF5E,$FF5D,$FF5C,$FF5B,$FF5A
	dc.w	$FF5A,$FF59,$FF58,$FF57,$FF57,$FF56,$FF55,$FF54
	dc.w	$FF54,$FF53,$FF53,$FF52,$FF52,$FF51,$FF51,$FF50
	dc.w	$FF50,$FF4F,$FF4F,$FF4F,$FF4E,$FF4E,$FF4E,$FF4D
	dc.w	$FF4D,$FF4D,$FF4D,$FF4D,$FF4D,$FF4D,$FF4D,$FF4D
	dc.w	$FF4D,$FF4D,$FF4D,$FF4D,$FF4D,$FF4D,$FF4D,$FF4D
	dc.w	$FF4E,$FF4E,$FF4E,$FF4E,$FF4F,$FF4F,$FF4F,$FF50
	dc.w	$FF50,$FF51,$FF51,$FF52,$FF52,$FF53,$FF53,$FF54
	dc.w	$FF55,$FF55,$FF56,$FF57,$FF58,$FF58,$FF59,$FF5A
	dc.w	$FF5B,$FF5C,$FF5D,$FF5E,$FF5F,$FF60,$FF61,$FF62
	dc.w	$FF63,$FF64,$FF65,$FF66,$FF67,$FF68,$FF69,$FF6B
	dc.w	$FF6C,$FF6D,$FF6E,$FF70,$FF71,$FF72,$FF74,$FF75
	dc.w	$FF77,$FF78,$FF79,$FF7B,$FF7C,$FF7E,$FF7F,$FF81
	dc.w	$FF83,$FF84,$FF86,$FF87,$FF89,$FF8B,$FF8C,$FF8E
	dc.w	$FF90,$FF92,$FF93,$FF95,$FF97,$FF99,$FF9A,$FF9C
	dc.w	$FF9E,$FFA0,$FFA2,$FFA4,$FFA6,$FFA8,$FFAA,$FFAB
	dc.w	$FFAD,$FFAF,$FFB1,$FFB3,$FFB5,$FFB7,$FFB9,$FFBB
	dc.w	$FFBE,$FFC0,$FFC2,$FFC4,$FFC6,$FFC8,$FFCA,$FFCC
	dc.w	$FFCE,$FFD0,$FFD3,$FFD5,$FFD7,$FFD9,$FFDB,$FFDD
	dc.w	$FFDF,$FFE2,$FFE4,$FFE6,$FFE8,$FFEA,$FFED,$FFEF
	dc.w	$FFF1,$FFF3,$FFF5,$FFF8,$FFFA,$FFFC,$FFFE,$0000


;------------------------C R E D I T S Y---------------------------

qu_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1,$1020000,$1080000,$10a0000 ;bplcon1,modulo1
dc.l	$2f01ff00,$01001300
qu_scr:
dc.l	$e00007,$e25000
dc.l	$1820000
dc.l	$3f01ff00,$01000300
qu_screen:
dc.l	$e00007,$e25000,$e40007,$e65000
dc.l	$1020030
dc.l	$1800000,$18205f0,$1840a0f,$18605f0
dc.l	$4001ff00,$01001300
dc.l	$4101ff00,$01002300
dc.l	$e801ff00,$9aa000
dc.l	$ef01ff00,$9a2000
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
qu_heith=185
qu_row=40
qu_hmid:	dc.w	-120
qu_vmid:	dc.w	138
qu_vmidd:	dc.w	138
qu_jaxid:	dc.w	0
;-------------------------------------------------------------------

qu_credits:lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
	move.l	#$75000,scron
	move.l	#$75000+[qu_heith*qu_row],scroff
qu_set2:btst.b	#14,$2(a0)
	bne	qu_set2
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$75000,$54(a0)
	move	#[qu_heith*64]+[qu_row],$58(a0)
	lea	qu_scr,a1
	bsr	tp_init
qu_set3:btst.b	#14,$2(a0)
	bne	qu_set3
	move.l	#qu_copper,$dff080
	clr	$dff088

	bsr	qu_watt
	add.b	#2,qu_mir1+7
	add.b	#2,qu_mir2+7
	add.b	#2,qu_mir3+7
	bsr	qu_watt
	add.b	#2,qu_mir1+7
	add.b	#2,qu_mir2+7
	bsr	qu_watt
	add.b	#2,qu_mir1+7

	lea	qu_scr,a1
	lea	qu_text,a2
	bsr	tp_print
	move	#190,d0
qu_wat2:raster
	dbf	d0,qu_wat2
	lea	qu_kane,a6
	bsr	qu_create

	lea	qu_scr,a1
	lea	qu_txt1,a2
	bsr	tp_print
qu_control:
	move	#2,counter
	bsr	qu_pass			;kane
	add.l	#[16*32],4(a6)
	bsr	qu_create
	move	#-110,qu_hmid
	lea	qu_scr,a1
	lea	qu_txt1,a2
	bsr	tp_print
	move	#2,counter
	bsr	qu_pass			;pillar
	add.l	#[16*32],4(a6)
	move	#120,8(a6)
	bsr	qu_create
	move	#-130,qu_hmid
	lea	qu_scr,a1
	lea	qu_txt2,a2
	bsr	tp_print
	move	#2,counter
	bsr	qu_pass			;artB
	add.l	#[16*32],4(a6)
	bsr	qu_create
	move	#-130,qu_hmid
	lea	qu_scr,a1
	lea	qu_txt2,a2
	bsr	tp_print
	move	#2,counter
	bsr	qu_pass			;crypton
	add.l	#[16*32],4(a6)
	move	#100,8(a6)
	move	#60,10(a6)
	move	#128,qu_vmidd
	bsr	qu_create
	move	#-110,qu_hmid
	lea	qu_scr,a1
	lea	qu_txt3,a2
	bsr	tp_print
	move	#2,counter
	bsr	qu_pass			;xtd
	add.l	#[16*32],4(a6)
	bsr	qu_create
	move	#-110,qu_hmid
	lea	qu_scr,a1
	lea	qu_txt3,a2
	bsr	tp_print
	move	#2,counter
	bsr	qu_pass			;kalosz
	bra	ve_odlot

qu_watt:move	#6,d1
qu_mirin:raster
	dbf	d1,qu_mirin
	rts

qu_pass:
	cmpi.b	#$ff,6(a0)
	bne	qu_pass
	move	counter,d0
	bpl	qu_pass
	move	#2,counter
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
	bra	qu_pass
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

qu_kane:
dc.l	$70000,qu_rysunek		;adres obrazka (tu 64*32)
dc.w	80,50,2,4	;promienie krzywizn i gestosc punktow
dc.w	128
dc.w	-10

;------------------statek vectorowy---------------------
ve_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
dc.l	$1020000,$1080000,$10a0000
ve_colors:
dc.l	$1800000,$1820404,$1840707,$1860440,$1880000,$18a0404,$18c0707,$18e0440
ve_screen:
dc.l	$e00007,$e20000,$e40007,$e60000
dc.l	$2c01ff00,$01002300

dc.l	$8c01ff00,$01003300
ve_scr:
dc.l	$e80007,$ea0000
dc.l	$1880000
dc.l	$9c01ff00,$01002300

dc.l	$e801ff00,$9aa000
dc.l	$ef01ff00,$9a2000
ve_mir1:
dc.l	$f801ff00,$1800006
dc.l	$ffdffffe
ve_mir2:
dc.l	$0801ff00,$1800004
ve_mir3:
dc.l	$1801ff00,$1800002
dc.l	$2c01ff00,$01000300
dc.l	$fffffffe

ve_copper2:
dc.l	$920038,$9400d0,$8e0171,$9037d1
dc.l	$1020000,$1080000,$10a0000
dc.l	$8c01ff00,$01001300
ve_scr2:
dc.l	$e00007,$e20000
dc.l	$1820000
dc.l	$9c01ff00,$01000300
dc.l	$c801ff00,$9aa000
dc.l	$cf01ff00,$9a2000
dc.l	$fffffffe

;--------------------------------------------------------------


ve_odlot:
	move	#$100,$dff096
	lea	ve_scr,a1
	bsr	tp_init
	move	#20,d0
qu_wat4:raster
	dbf	d0,qu_wat4
	move.l	#$70000,scron
	move.l	#$70000+[2*heith*row],scroff
	bsr	ve_chgscr
	bsr	ve_chgscr
	bsr	ve_chgscr
	lea	statek,a6
	bsr	speed
	raster
	move.l	#ve_copper,$dff080
	clr	$dff088
	move	#$8100,$dff096
	move	#30,d0
ve_wat0:raster
	dbf	d0,ve_wat0
	lea	ve_scr,a1
	lea	ve_txt1,a2
	bsr	tp_print

	move	#50,d0
ve_wat1:raster
	dbf	d0,ve_wat1
	bsr	qu_watt
	sub.b	#2,ve_mir1+7
	sub.b	#2,ve_mir2+7
	sub.b	#2,ve_mir3+7
	bsr	qu_watt
	sub.b	#2,ve_mir1+7
	sub.b	#2,ve_mir2+7
	bsr	qu_watt
	sub.b	#2,ve_mir1+7

	move	#2,counter
ve_cont:bsr	waitvbl
	subi	#8,(a6)
	subi	#4,2(a6)
	addi	#1,4(a6)
	bsr	ve_chgscr
	bsr	vector
	cmpi	#-210,(a6)
	bgt	ve_cont

	move	#8,6(a6)
ve_cont2:bsr	waitvbl
	addi	#5,(a6)
	addi	#2,2(a6)
	addi	#2,4(a6)
	bsr	ve_chgscr
	bsr	vector
	cmpi	#995,4(a6)
	blt	ve_cont2

	clr	ve_colors+6
	clr	ve_colors+10
	clr	ve_colors+14
	clr	ve_colors+22
	clr	ve_colors+26
	clr	ve_colors+30
	move	#100,d0
ve_wat2:raster
	dbf	d0,ve_wat2
	lea	ve_scr2,a1
	bsr	tp_init
	raster
	move.l	#ve_copper2,$dff080
	clr	$dff088
	lea	ve_scr2,a1
	lea	ve_txt2,a2
	bsr	tp_print
	move	#50,d0
ve_wat3:raster
	dbf	d0,ve_wat3
	bra	an_animation

ve_chgscr:btst.b #14,$2(a0)
	bne	ve_chgscr
	move.l	scron,d0		;zmien ekrany
	move.l	scroff,d1
	move.l	d0,scroff
	move.l	d1,scron
	move	d1,ve_screen+6
	swap	d1
	move	d1,ve_screen+2
	swap	d1
	add.l	#[heith*row],d1
	move	d1,ve_screen+14
	swap	d1
	move	d1,ve_screen+10
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[2*heith*64]+[row/2],$58(a0)
	rts

statek:
dc.w	400,240,700
dc.w	0,0,0
dc.w	128,100,220
dc.w	8,5
dc.l	stdots,stpla
stdots:
dc.w	-900,0,0
dc.w	900,200,0
dc.w	900,0,-450
dc.w	900,-200,0
dc.w	900,0,450

dc.w	900,160,0
dc.w	900,0,-400
dc.w	900,-160,0
dc.w	900,0,400

stpla:
dc.w	1,3,0,3,2
dc.w	2,3,0,2,1
dc.w	1,3,0,1,4
dc.w	2,3,0,4,3
dc.w	3,4,1,2,3,4
dc.w	2,4,5,6,7,8

;--------------------------mala animacja---------------------------
aaobrazg=$60000+[20*512]
aaobrazek=aaobrazg+6120

aaobrpnt:		dc.w	0
aaobrtab:
dc.l aaobrazek,aaobrazek+[9240],aaobrazek+[2*9240],aaobrazek+[3*9240]
dc.l aaobrazek+[4*9240],aaobrazek+[5*9240],aaobrazek+[6*9240]
dc.l aaobrazek+[7*9240],0

aaheigthg=51
aaheigth=77
aarow=20
;-----------------------------------------------------------------
an_animation:
	moveq	#44,d0
	moveq	#9,d1
	move.l	#$60000,d2
	bsr	dl_start
	
	move.l	#aaobrazg,d1
	move	#5,d3
	lea	aascreeng,a1
aachgl:	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[aaheigthg*aarow],d1
	adda	#8,a1
	dbf	d3,aachgl
	move.l	#aacopper,$dff080
	clr	$dff088
	move	#14,d1
aaramka:add.b	#$11,aaramg+7
	add.b	#$11,aaramd+7
	move	#1,d0
	bsr	aawait
	dbf	d1,aaramka
	sf	aawyjdz

aashow:	move	#3,d0
	bsr	aawait
aachgscr:lea	aaobrtab,a1
	move	aaobrpnt,d0
	lsl	#2,d0
	move.l	(a1,d0.w),d1
	bne	aachg2
	clr	aaobrpnt
	bra	aachgscr
aachg2:	addi	#2,aaobrpnt
	bsr	aasetaddr
	tst	aaexit
	beq	aashow

	move	#14,d1
aaramka2:sub.b	#$11,aaramg+7
	sub.b	#$11,aaramd+7
	move	#1,d0
	bsr	aawait
	dbf	d1,aaramka2
	move	#80,d0
aa_wat5:raster
	dbf	d0,aa_wat5
	lea	ve_scr2,a1
	bsr	tp_init
	raster
	move.l	#ve_copper2,$dff080
	clr	$dff088
	lea	ve_scr2,a1
	lea	aa_txt1,a2
	bsr	tp_print
	move	#180,d0
aa_wat1:raster
	dbf	d0,aa_wat1
	bra	pl_plasm

;------------------zmiana ekranu---------------------------
aasetaddr:move	#5,d3
	lea	aascreen,a1
aachgloop:move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[aaheigth*aarow],d1
	adda	#8,a1
	dbf	d3,aachgloop
	rts
;---------------czekanie i poruszanie obrazkiem-------------
aawait:	cmpi.b	#$f8,$dff006
	bne	aawait

	subi	#1,aalicz
	move	d0,-(sp)
	tst.b	aawyjdz
	bne	aadalej
	sub.b	#2,aalinia
	move.b	aalinia,d0
	cmp.b	#$5f,d0
	bne	aawy2
	st	aawyjdz

	bra	aakon
aawy2:	move.b	d0,aal1
	add.b	#51,d0
	cmp.b	#$ef,d0
	bmi	aawy3
	move.b	#$ef,d0
aawy3:	move.b	d0,aal2
	add.b	#77,d0
	cmp.b	#$ef,d0
	bmi	aawy4
	move.b	#$ef,d0
aawy4:	move.b	d0,aal3
	bra	aakon
aadalej:tst	aalicz
	bne	aakon
	move	#1,aalicz
	tst	aaexit
	bne	aakon
	add.b	#2,aalinia
	move.b	aalinia,d0
	cmp.b	#$f1,d0
	bne	aawy5
	move	#1,aaexit
	bra	aakon
aawy5:	move.b	d0,aal1
	add.b	#51,d0
	cmp.b	#$ef,d0
	bmi	aawy6
	move.b	#$ef,d0
aawy6:	move.b	d0,aal2
	add.b	#77,d0
	cmp.b	#$ef,d0
	bmi	aawy7
	move.b	#$ef,d0
aawy7:	move.b	d0,aal3
aakon:	move	(sp)+,d0

aashow2:cmpi.b	#$ff,$dff006
	bne	aashow2
	dbf	d0,aawait
	rts
;----------------------------------------------------------
aawyjdz:	dc.b	1
aalinia:	dc.b	$ef
aalicz:		dc.w	600
aaexit:		dc.w	0

aacopper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$1800000,$182066f,$1840950,$1860214,$1880ed3,$18a022c,$18c0d99,$18e0776
dc.l	$1900eef,$1920d92,$1940641,$1960330,$1980f55,$19a054a,$19c0ff9,$19e0bbf

dc.l	$920060,$9400a8,$8e0171,$9037d1
dc.l	$1020000,$1080000,$10a0000
dc.l	$4001ff00,$9aa000
dc.l	$4801ff00,$9a2000
aascreeng:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$ec0007,$ee0000,$f00007,$f20000,$f40007,$f60000
aaramg:
dc.l	$5001ff00,$1800000,$5101ff00,$1800000
aal1:
dc.l	$ef01ff00,$01006b00
aal2:
dc.l	$ef01ff00,$01006b00
aascreen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$ec0007,$ee0000,$f00007,$f20000,$f40007,$f60000
aal3:
dc.l	$ef01ff00,$01000300
aaramd:
dc.l	$f001ff00,$1800000,$f101ff00,$1800000
dc.l	$fffffffe

;--------------------------ladowanie--------------------------

;	d0=start cylinder
;	d1=no. of cylinders to read
;	d2=load address to be outputed in to.


DL_start:bsr	DL_seekTRK0
	movem.l d0-d7/a0-a6,-(a7)
	tst	d1		;if 0 trk the exit
	beq.s	DL_start-2
	cmp.l	#$7fffe,d2	;if address out then exit
	bge.s	DL_start-2
	tst.l	d2		;if address minus then exit
	ble.s	DL_start-2
	cmp.b	#80,d0		;if track > 81
	bge.s	DL_start-2
	cmp.b	#-1,d0		;if track < 0
	ble.s	DL_start-2
	bsr	DL_seektrack
	bsr	DL_setup
	bsr	DL_readboth
DL_load:
	cmp	#1,d1
	beq.s	DL_setdown
	subq	#1,d1
	bsr	DL_headin
	bsr	DL_readboth	
	bra.s	DL_load

DL_setup:
	lea	DL_loadadr(pc),a0
	move.l	d2,(a0)
	move	$dff010,D0
	bset	#15,D0
	lea	DL_Uart(pc),a0
	move	D0,(a0)
	rts

DL_setdown:
	move.b	#$f9,D0
	move.b	D0,$bfd100
	and.b	DL_Dsk(pc),D0
	move.b	D0,$bfd100
	move	#$7fff,$dff09e
	move	DL_Uart(pc),$dff09e
	movem.l (a7)+,d0-d7/a0-a6
	rts
DL_readupper:
	bclr	#2,$bfd100
	bra.s DL_set
DL_readlower:
	bset	#2,$bfd100
	bra.s DL_set
DL_readboth:
	bset	#2,$bfd100
	bsr.s	DL_set
	bclr	#2,$bfd100
DL_set: move	#$8210,$dff096
	move	#$7fff,$dff09e
	move	#$9500,$dff09e
	move	#$4489,$dff07e		;sync
	lea	DL_DSKpointer(pc),a0
	move.l	(a0),$dff020
	move	#$4000,$dff024
DL_ready:
	btst	#5,$bfe001
	bne.s	DL_ready
	move	#$9980,$dff024
	move	#$9980,$dff024
	move	#$0002,$dff09c
DL_ready2:
	btst	#1,$dff01f
	beq.s	DL_ready2
	move	#$4000,$dff024
	bsr	DL_Trackuncode
	lea	DL_Loadadr(pc),a0
	addi.l	#$1600,(a0)
	rts

DL_drv: bset	#2,$bfd100

DL_HeadIN:
	lea	DL_TRKno(pc),a0
	addq	#1,(a0)
	move.b	#%01111101,$bfd100
	move.b	#%01111100,D7
	and.b	-2(a0),D7
	bra.s	DL_sel
DL_HeadOUT:
	lea	DL_TRKno(pc),a0
	subq	#1,(a0)
	move.b	#%01111111,$bfd100
	move.b	#%01111110,D7
	and.b	-2(a0),D7
DL_sel:
	mulu	#1,d0
	move.b	D7,$bfd100
	bset	#0,D7
	move.b	D7,$bfd100
	lea	dl_delayT(pc),a0
	move	(a0),D6
DL_delay:
	nop
	dbra	D6,DL_delay
	rts
DL_delayT:
	dc.w $555

DL_seekTRK0:
	btst	#4,$bfe001
	beq.s	DL_trk0
	bsr.s	DL_HeadOUT
	bra.s	DL_seekTRK0
DL_trk0:clr	DL_TRKno
	rts

DL_seektrack:
	lea	dl_trkno(pc),a0
	move	(a0),d3
	cmp	d3,d0
	beq.s	DL_seektrack-2	;do rts
	cmp	d3,d0
	ble.s	DL_seektrack2
	sub	d3,d0
	bra.s	DL_seekd0
DL_seektrack2:
	sub	d0,d3
	move	d3,d0
	bra.s	DL_backd0


DL_seekd0:
	tst	d0
	beq.s	DL_seekd0-2
DL_seekup:
	bsr	DL_HeadIN
	subq	#1,d0
	tst	d0
	bne.s	DL_seekup
	rts

DL_backd0:
	tst	d0
	beq.s	DL_backd0-2
DL_back:bsr	DL_HeadOUT
	subq	#1,d0
	tst	d0
	bne.s	DL_back
	rts

*------------------------------------

DL_Trackuncode:
	movem.l D0-D7/a0-a6,-(A7)
	move	#-1,DL_var
	moveq	#10,D6		;sectors 0 - 10
	move.l	DL_DSKpointer(pc),A0
	move.l	A0,A6
	add.l	#$3300,A6
DL_lp2:	cmp.l	A6,A0
	ble.s	DL_lp1
	movem.l (A7)+,D0-D7/a0-a6
	rts

DL_lp1:	cmp	#$4489,(A0)+	;wait for sync
	bne.s	DL_lp2
	cmp	#$4489,(A0)
	beq.s	DL_lp3
	bra.s	DL_lp4
DL_lp3:	addq.l	#2,A0
DL_lp4:	bsr.s	DL_uncode
	lea	DL_data(PC),A2
	move.b	2(A2),D1
	cmp.b	DL_var(pc),D1
	bne.s	DL_lp6
	addq.l	#8,A0
	bra.s	DL_lp2

DL_lp6:	lea	dl_var(pc),a3
	move.b	D1,(a3)
	and.l	#$ff,D1
	mulu	#$200,D1
	add.l	DL_Loadadr(pc),D1
	move.l	D1,A1
	add.l	#$38,A0
	move.l	A0,A2
	add.l	#$200,A2
	move	#$7f,D0

DL_cp1:	move.l	#$55555555,d3
DL_cp1a:move.l	(A0)+,D1
	move.l	(A2)+,D2
	and.l	d3,d1
	and.l	d3,d2
	asl.l	#1,D1
	or.l	D1,D2
	move.l	D2,(A1)+
	dbf	D0,DL_cp1a
	dbf	D6,DL_lp2
	movem.l (A7)+,d0-d7/a0-a6
	rts

DL_uncode:
	movem.l D0-D7/a0-a6,-(A7)
	moveq	#$0f,D2
	move.l	#$55555555,d3
	lea	DL_data(PC),A1
DL_uncodeLP:
	move.l	(A0)+,D0
	move.l	(A0)+,D1
	and.l	d3,d0
	and.l	d3,d1
	asl.l	#1,D0
	or.l	D0,D1
	move.l	D1,(A1)+
	dbf	D2,DL_uncodeLP
	movem.l (A7)+,D0-D7/a0-a6
	rts

DL_data:	blk.l	20,0
DL_Loadadr:	dc.l	0
DL_DSKpointer:	dc.l	diskbuffer
DL_Uart:	dc.w	0
DL_DSK:		dc.b	%11110111,0
DL_TRKno:	dc.w	0
DL_var:		dc.w	$0600
diskbuffer:	blk.w	$1a00,0


;--------------------------P L A Z M A--------------------------
pl_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
pl_colors:
dc.l	$1820110,$1840220,$1860330,$1880440,$18a0550
dc.l	$18c0660,$18e0770,$1900880,$1920990,$1940aa0,$1960bb0
dc.l	$1980cc0,$19a0dd0,$19c0ee0,$19e0ff0
dc.l	$1a00ff0,$1a20ee0,$1a40dd0,$1a60cc0,$1a80bb0,$1aa0aa0
dc.l	$1ac0990,$1ae0880,$1b00770,$1b20660,$1b40550,$1b60440
dc.l	$1b80330,$1ba0220,$1bc0110,$1be0000

dc.l	$920048,$9400c0,$8e0171,$9037d1
dc.l	$e00007,$e20000,$e40007,$e60000+[pl_height*pl_row]
dc.l	$e80007,$ea0000+[2*pl_height*pl_row],$ec0007,$ee0000+[3*pl_height*pl_row]
dc.l	$f00007,$f20000+[4*pl_height*pl_row]
dc.l	$1020000,$1080000,$10a0000	;bplcon1,modulo1
dc.l	$3001ff00,$9aa000
dc.l	$3801ff00,$9a2000
pl_border:
dc.l	$a001ff00,$18000a0
dc.l	$a101ff00,$1800000
dc.l	$a301ff00,$01005300
dc.l	$a301ff00,$01000300
pl_border2:
dc.l	$a501ff00,$18000a0
dc.l	$a601ff00,$1800000
dc.l	$ffdffffe
pl_scrcol:
dc.l	$1800000,$1820099,$1840055,$1860077,$1880033,$18a00bb,$18c00dd,$18e00ff
dc.l	$920028,$9400d8
dc.l	$e00006,$e20002,$e40006,$e60002+[16*pl_scrow],$e80006,$ea0002+[2*16*pl_scrow]
dc.l	$1080004,$10a0004		;modulo scrolla
pl_shft:
dc.l	$10200ff
dc.l	$0801ff00,$1003300
dc.l	$1801ff00,$1000300
dc.l	$fffffffe

;-------------------------------------------------------------------
pl_height=175
pl_row=32

pl_nomouse:	dc.w	0
pl_isitall:	dc.w	0
pl_conti:	dc.w	0
pl_counter:	dc.w	3000
pl_oldlev:	dc.l	0
pl_plaaddr:	dc.l	plasm1
pl_coladdr:	dc.l	pl_coltab
pl_addval:	dc.w	1

pl_obnum:		dc.w	0
pl_obtab:		dc.l	plasm5,plasm6,plasm3,plasm4,plasm1,plasm2,plasm7,plasm8,plasm9,plasm10,0

pl_clrit:		dc.l	0,0,0,0,0,0,0
pl_point:		dc.w	0
pl_endflag:	dc.w	0
even
;-------------------------------------------------------------------

pl_plasm:
	move	#1,pl_nomouse
	move.l	#$dff000,a0
	move.l	#$ffffffff,$44(a0)
	bsr	pl_crtab
	bsr	pl_clsc
	move	#$4000,$dff09a
	move.l	$6c,pl_oldlev
	move.l	#pl_level3,$6c
	move	#$c000,$dff09a
	lea	pl_clrit,a1
	movem.l	(a1),d0-d7
	bsr	pl_clrscr
	move.l	#pl_copper,$dff080
	clr	$dff088
	bsr	pl_newob
	bsr	pl_ramka
	bsr	pl_draw
pl_control:
	cmpi.b	#$ff,6(a0)
	bne	pl_control
	tst	pl_endflag
	bne	pl_con3
	tst	pl_isitall
	bne	pl_con4
	btst.b	#2,$16(a0)
	bne	pl_con2
	bsr	pl_next
pl_con2:	btst.b	#6,$bfe001
	bne	pl_control
pl_con4:bsr	pl_pull
pl_con3:bsr	pl_clrscr
	move	#15,d0
pl_scout:raster
	raster
	move	#6,d1
	lea	pl_scrcol+6,a1
pl_out1:move	(a1),d2
	beq	pl_out2
	subi	#$11,(a1)
pl_out2:adda.l	#4,a1
	dbf	d1,pl_out1
	dbf	d0,pl_scout
	bsr	pl_ramka2
pl_quit:move	#$4000,$dff09a
	move.l	pl_oldlev,$6c
	move	#$c000,$dff09a
	move	#0,pl_nomouse
	move	#9,d0
pl_rout:raster
	raster
	sub.b	#$10,pl_border+7
	sub.b	#$10,pl_border2+7
	dbf	d0,pl_rout
pppp: bra	pppp
	rts

pl_level3:movem.l d0-d7/a0-a6,-(sp)
	bsr	pl_circle
	bsr	pl_scroll
	btst.b	#2,$dff016
	bne	pl_lev1
	move	#1,pl_conti
pl_lev1:subi	#1,pl_counter
	bne	pl_lev2
	tst	pl_conti
	bne	pl_lev2
	move	#1,pl_isitall
pl_lev2:movem.l	(sp)+,d0-d7/a0-a6
	move	#$20,$dff09c
	rte

pl_clrscr:	btst.b	#14,$2(a0)		;czysc ekrany
	bne	pl_clrscr
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$70000,$54(a0)
	move	#[5*pl_height*64]+[pl_row/2],$58(a0)
	rts

pl_draw:	btst.b	#14,2(a0)		;rysuj plazme
	bne	pl_draw
	move	#[pl_row*8]-1,d4	;x
pl_draw2:move	#pl_height-1,d5		;y
pl_draw3:move.l	pl_plaaddr,a1		;adres danych plazmy
	moveq	#0,d3
	move	(a1)+,d7
pl_draw1:	move	(a1)+,d2
	mulu	#160,d2
	move	(a1)+,d0		;x1
	subi	d4,d0
	mulu	d0,d0
	move	(a1)+,d1		;y1
	subi	d5,d1
	mulu	d1,d1
	addi	d1,d0			;pitagoras
	beq	pl_dr5
	bsr	sqrt			;wyciagnij pierwiastek
	divu	d0,d2
pl_dr5:	addi	d2,d3
	dbf	d7,pl_draw1
	divu	#31,d3			;kolor
	swap	d3
	tst	d3
	bne	pl_dr6
	move	#31,d3			;jesli kolor0 to zmien

pl_dr6:	move	d4,d1
	move	d5,d2
	mulu	#pl_row,d2
	move	d1,d0
	lsr	#3,d1
	andi	#7,d0
	eori	#7,d0
	addi	d1,d2
	lea	$70000,a2
	btst	#0,d3
	beq	pl_pl2
	bset	d0,(a2,d2.w)		;postaw punkt
pl_pl2:	adda.l	#[pl_height*pl_row],a2
	btst	#1,d3
	beq	pl_pl3
	bset	d0,(a2,d2.w)
pl_pl3:	adda.l	#[pl_height*pl_row],a2
	btst	#2,d3
	beq	pl_pl4
	bset	d0,(a2,d2.w)
pl_pl4:	adda.l	#[pl_height*pl_row],a2
	btst	#3,d3
	beq	pl_pl5
	bset	d0,(a2,d2.w)
pl_pl5:	adda.l	#[pl_height*pl_row],a2
	btst	#4,d3
	beq	pl_pl6
	bset	d0,(a2,d2.w)

pl_pl6:	btst.b	#2,$16(a0)		;test myszy
	bne	pl_pl7
	bsr	pl_next1
pl_pl7:	btst.b	#6,$bfe001
	beq	pl_wroc
	tst	pl_isitall
	bne	pl_wroc
pl_nodot:	dbf	d5,pl_draw3
	dbf	d4,pl_draw2
	rts

pl_wroc:move.l	(sp)+,d0
	bra	pl_con4

pl_circle:	move	pl_addval,d1		;cyrkulacja kolorow
	addi	d1,pl_point
	andi	#31,pl_point
	move	pl_point,d2
	lsl	#1,d2
pl_setcol:	move.l	pl_coladdr,a3
	lea	pl_colors+2,a4
	move	#30,d1
pl_cir2:	move	(a3,d2.w),(a4)
	addq	#4,a4
	addi	#2,d2
	andi	#63,d2
	dbf	d1,pl_cir2
	rts

sqrt:	movem.l	d1/d2,-(a7)		;proc. liczenia pierwiastka
	move	d0,d1
	addi	#1,d1
	mulu	#5,d1
sqrt2:	move	d0,d2
	mulu	#100,d2
	divu	d1,d2
	addi	d1,d2
	lsr	#1,d2
	subi	d2,d1
	cmpi	#1,d1
	bls	sqrt3
	move	d2,d1
	bra	sqrt2
sqrt3:	andi.l	#$ffff,d2
	divu	#10,d2
	swap	d2
	cmpi	#5,d2
	bls	sqrt4
	add.l	#$10000,d2
sqrt4:	swap	d2
	move	d2,d0
	movem.l	(a7)+,d1/d2
	rts

pl_ramka:	move	#$a0,d0			;rozjechanie ramki
	move	#$a3,d1
	lea	pl_border,a1
pl_ra2:	cmpi.b	#$ff,6(a0)
	bne	pl_ra2
	bsr	pl_opozn
	subq	#2,d0
	addq	#2,d1
	move	d0,d2
	move	d1,d3
	move.b	d2,(a1)
	addq	#1,d2
	move.b	d2,8(a1)
	addq	#2,d2
	move.b	d2,16(a1)
	move.b	d3,24(a1)
	addq	#2,d3
	move.b	d3,32(a1)
	addq	#1,d3
	move.b	d3,40(a1)
	cmpi	#$4a,d0
	bne	pl_ra2
	rts

pl_ramka2:	move	#$4a,d0			;zjechanie ramki
	move	#$fb,d1
	lea	pl_border,a1
pl_ra3:	cmpi.b	#$ff,6(a0)
	bne	pl_ra3
	bsr	pl_opozn
	addq	#2,d0
	subq	#2,d1
	move	d0,d2
	move	d1,d3
	move.b	d2,(a1)
	addq	#1,d2
	move.b	d2,8(a1)
	addq	#2,d2
	move.b	d2,16(a1)
	move.b	d3,24(a1)
	addq	#2,d3
	move.b	d3,32(a1)
	addq	#1,d3
	move.b	d3,40(a1)
	cmpi	#$a0,d0
	bne	pl_ra3
	rts

pl_opozn:	move.l	d0,-(a7)		;petla opozniajaca
	move	#150,d0
pl_opo1:	nop
	dbf	d0,pl_opo1
	move.l	(a7)+,d0
	rts

pl_pull:	move	#$4d,d0			;sciagnij obrazek w dol
pl_pu1:	cmpi.b	#$ff,6(a0)
	bne	pl_pu1
	addi	#3,d0
	move.b	d0,pl_border+16
	bsr	pl_opozn
	cmpi	#$fb,d0
	bne	pl_pu1
	rts

pl_next1:	move.l	(sp)+,d0		;zmiana plazmy
pl_next:	bsr	pl_pull
	bsr	pl_clrscr	
	bsr	pl_newob
	move.b	#$4d,pl_border+16
	tst	pl_endflag
	bne	pl_con3
	bsr	pl_draw
	rts

pl_newob:	move	pl_obnum,d0		;nowa plazma
	lsl	#2,d0
	lea	pl_obtab,a1
	move.l	(a1,d0.w),a1
	cmpa.l	#0,a1
	beq	pl_endit
	move.l	(a1)+,pl_coladdr
	move	(a1)+,pl_addval
	move.l	a1,pl_plaaddr
	addi	#1,pl_obnum
	clr	pl_point
	clr.l	d2
	bsr	pl_setcol
	rts
pl_endit:st	pl_endflag			;koniec obiektow
	rts

;--------------------------scroll-------------------------
pl_scrow=50
pl_scroll:
	subi	#$44,pl_shft+2
	move	pl_shft+2,d0
	and	#$100,d0
	bne	pl_wstaw
	rts
pl_wstaw:
	move	#$ff,pl_shft+2
pl_wblt:btst.b	#14,$dff002		;przesun
	bne	pl_wblt
	clr.l	$64(a0)
	move.l	#$9f00000,$dff040
	move.l	#$60002,$dff050
	move.l	#$60000,$dff054
	move	#[3*16*64]+[pl_scrow/2],$dff058

pl_f0:	move.l	pl_txtpointer,a2
	moveq	#0,d0
	move.b	(a2),d0
	bne	pl_f1
	move.l	#pl_text,pl_txtpointer
	bra	pl_f0
pl_f1:	add.l	#1,pl_txtpointer
	lea	pl_fntable,a1
	moveq	#0,d1
pl_find:move.b	(a1,d1.w),d2
	cmp.b	d2,d0		;znajdz znak w tabeli
	beq	pl_f2
	addi	#1,d1
	cmpi	#60,d1
	bne	pl_find
	move	#0,d1
pl_f2:	lsl	#1,d1		;offset fonta w d1
	lea	pl_foffs,a1
	move	(a1,d1.w),d1	;offset z tablicy fontow
	lea	pl_fonts,a1
	lea	$60000+[pl_scrow-2],a2

	move	#2,d3
pl_copy:move.l	d1,d2
	add.l	a1,d2		;d2-adres fonta
	bsr	pl_bltc
	adda.l	#[16*pl_scrow],a2
	adda.l	#[30*64],a1
	dbf	d3,pl_copy
	rts

pl_bltc:btst.b	#14,$dff002		;przesun
	bne	pl_bltc
	move	#28,$64(a0)
	move	#[pl_scrow-2],$66(a0)
	move.l	#$9f00000,$dff040
	move.l	d2,$dff050
	move.l	a2,$dff054
	move	#[16*64]+1,$dff058
	rts

pl_clsc:btst.b	#14,$2(a0)
	bne	pl_clsc
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$60000,$54(a0)
	move	#[3*16*64]+[pl_scrow/2],$58(a0)
	rts

pl_crtab:
	moveq	#0,d1
	lea	pl_foffs,a1
pl_cr1:	move	#14,d2
	moveq	#0,d0
pl_cr2:	move	d1,d3
	mulu	#480,d3
	addi	d0,d3
	move	d3,(a1)+
	addi	#2,d0
	dbf	d2,pl_cr2
	addi	#1,d1
	cmpi	#4,d1
	bne	pl_cr1
	rts

pl_foffs:	blk.w	61,0
pl_txtpointer:	dc.l	pl_text
pl_fntable:	dc.b"ABCDEFGHIJKLMNOWXYZ1234567890P"
		dc.b",/;V.:-!?QRSTU aceloszx",13
		dc.b"      "

pl_text:dc.b"       TAK TAK TO JA ZNOWU JA, NO ILE CZASU MOzNA ROBIc TO SAMO /////// ??!!! ... TEST LITER: a c e o z x l s  , / : ; - V  1234567890       ",0

;---------------------------OBIEKTY----------------------------------

plasm1:
dc.l	pl_coltab3		;adres tablicy kolorow 
dc.w	1		;szybkosc
dc.w	1		;ilosc ladunkow-1
dc.w	100,70,50	;ich wartosci ladunkow i polozenia x,y
dc.w	30,150,120

pl_coltab:
dc.w	$110,$220,$330,$440,$550,$660,$770,$880,$990,$aa0,$bb0,$cc0,$dd0,$ee0,$ff0,$ff0
dc.w	$ff0,$ee0,$dd0,$cc0,$bb0,$aa0,$990,$880,$770,$660,$550,$440,$330,$220,$110,0
pl_coltab2:
dc.w	$88,$99,$aa,$bb,$cc,$dd,$ee,$ff,$ff,$ee,$dd,$cc,$bb,$aa,$99,$88
dc.w	$838,$939,$a3a,$b3b,$c3c,$d3d,$e3e,$f3f,$f3f,$e3e,$d3d,$c3c,$b3b,$a3a,$939,$838
pl_coltab3:
dc.w	$a1f,$a2f,$a3f,$a4f,$a5f,$a6f,$a7f,$a8f,$a9f,$aaf,$abf,$acf,$adf,$aef,$aff,$aff
dc.w	$af1,$ae1,$ad1,$ac1,$ab1,$aa1,$a91,$a81,$a71,$a61,$a51,$a41,$a31,$a21,$a11,$a11


plasm2:
dc.l	pl_coltab
dc.w	-1,0
dc.w	80,150,100

plasm3:
dc.l	pl_coltab
dc.w	1,4
dc.w	10,40,60
dc.w	20,100,90
dc.w	50,200,150
dc.w	5,150,40
dc.w	10,70,120

plasm4:
dc.l	pl_coltab2
dc.w	-1,1
dc.w	16,90,150
dc.w	2,130,40

plasm5:
dc.l	pl_coltab
dc.w	-1,2
dc.w	40,90,60
dc.w	60,180,80
dc.w	2,135,120

plasm6:
dc.l	pl_coltab3
dc.w	1,1
dc.w	3,80,60
dc.w	5,160,120

plasm7:
dc.l	pl_coltab2
dc.w	-1,2
dc.w	30,180,60
dc.w	5,100,10
dc.w	80,80,150

plasm8:
dc.l	pl_coltab3
dc.w	1,4
dc.w	90,180,60
dc.w	50,100,10
dc.w	100,180,30
dc.w	10,40,40
dc.w	5,70,140

plasm9:
dc.l	pl_coltab
dc.w	1,2
dc.w	120,50,40
dc.w	60,130,80
dc.w	30,50,100

plasm10:
dc.l	pl_coltab3
dc.w	-1,3
dc.w	150,180,60
dc.w	170,50,10
dc.w	100,160,150
dc.w	70,90,120

;*********************************************************************

mt_data=$30000
>extern	"df0:.store/mod.exorcist.pro",mt_data,-1

logos=$58000
>extern	"df0:.store/suspect_logo.raw",logos,-1
tp_fonts=$57a00
>extern	"df0:.store/kane.fnt",tp_fonts,-1
qu_rysunek=$53000
>extern	"df0:.store/kula_pic.raw",qu_rysunek,-1
pl_fonts=$50000
>extern	"df0:.store/ohm_font.raw",pl_fonts,-1

;>extern "df0:.store/ball_anim.raw",$5b000,-1

end:
