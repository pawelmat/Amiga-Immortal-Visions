;Suspect Immortal Visions Animation Replayer coded by Kane

org	$20000
load	$20000

obrazek=$22000

>extern	"df0:sus1",obrazek,-1
>extern	"df0:sus2",obrazek+[12864],-1
>extern	"df0:sus3",obrazek+[2*12800],-1
>extern	"df0:sus4",obrazek+[3*12800],-1
>extern	"df0:sus5",obrazek+[4*12800],-1
>extern	"df0:sus6",obrazek+[5*12800],-1
>extern	"df0:sus7",obrazek+[6*12800],-1
>extern	"df0:sus8",obrazek+[7*12800],-1
>extern	"df0:sus9",obrazek+[8*12800],-1
>extern	"df0:sus10",obrazek+[9*12800],-1

obrpnt:		dc.w	0
obrtab:
dc.l	obrazek,obrazek+[12864],obrazek+[2*12800],obrazek+[3*12800]
dc.l	obrazek+[4*12800],obrazek+[5*12800],obrazek+[6*12800]
dc.l	obrazek+[7*12800],obrazek+[8*12800],obrazek+[9*12800],0

heigth=128
row=20

s:	
	move.l	#obrazek,d1
	bsr	setaddr
	move.l	#copper,$dff080
	clr	$dff088
	bsr	colin

show:	move	#6,d0
show1:	cmpi.b	#$fe,$dff006
	bne	show1
show2:	cmpi.b	#$ff,$dff006
	bne	show2
	dbf	d0,show1

chgscr:	lea	obrtab,a1
	move	obrpnt,d0
	lsl	#2,d0
	move.l	(a1,d0.w),d1
	bne	chg2
	clr	obrpnt
	bra	chgscr
chg2:	addi	#2,obrpnt
	bsr	setaddr

mouse:	btst.b	#6,$bfe001
	bne	show

	bsr	colout
move.l	4,a6
lea	gfxname,a1
jsr	-552(a6)
move.l	d0,a0
move.l	$32(a0),$dff080
clr	$dff088
rts


;------------------zmiana ekranu---------------------------

setaddr:move	#4,d3
	lea	screen,a1
chgloop:move	d1,6(a1)
	swap	d1
	move	d1,2(a1)
	swap	d1
	add.l	#[heigth*row],d1
	adda	#8,a1
	dbf	d3,chgloop
	rts

;-------------------wchodzenie kolorow---------------------
colin:	move	#15,d0
setcol:	lea	colors,a1
	move.l	obrtab,a2
	adda.l	#[5*heigth*row],a2
	move	#31,d3
scol1:	move	(a2),d1
	andi	#$f,d1
	move	2(a1),d2
	andi	#$f,d2
	cmpi	d1,d2
	beq	scol2
	addi	#1,2(a1)
scol2:	move	(a2),d1
	andi	#$f0,d1
	move	2(a1),d2
	andi	#$f0,d2
	cmpi	d1,d2
	beq	scol3
	addi	#$10,2(a1)
scol3:	move	(a2)+,d1
	andi	#$f00,d1
	move	2(a1),d2
	andi	#$f00,d2
	cmpi	d1,d2
	beq	scol4
	addi	#$100,2(a1)
scol4:	adda	#4,a1
	dbf	d3,scol1
	move	#$1c00,d3
waitt:	muls	d1,d1
	dbf	d3,waitt
	dbf	d0,setcol
	rts

colout:	move	#7,d0
fadcol:	lea	colors,a1
	move	#31,d3
fad1:	move	2(a1),d1
	andi	#$f,d1
	beq	fad2
	subi	#1,2(a1)
fad2:	move	2(a1),d1
	andi	#$f0,d1
	beq	fad3
	subi	#$10,2(a1)
fad3:	move	2(a1),d1
	andi	#$f00,d1
	beq	fad4
	subi	#$100,2(a1)
fad4:	adda	#4,a1
	dbf	d3,fad1
	move	#$1c00,d3
wait5:	muls	d1,d1
	dbf	d3,wait5
	dbf	d0,fadcol
	rts

gfxname:
dc.b	'graphics.library',0,0
copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
colors:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
dc.l	$1900000,$1920000,$1940000,$1960000
dc.l	$1980000,$19a0000,$19c0000,$19e0000
dc.l	$1a00000,$1a20000,$1a40000,$1a60000
dc.l	$1a80000,$1aa0000,$1ac0000,$1ae0000
dc.l	$1b00000,$1b20000,$1b40000,$1b60000
dc.l	$1b80000,$1ba0000,$1bc0000,$1be0000

dc.l	$920060,$9400a8,$8e0171,$9037d1
screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000,$ec0007,$ee0000,$f00007,$f20000
dc.l	$1020000
dc.l	$1080000,$10a0000
dc.l	$6001ff00,$01005300
dc.l	$e001ff00,$01000300
dc.l	$fffffffe

end:
