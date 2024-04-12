;Suspect Immortal Visions loader coded by Kane and Pillar

>extern	"df0:suspectMd.pack",obrazekspak,-1

obrazek=$60000
obrazekspak=$59000
dlug=21568

heigth=323		;(640/323)
row=80

org	$f000
load	$f000

q:
dc.b	'DOS',0
dc.l	0
dc.l	880

s:	lea	start(pc),a2
	lea	start,a3
	move	#$ff,d0
copy:	move.l	(a2)+,(a3)+
	dbf	d0,copy
	jmp	start
start:
	move	#$8290,$dff096
	move.l	#$20000+$400,d0		;zaladuj
	move.l	#2*512,d1
	move.l	#2*512,d2		;1 kb
;	bsr	load

	bset	#15,$dff02a
	lea	copper,a1
	move.l	a1,$dff080
fade:	move	#$f00,d0
fade2:	muls	d1,d1
	dbf	d0,fade2
	subi	#$111,2(a1)
	bne	fade

	move.l	#obrazekspak,d0		;zaladuj
	move.l	#44,d1
	move.l	#4,d2		;ok 22 kb
	bsr	tr_load

	lea	obrazekspak,a0		;zdepakuj logos - start
	move.l	#dlug,d0		;dlugosc
	lea	obrazek,a1		;destination
	bsr	decrunch


coppry:	move.l	#copper2,d0
	move.l	#copper3,d1
	move	d1,cop2+6
	swap	d1
	move	d1,cop2+2
	move	d0,cop3+6
	swap	d0
	move	d0,cop3+2

	move	#3,d0
	lea	screen,a1
	lea	screen3,a2
	move.l	#obrazek,d1
setscr:	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#80,d1
	move	d1,6(a2)
	swap	d1
	move	d1,2(a2)
	swap	d1
	add.l	#[heigth*row]-80,d1
	addq	#8,a1
	addq	#8,a2
	dbf	d0,setscr

wait1:	btst	#15,$dff004		;czy long frame? (1)
	beq	wait1
	move.l	#copper2,$dff080
	clr	$dff088

	move	#15,d0
setcol:	lea	colors,a1
	lea	colors3,a3
	lea	obrazek+[4*heigth*row],a2
	move	#15,d3
scol1:	move	(a2),d1
	andi	#$f,d1
	move	2(a1),d2
	andi	#$f,d2
	cmpi	d1,d2
	beq	scol2
	addi	#1,2(a1)
	addi	#1,2(a3)
scol2:	move	(a2),d1
	andi	#$f0,d1
	move	2(a1),d2
	andi	#$f0,d2
	cmpi	d1,d2
	beq	scol3
	addi	#$10,2(a1)
	addi	#$10,2(a3)
scol3:	move	(a2)+,d1
	andi	#$f00,d1
	move	2(a1),d2
	andi	#$f00,d2
	cmpi	d1,d2
	beq	scol4
	addi	#$100,2(a1)
	addi	#$100,2(a3)
scol4:	adda	#4,a1
	adda	#4,a3
	dbf	d3,scol1
	move	#$1900,d3
waitt:	muls	d1,d1
	dbf	d3,waitt
	dbf	d0,setcol

	move.l	#$30000,d0
	move.l	#48*512,d1
	move.l	#6*512,d2	;ok 3 kb
;	bsr	load

mouse:	btst	#6,$bfe001		;to potem wywalic
	bne	mouse

	move	#15,d0
fadcol:	lea	colors,a1
	lea	colors3,a3
	move	#15,d3
fad1:	move	2(a1),d1
	andi	#$f,d1
	beq	fad2
	subi	#1,2(a1)
	subi	#1,2(a3)
fad2:	move	2(a1),d1
	andi	#$f0,d1
	beq	fad3
	subi	#$10,2(a1)
	subi	#$10,2(a3)
fad3:	move	2(a1),d1
	andi	#$f00,d1
	beq	fad4
	subi	#$100,2(a1)
	subi	#$100,2(a3)
fad4:	adda	#4,a1
	adda	#4,a3
	dbf	d3,fad1
	move	#$1900,d3
wait5:	muls	d1,d1
	dbf	d3,wait5
	dbf	d0,fadcol

move.l	4,a6
lea	gfxname,a1
jsr	-552(a6)
move.l	d0,a0
move.l	$32(a0),$dff080
clr	$dff088
rts

tr_load:
rts
	lea	tr_skok(pc),a5
	move	#$4000,$dff09a
	move.l	$6c,6(a5)	;oldlevel
	move.l 	$6c,2(a5)
	lea	tr_newlev(pc),a4
	move.l	a4,$6c
	move	#$c000,$dff09a	

	lsl.l	#8,d2
	lsl.l	#1,d2		;*512
	move.l	d1,d3
	lsl.l	#8,d1
	lsl.l	#1,d1		;*512
	movem.l	d0-d2,-(a7)
	muls	#50,d3
	divs	#30,d3
	addi	#50,d3		;policz czas

	move	d3,10(a5)	;licznik
	move.l	4,a6
	lea	tr_diskio(pc),a1
	lea	tr_trackname(pc),a0
	clr.l	d0
	clr.l	d1
	jsr	-444(a6)
	movem.l	(a7)+,d0-d2
	move.l	4,a6
	move.w	#2,$1c(a1)
	move.l	d0,40(a1)	;bufor
	move.l	d1,36(a1)	;dlugosc
	move.l	d2,44(a1)	;offset
	jsr	-462(a6)	;sendio

	lea	tr_skok(pc),a5
	move	#1,12(a5)	;zainicjuj licznik
tr_wait:tst.w	10(a5)
	bne	tr_wait
	clr	12(a5)		;zakoncz liczenie
	move	#$4000,$dff09a
	move.l	tr_oldlev(pc),$6c
	move	#$c000,$dff09a	
	move.l	4,a6
	lea	tr_diskio(pc),a1
	move	#9,28(a1)
	clr.l	36(a1)
	jsr	-462(a6)	;wylacz diode
	rts

tr_newlev:btst	#5,$dff01f
	beq	tr_skok
	tst.w	12(a5)
	beq	tr_skok
	subi 	#1,10(a5)
tr_skok:jmp	0
tr_oldlev:	dc.l	0,0
tr_trackname:	dc.b "trackdisk.device",0,0
tr_diskio:	blk.l 20,0

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


gfxname:
dc.b	'graphics.library',0,0
readrep:blk.l	8,0
track:	dc.l	0
copper:	dc.l	$1800fff,$fffffffe
copper2:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
colors:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
dc.l	$1900000,$1920000,$1940000,$1960000
dc.l	$1980000,$19a0000,$19c0000,$19e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000,$ec0007,$ee0000
dc.l	$1020000
dc.l	$1080050,$10a0050
dc.l	$4801ff00,$0100c304
dc.l	$e901ff00,$01000304
cop2:
dc.l	$800000,$820000
dc.l	$fffffffe

copper3:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
colors3:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
dc.l	$1900000,$1920000,$1940000,$1960000
dc.l	$1980000,$19a0000,$19c0000,$19e0000
dc.l	$920038,$9400d0,$8e0171,$9037d1
screen3:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000,$ec0007,$ee0000
dc.l	$1020000
dc.l	$1080050,$10a0050
dc.l	$4801ff00,$0100c304
dc.l	$e901ff00,$01000304
cop3:
dc.l	$800000,$820000
dc.l	$fffffffe

end:
