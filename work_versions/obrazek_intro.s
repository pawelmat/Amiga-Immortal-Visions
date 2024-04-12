;Suspect Immortal Visions loader coded by Kane and Pillar

>extern	"df0:face1",obrazek,-1

obrazek=$60000

heigth=173		;(640/323)
row=40

org	$f000
load	$f000

s:
	move	#3,d0
	lea	screen,a1
	move.l	#obrazek,d1
setscr:	move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[heigth*row],d1
	addq	#8,a1
	dbf	d0,setscr

	move.l	#copper2,$dff080
	clr	$dff088

	move	#15,d0
	lea	colors,a1
	lea	obrazek+[4*heigth*row],a2
scol:	move	(a2)+,2(a1)
	addi	#4,a1
	dbf	d0,scol


mouse:	btst	#6,$bfe001		;to potem wywalic
	bne	mouse

	move	#15,d0
fadcol:	lea	colors,a1
	move	#15,d3
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
	move	#$700,d3
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


gfxname:
dc.b	'graphics.library',0,0
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
dc.l	$1080000,$10a0000
dc.l	$3801ff00,$01004300
dc.l	$e501ff00,$01000300
dc.l	$fffffffe

end:
