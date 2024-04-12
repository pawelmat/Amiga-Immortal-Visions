;Suspect Immortal Visions HAM Animation Replayer coded by Kane

org	$30000
load	$30000

aaobrazg=$32000
aaobrazek=aaobrazg+6120

tp_fonts=$50000

>extern	"df0:.store/ball_anim.raw",aaobrazg,-1
;>extern	"df0:ball_anim/fonts_8*16",tp_fonts,-1

aaobrpnt:		dc.w	0
aaobrtab:
dc.l aaobrazek,aaobrazek+[9240],aaobrazek+[2*9240],aaobrazek+[3*9240]
dc.l aaobrazek+[4*9240],aaobrazek+[5*9240],aaobrazek+[6*9240]
dc.l aaobrazek+[7*9240],0

aaheigthg=51
aaheigth=77
aarow=20

s:	
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

mouse:	btst.b	#6,$bfe001	;
	beq	w

	tst	aaexit
	beq	aashow

w	move	#14,d1
aaramka2:sub.b	#$11,aaramg+7
	sub.b	#$11,aaramd+7
	move	#1,d0
	bsr	aawait
	dbf	d1,aaramka2

move.l	4,a6
lea	gfxname,a1
jsr	-552(a6)
move.l	d0,a0
move.l	$32(a0),$dff080
clr	$dff088
rts


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

	bsr	tp_proba	;;;;;;;;;;;;;;;;;;;;

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

gfxname:
dc.b	'graphics.library',0,0
aacopper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000
dc.l	$1800000,$182066f,$1840950,$1860214,$1880ed3,$18a022c,$18c0d99,$18e0776
dc.l	$1900eef,$1920d92,$1940641,$1960330,$1980f55,$19a054a,$19c0ff9,$19e0bbf

dc.l	$920060,$9400a8,$8e0171,$9037d1
dc.l	$1020000,$1080000,$10a0000
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

dc.l	$ffdffffe
dc.l	$920038,$9400d0
tp_scr
dc.l	$e00003,$e20000,$1820000
dc.l	$0101ff00,$01001300
dc.l	$1101ff00,$01000300

dc.l	$fffffffe


;---------------------------------------------------------------
tp_proba:
	lea	tp_scr,a1
	lea	tp_text,a2
	bsr	tp_init
	rts

tp_text: dc.b	"  NOW WE'RE IN FOR  ",0,100

tp_scarea:	blk.b	[16*40],0
tp_scaddr:	dc.l	0
tp_counter:	dc.b	0
tp_in:		dc.b	0
tp_iocount:	dc.b	2
even

;a1-ekran+kolor w copperliscie
;a2-pocz tekstu

tp_init:move.l	d0,-(sp)
	move.l	#tp_scarea,d0
	move	d0,6(a1)
	swap	d0
	move	d0,2(a1)
	move.l	a1,tp_scaddr
	lea	tp_scarea,a1
tp_loop:clr.l	d0
	move.b	(a2)+,d0
	beq	tp_end
	subi	#32,d0
	mulu	#32,d0
	add.l	#tp_fonts,d0
tp_wblt:btst.b	#14,$dff002
	bne	tp_wblt
	move.l	#$ffffffff,$dff044
	clr	$dff064
	move	#38,$dff066
	move.l	#$9f00000,$dff040
	move.l	d0,$dff050
	move.l	a1,$dff054
	move	#[16*64]+1,$dff058
	addi	#2,a1
	bra	tp_loop
tp_end:	move.b	(a2)+,tp_counter
	move	#$4000,$dff09a
	move.l	$6c,tp_jump+2
	move.l	#tp_level3,$6c
	move	#$c020,$dff09a
	move.l	(sp)+,d0
	rts
tp_level3:
	movem.l	d0/a1,-(sp)
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
	move.l	tp_jump+2,$6c
	clr	10(a1)
	sf	tp_in
tp_quit:movem.l	(sp)+,d0/a1
tp_jump:jmp	0

end:
