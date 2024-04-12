;		*****************************************	
;		*	Immortal Visions 2D intro	*
;		*    ------------------------------	*
;		*					*
;		*  Coding on 22.05.1992 to 31.05.1992	*
;		*	  by  KANE  of SUSPECT		*
;		*****************************************

org $20000
load $20000

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
	move.b	#$71,$bfd400
	move.b	#$37,$bfd500	;timer na $3782(80) - ok. 1 frame
	move.b	#$81,$bfdd00
	move.l	$78,oldlev
	move.l	#newlev,$78
;beam:	move.l	$dff004,d0
;	and.l	#$1ff00,d0
;	lsr.l	#8,d0
;	cmpi	#$88,d0
;	bne	beam
	move.b	#$11,$bfde00	;start timer at line $d0
	move	#$e000,$dff09a
	move	#%1000011111110000,$dff096

	bsr	setup

quit:	move.l	4,a6
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
	jmp	(a0)		;jak mowi Pillar 'fajrant'

newlev:	movem.l	d0-d7/a0-a6,-(sp)
	move.b	$bfdd00,d0
	bsr	mt_music
	movem.l	(sp)+,d0-d7/a0-a6
	btst	#6,$bfe001
	bne	nopress
	move	(sp)+,storee
	move.l	(sp)+,adress
	move.l	#quit,-(sp)
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

copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1

dc.l	$1800000,$18200f0,$18400d0,$18600f0,$18800b0,$18a00f0,$18c00d0,$18e00f0
dc.l	$1900090,$19200f0,$19400d0,$19600f0,$19800b0,$19a00f0,$19c00d0,$19e00f0
dc.l	$1a00070,$1a200f0,$1a400d0,$1a600f0,$1a800b0,$1aa00f0,$1ac00d0,$1ae00f0
dc.l	$1b00090,$1b200f0,$1b400d0,$1b600f0,$1b800b0,$1ba00f0,$1bc00d0,$1be00f0
screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$ec0007,$ee0000,$f00007,$f20000
dc.l	$1020000,$1080000,$10a0000
scrcol:
dc.l	$2c01ff00,$01005300
dc.l	$8001ff00,$9aa000
dc.l	$9001ff00,$9a2000
dc.l	$ffdffffe
dc.l	$2c01ff00,$01000300
dc.l	$fffffffe

;-------------------------------------------------------------------
scrarea=$6a000
scron:		dc.l	0
scroff:		dc.l	0
scrpnt:		dc.w	0

heith=256
row=40

ubor:	dc.w	0		;ramka,w ktorej ma byc zawarty obraz
dbor:	dc.w	255
lbor:	dc.w	1
rbor:	dc.w	319

zoomob=5000			;zooming wstepny obiektow
zoom=1000			;zooming perspektywiczny calosci

firstp:	dc.w	0

prpnt:	dc.w	0
lepnt:	dc.w	0
prtab:	blk.l	50,0
letab:	blk.l	50,0
matrix:	blk.l	100,0
;-------------------------------------------------------------------

setup:
	lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
clear:	btst.b	#14,$2(a0)
	bne	clear
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#scrarea,$54(a0)
	move	#[3*heith*64]+[row],$58(a0)
	bsr	chgscr
clears:	btst.b	#14,$2(a0)
	bne	clears
	move.l	#copper,$dff080
	clr	$dff088
	lea	suspect,a6		;tu nazwe
	bsr	speed
control:
	cmpi.b	#$ff,$dff006	;oddal
	bne	control
	cmpi	#970,4(a6)
	bpl	con2
	addi	#2,4(a6)
con2:	cmpi	#150,(a6)
	bmi	con3
	subi	#7,(a6)
	bsr	chgscr
	bsr	vector
	bra	control

con3:	addi	#6,16(a6)
	move	#6,10(a6)
contr2	cmpi.b	#$ff,$dff006	;przekrec i zblizaj
	bne	contr2
	move	16(a6),d0
	andi	#$1fe,d0
	cmpi	#126,d0
	beq	con5
	subi	#6,4(a6)
	bsr	chgscr
	bsr	vector
	bra	contr2

con5:	clr	10(a6)
contr3	cmpi.b	#$ff,$dff006	;calkiem zbliz
	bne	contr3
	subi	#15,4(a6)
	cmpi	#100,4(a6)
	bmi	con6
	bsr	chgscr
	bsr	vector
	bra	contr3

con6:	bra	pi_show


chgscr:	btst.b	#14,$2(a0)
	bne	chgscr
	move	scrpnt,d0
	bpl	chg2
	move	#5,scrpnt
	moveq	#5,d0
chg2:	move	#4,d1
	lea	screen+2,a1
chg3:	move	d0,d2
	mulu	#[row*heith],d2
	add.l	#scrarea,d2
	move	d2,4(a1)
	swap	d2
	move	d2,(a1)
	addq	#8,a1
	addq	#1,d0
	cmpi	#6,d0
	bne	chg4
	clr	d0
chg4:	dbf	d1,chg3
	mulu	#[row*heith],d0
	add.l	#scrarea,d0
	move.l	d0,scroff
	subi	#1,scrpnt

	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[heith*64]+[row/2],$58(a0)
	rts

vector:	move	20(a6),d7		;ilosc plaszczyzn
	lea	matrix,a4
	move.l	26(a6),a3		;tab plaszczyzn
obr2:	move	(a3)+,d6
	subi	#2,d6
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
	dbf	d7,obr2

fill:	btst.b	#14,$2(a0)
	bne	fill
	clr.l	$64(a0)
	move.l	#$09f00012,$40(a0)
	move.l	scroff,d4
	add.l	#[heith*row]-2,d4
	move.l	d4,$54(a0)
	move.l	d4,$50(a0)
	move	#[heith*64]+[row/2],$58(a0)

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
	move	18(a6),d6		;ilosc punktow
twodim:	move	4(a2),d1
	move	(a2),d2		;zxy
	move	16(a6),d0
	bsr	rotate
	move	d2,d3
	move	2(a2),d2	;zyx
	neg	d2
	move	14(a6),d0
	bsr	rotate
	exg	d1,d3		;xyz
	move	12(a6),d0
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
prdory:
	lea	prtab,a2
	move	prpnt,d5
	move	rbor,(a2,d5.w)
	move	d4,2(a2,d5.w)
	addi	#4,d5
	move	d5,prpnt
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
ldorys:
	lea	letab,a2
	move	lepnt,d5
	move	lbor,(a2,d5.w)
	move	d4,2(a2,d5.w)
	addi	#4,d5
	move	d5,lepnt
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
	movem.l	d0-d7,-(sp)	;rys.linie
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
	add.l	scroff,d3		;rastport
	move.l	d7,$40(a0)
	move	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move	#$ffff,$72(a0)
	move	d0,$58(a0)
	movem.l	(a7)+,d0-d7
noline:	rts

rotate:	andi.l	#$1fe,d0	;obroc punkty
	cmpi	#128,d0
	beq	rot2
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
rot2:	rts	

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

suspect:
dc.w	680,120,820
dc.w	0,0,0
dc.w	128,128,128
dc.w	69,7
dc.l	sudots,supla
sudots:
dc.w	-1500,800,0,-2000,800,0
dc.w	-2000,-200,0,-1600,-200,0
dc.w	-1600,-400,0,-2000,-400,0
dc.w	-2000,-800,0,-1500,-800,0
dc.w	-1500,200,0,-1900,200,0
dc.w	-1900,400,0,-1500,400,0

dc.w	-1400,800,0,-1400,-800,0
dc.w	-900,-800,0,-900,800,0
dc.w	-1000,800,0,-1000,-400,0
dc.w	-1300,-400,0,-1300,800,0

dc.w	-300,800,0,-800,800,0
dc.w	-800,-200,0,-400,-200,0
dc.w	-400,-400,0,-800,-400,0
dc.w	-800,-800,0,-300,-800,0
dc.w	-300,200,0,-700,200,0
dc.w	-700,400,0,-300,400,0

dc.w	300,800,0,-200,800,0
dc.w	-200,-800,0,-100,-800,0
dc.w	-100,-200,0,300,-200,0
dc.w	200,200,0,200,400,0,-100,400,0,-100,200,0

dc.w	900,800,0,400,800,0,400,-800,0,900,-800,0
dc.w	900,-400,0,500,-400,0,500,-200,0,800,-200,0
dc.w	800,200,0,500,200,0,500,400,0,900,400,0

dc.w	1500,800,0,1000,800,0,1000,-800,0,1500,-800,0
dc.w	1500,-400,0,1100,-400,0,1100,400,0,1500,400,0

dc.w	2100,800,0,1600,800,0,1600,400,0,1800,400,0
dc.w	1800,-800,0,1900,-800,0,1900,400,0,2100,400,0

supla:
dc.w	12,0,1,2,3,4,5,6,7,8,9,10,11
dc.w	8,12,13,14,15,16,17,18,19
dc.w	12,20,21,22,23,24,25,26,27,28,29,30,31
dc.w	6,32,33,34,35,36,37,   4,38,39,40,41
dc.w	12,42,43,44,45,46,47,48,49,50,51,52,53
dc.w	8,54,55,56,57,58,59,60,61
dc.w	8,62,63,64,65,66,67,68,69


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

;--------------------------------------------------------------
pi_heigth=173		;(640/323)
pi_row=40

pi_show:
	lea	presents,a6
	bsr	speed
	move.l	#scrarea,scroff
	move.l	#scrarea+[heith*row],scron
waiit1:	cmpi.b	#$ff,6(a0)
	bne	waiit1
	bsr	chgscr2
	bsr	vector
waiit2:	cmpi.b	#$ff,6(a0)
	bne	waiit2
	bsr	chgscr2
	bsr	vector

	move	#3,d0
	lea	pi_screen,a1
	move.l	scron,d1
	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	addq	#8,a1
	move.l	#obrazek,d1
setscr:	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[pi_heigth*pi_row],d1
	addq	#8,a1
	dbf	d0,setscr

	move	#15,d0
	lea	pi_colors+4,a1
scollo:	move	#$f0,2(a1)
	addi	#8,a1
	dbf	d0,scollo
	move	#15,d0
	lea	pi_colors,a1
	lea	obrazek+[4*pi_heigth*pi_row],a2
scol:	move	(a2)+,2(a1)
	addi	#8,a1
	dbf	d0,scol

	move.l	#copper2,$dff080
	clr	$dff088

;^^^^^^^^^^^^^^^^Animacja 'presents'^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

waiit3:	cmpi.b	#$ff,6(a0)
	bne	waiit3
	addi	#25,4(a6)
	addi	#3,(a6)
	subi	#1,2(a6)
	bsr	chgscr2
	bsr	vector
	cmpi	#965,4(a6)
	bne	waiit3

	move	#8,6(a6)
waiit4:	cmpi.b	#$ff,6(a0)
	bne	waiit4
	subi	#2,4(a6)
	addi	#1,2(a6)
	bsr	chgscr2
	bsr	vector
	cmpi	#895,4(a6)
	bne	waiit4

	move	#8,10(a6)
	addi	#48,16(a6)
waiit5:	cmpi.b	#$ff,6(a0)
	bne	waiit5
	addi	#1,2(a6)
	subi	#1,4(a6)
	bsr	chgscr2
	bsr	vector
	cmpi	#118,2(a6)
	bne	waiit5

	move	#4,10(a6)
	move	#10,6(a6)
waiit6:	cmpi.b	#$ff,6(a0)
	bne	waiit6
	cmpi	#200,2(a6)
	beq	wai61
	addi	#2,2(a6)
wai61:	addi	#2,4(a6)
	cmpi	#926,4(a6)
	bmi	wait63
	clr	10(a6)
	addi	#1,(a6)
wait63	cmpi	#930,4(a6)
	bmi	wait62
	move	#11,6(a6)
wait62:	bsr	chgscr2
	bsr	vector
	cmpi	#936,4(a6)
	bne	waiit6

waiit7:	cmpi.b	#$ff,6(a0)
	bne	waiit7
	clr	6(a6)
	clr	10(a6)
	move	#128,12(a6)
	move	#128,16(a6)
	bsr	chgscr2
	bsr	vector
waiit71:cmpi.b	#$ff,6(a0)
	bne	waiit71
	bsr	chgscr2
	bsr	vector
waiit72:cmpi.b	#$ff,6(a0)
	bne	waiit72
	bsr	chgscr2

	move	#$ee00,d1
dalej0:	move	#8,d0
dalej:	muls	d2,d2
	dbf	d0,dalej
	dbf	d1,dalej0

	move	#15,d0
fadcol:	lea	pi_colors,a1
	move	#31,d3
fad1:	move	2(a1),d1
	andi	#$f,d1
	eori	#$f,d1
	beq	fad2
	addi	#1,2(a1)
fad2:	move	2(a1),d1
	andi	#$f0,d1
	eori	#$f0,d1
	beq	fad3
	addi	#$10,2(a1)
fad3:	move	2(a1),d1
	andi	#$f00,d1
	eori	#$f00,d1
	beq	fad4
	addi	#$100,2(a1)
fad4:	adda	#4,a1
	dbf	d3,fad1
	move	#$800,d3
wait5:	muls	d1,d1
	dbf	d3,wait5
	dbf	d0,fadcol

;--------------tu wchodzi I.V logos------------------------

lo_heigth=202
lo_row=40

 	move	#2,d0
	lea	lo_screen,a1
	move.l	#logos,d1
lo_set:	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[lo_heigth*lo_row],d1
	addq	#8,a1
	dbf	d0,lo_set

	move	#7,d0
	lea	lo_colors,a1
lo_col:	move	#$fff,2(a1)
	addi	#4,a1
	dbf	d0,lo_col

	move.l	#lo_copper,$dff080
	clr	$dff088

	move	#15,d0
lo_fad:	lea	lo_colors,a1
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
lo_fad4:adda	#4,a1
	adda	#2,a2
	dbf	d3,lo_fad1
	move	#$1a00,d3
lo_wait:muls	d1,d1
	dbf	d3,lo_wait
	dbf	d0,lo_fad

	move	#350,d0
finally:cmpi.b	#$fe,6(a0)
	bne	finally
final2:	cmpi.b	#$ff,6(a0)
	bne	final2
	dbf	d0,finally

	move	#15,d0
fi_fad:	lea	lo_colors,a1
	move	#7,d3
fi_fad1:move	2(a1),d1
	andi	#$f,d1
	beq	fi_fad2
	subi	#1,2(a1)
fi_fad2:move	2(a1),d1
	andi	#$f0,d1
	beq	fi_fad3
	subi	#$10,2(a1)
fi_fad3:move	2(a1),d1
	andi	#$f00,d1
	beq	fi_fad4
	subi	#$100,2(a1)
fi_fad4:adda	#4,a1
	dbf	d3,fi_fad1
	move	#$1a00,d3
fi_wait:muls	d1,d1
	dbf	d3,fi_wait
	dbf	d0,fi_fad
	rts

chgscr2:btst.b	#14,$2(a0)
	bne	chgscr2
	move.l	scron,d0
	move.l	scroff,d1
	move.l	d1,scron
	move.l	d0,scroff
	lea	pi_screen,a1
	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[heith*64]+[row/2],$58(a0)
	rts

copper2:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
pi_colors:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
dc.l	$1900000,$1920000,$1940000,$1960000
dc.l	$1980000,$19a0000,$19c0000,$19e0000
dc.l	$1a00000,$1a20000,$1a40000,$1a60000
dc.l	$1a80000,$1aa0000,$1ac0000,$1ae0000
dc.l	$1b00000,$1b20000,$1b40000,$1b60000
dc.l	$1b80000,$1ba0000,$1bc0000,$1be0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
pi_screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000,$ec0007,$ee0000,$f00007,$f20000
dc.l	$1020000
dc.l	$1080000,$10a0000
dc.l	$2c01ff00,$01001300
dc.l	$3801ff00,$01005300
dc.l	$8001ff00,$9aa000
dc.l	$9001ff00,$9a2000
dc.l	$e501ff00,$01001300
dc.l	$ffdffffe
dc.l	$2c01ff00,$01000300
dc.l	$fffffffe


lo_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
lo_colors:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
lo_screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$1020000
dc.l	$1080000,$10a0000
dc.l	$4001ff00,$01003300
dc.l	$8001ff00,$9aa000
dc.l	$9001ff00,$9a2000
dc.l	$ffdffffe
dc.l	$0a01ff00,$01000300
dc.l	$fffffffe


presents:
dc.w	-70,120,-985
dc.w	0,0,0
dc.w	128,128,128
dc.w	89,9			;liczba lini -1,liczba plaszczyzn -1
dc.l	prdots,prpla
prdots:
dc.w	-1600,200,0,-2040,200,0
dc.w	-2040,-200,0,-1880,-200,0,-1880,-80,0
dc.w	-1600,-80,0, -1720,160,0
dc.w	-1880,160,0,-1880,0,0
dc.w	-1720,0,0

dc.w	-1080,200,0,-1520,200,0	
dc.w	-1520,-200,0,-1360,-200,0
dc.w	-1360,-80,0,-1320,-80,0
dc.w	-1200,-200,0,-1080,-200,0
dc.w	-1200,-80,0,-1080,-80,0
dc.w	-1200,160,0,-1360,160,0
dc.w	-1360,0,0,-1200,0,0

dc.w	-560,200,0,-1000,200,0	
dc.w	-1000,-200,0,-560,-200,0
dc.w	-560,-120,0,-840,-120,0
dc.w	-840,-40,0,-720,-40,0
dc.w	-720,40,0,-840,40,0
dc.w	-840,120,0,-560,120,0

dc.w	-40,200,0,-480,200,0	
dc.w	-480,-40,0,-200,-40,0
dc.w	-200,-120,0,-480,-120,0
dc.w	-480,-200,0,-40,-200,0
dc.w	-40,40,0,-320,40,0
dc.w	-320,120,0,-40,120,0

dc.w	480,200,0,40,200,0	
dc.w	40,-200,0,480,-200,0
dc.w	480,-120,0,200,-120,0
dc.w	200,-40,0,280,-40,0
dc.w	280,40,0,200,40,0
dc.w	200,120,0,480,120,0

dc.w	1000,200,0,880,200,0		
dc.w	880,-40,0,720,200,0
dc.w	560,200,0,560,-200,0
dc.w	720,-200,0,720,0,0
dc.w	880,-200,0,1000,-200,0

dc.w	1520,200,0,1080,200,0	
dc.w	1080,120,0,1240,120,0
dc.w	1240,-200,0,1360,-200,0
dc.w	1360,120,0,1520,120,0

dc.w	2040,200,0,1600,200,0	
dc.w	1600,-40,0,1880,-40,0
dc.w	1880,-120,0,1600,-120,0
dc.w	1600,-200,0,2040,-200,0
dc.w	2040,40,0,1760,40,0
dc.w	1760,120,0,2040,120,0

prpla:
dc.w	6,0,1,2,3,4,5, 4,6,7,8,9
dc.w	10,10,11,12,13,14,15,16,17,18,19, 4,20,21,22,23
dc.w	12,24,25,26,27,28,29,30,31,32,33,34,35
dc.w	12,36,37,38,39,40,41,42,43,44,45,46,47
dc.w	12,48,49,50,51,52,53,54,55,56,57,58,59
dc.w	10,60,61,62,63,64,65,66,67,68,69
dc.w	8,70,71,72,73,74,75,76,77
dc.w	12,78,79,80,81,82,83,84,85,86,87,88,89

mt_data=$30000
obrazek=$60000
logos=$58000
>extern	"df0:.store/mod.intro-exorcist.pro",mt_data,-1
>extern	"df0:.store/vampire.raw",obrazek,-1
>extern	"df0:.store/immortal.raw",logos,-1

end:
