
;		*****************************************	
;		*	  GLASS TRAIL VECTORS		*
;		*	 --------------------- 		*
;		*					*
;		*	   Coding on 25.05.1992		*
;		*	   by  KANE  of SUSPECT		*
;		*****************************************

org $30000
load $30000

raster: macro
wait?0:	cmp.b	#$fe,$dff006
	bne	wait?0
	cmp.b	#$ff,$dff006
	bne	wait?0+12
	endm

s:	movem.l	a0-a6/d0-d7,-(sp)
	move	$dff002,olddma
	ori	#$8000,olddma
	move	$dff01c,oldint
	ori	#$8000,oldint
	move	#$7fff,$dff09a
	move	#%1000001111110000,$dff096

	bsr	gl_vectors

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

gl_copper:
dc.l	$1200000,$1220000,$1240000,$1260000,$1280000,$12a0000
dc.l	$12c0000,$12e0000,$1300000,$1320000,$1340000,$1360000
dc.l	$1380000,$13a0000,$13c0000,$13e0000

gl_colors:

dc.l	$1800000,$1820090,$184000c,$1860909
dc.l	$1880090,$18a0070,$18c0009,$18e0707	;kol 1 w tle i komb.
dc.l	$190000c,$1920050,$1940006,$1960505	;kol 2
dc.l	$1980909,$19a0030,$19c0003,$19e0303	;kol 3

dc.l	$1a00000,$1a20bb0,$1a40ad7,$1a60fa5	;kolory traila
dc.l	$1a80000,$1aa0bb0,$1ac0ad7,$1ae0fa5
dc.l	$1b00000,$1b20bb0,$1b40ad7,$1b60fa5
dc.l	$1b80000,$1ba0bb0,$1bc0ad7,$1be0fa5

dc.l	$920038,$9400d0,$8e0171,$9037d1
gl_screen:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000,$ec0007,$ee0000,$f00007,$f20000
dc.l	$1020000,$1080002,$10a0002
gl_scril:
dc.l	$2a01ff00,$01000300
gl_up:
dc.l	$3801ff00,$1800000
dc.l	$3901ff00,$1800000
dc.l	$ffdffffe
dc.l	$0a01ff00,$01000300
gl_dn:
dc.l	$0b01ff00,$1800000
dc.l	$0c01ff00,$1800000
dc.l	$fffffffe

;-------------------------------------------------------------------
scron:		dc.l	$60000
scroff:		dc.l	$60000+[5*gl_heith*gl_row]

gl_heith=224
gl_row=42

ubor:	dc.w	0		;ramka,w ktorej ma byc zawarty obraz
dbor:	dc.w	223
lbor:	dc.w	0
rbor:	dc.w	320

gl_zoomob=2000			;zooming wstepny obiektow
gl_zoom=1000			;zooming perspektywiczny calosci

pkol:	dc.w	0
firstp:	dc.w	0

prpnt:	dc.w	0
lepnt:	dc.w	0
prtab:	blk.l	40,0
letab:	blk.l	40,0
matrix:	blk.l	50,0

gl_obiekt:	dc.w	1		;ktora anima?
gl_licz:	dc.w	200
gl_plane:	dc.w	0
gl_lfbyte:	dc.l	0
gl_texture:dc.w	0
gl_trbyte:	dc.b	0
even
;-------------------------------------------------------------------

gl_vectors:
	lea	$dff000,a0
	move.l	#$ffffffff,$44(a0)
	move.l	#$60000,scron
	move.l	#$60000+[5*gl_heith*gl_row],scroff
	bsr	gl_clscr
gl_wt5:	btst.b	#14,$2(a0)
	bne	gl_wt5
	move.l	#gl_copper,$dff080
	clr	$dff088
	move	gl_obiekt,d0
	beq	gl_kufel
	bne	gl_szescian

gl_kufel:move	#15,d0
	lea	kufel_cols,a1
	bsr	gl_setcol
	move.b	#$43,gl_scril+6
	lea	kufel,a6
	bsr	gl_speed
	clr	ubor
	move	#223,dbor
	move	#200,gl_licz
gl_control:cmpi.b #$ff,$dff006
	bne	gl_control
	addi	#4,(a6)
	subi	#3,4(a6)
	bsr	gl_chgscr
	bsr	gl_vector
	cmpi	#160,(a6)
	bmi	gl_control
gl_con2:cmpi.b	#$ff,$dff006
	bne	gl_con2
	bsr	gl_chgscr
	bsr	gl_vector
	subi	#1,gl_licz
	bne	gl_con2
gl_con3:cmpi.b	#$ff,$dff006
	bne	gl_con3
	addi	#3,(a6)
	subi	#5,4(a6)
	subi	#2,2(a6)
	bsr	gl_chgscr
	bsr	gl_vector
	cmpi	#550,(a6)
	bmi	gl_con3
	move.b	#3,gl_scril+6
	rts

gl_szescian:
	move	#15,d0
	lea	szescian_cols,a1
	bsr	gl_setcol
	move.b	#$53,gl_scril+6
	lea	szescian,a6
	bsr	gl_speed
	move	#15,ubor
	move	#223,dbor
	move	#14,d0
gl_ramka:raster
	raster
	add.b	#$10,gl_up+7
	add.b	#$10,gl_dn+7
	dbf	d0,gl_ramka

gl_cs1:	cmpi.b #$ff,$dff006
	bne	gl_cs1
	addi	#3,(a6)
	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	cmpi	#160,(a6)
	bmi	gl_cs1
	move	#100,gl_licz
gl_cs2:	cmpi.b #$ff,$dff006
	bne	gl_cs2
	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	subi	#1,gl_licz
	bne	gl_cs2
	move	#6,6(a6)
	move	#-8,8(a6)
	move	#10,10(a6)
gl_cs3:	cmpi.b #$ff,$dff006
	bne	gl_cs3
	addi	#1,4(a6)
	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	cmpi	#900,4(a6)
	bmi	gl_cs3
	move	#60,gl_licz
gl_cs4:	cmpi.b #$ff,$dff006
	bne	gl_cs4
	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	subi	#1,gl_licz
	bne	gl_cs4
	clr	ubor
gl_cs5:	cmpi.b #$ff,$dff006
	bne	gl_cs5
	subi	#1,(a6)
	subi	#2,2(a6)
	cmpi	#650,4(a6)
	bmi	gl_cc5
	subi	#6,4(a6)
gl_cc5:	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	cmpi	#-140,2(a6)
	bpl	gl_cs5

gl_shit:
	move	#31,d0
	lea	box_cols,a1
	bsr	gl_setcol
	move	#-90,(a6)
	move	#300,2(a6)
	move	#800,4(a6)
	move	#4,20(a6)
	move	#15,ubor
gl_cs6:	cmpi.b #$ff,$dff006
	bne	gl_cs6
	addi	#4,(a6)
	subi	#3,2(a6)
	cmpi	#630,4(a6)
	bmi	gl_cc6
	subi	#6,4(a6)
gl_cc6:	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	cmpi	#120,2(a6)
	bpl	gl_cs6
	move	#80,gl_licz
gl_wtt6:cmpi.b #$ff,$dff006
	bne	gl_wtt6
	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	subi	#1,gl_licz
	bne	gl_wtt6
gl_cs7:	cmpi.b #$ff,$dff006
	bne	gl_cs7
	addi	#2,(a6)
	subi	#1,2(a6)
	addi	#5,4(a6)
	bsr	gl_chgscr
	bsr	gl_vector
	bsr	gl_vtrail
	cmpi	#1000,4(a6)
	bmi	gl_cs7
	move	#31,d0
	lea	gl_colors,a1
gl_cout2:move	#0,2(a1)
	adda.l	#4,a1
	dbf	d0,gl_cout2
	move	#40,d0
gl_wtt7:raster
	dbf	d0,gl_wtt7

	move	#14,d0
gl_ramk2:raster
	raster
	sub.b	#$10,gl_up+7
	sub.b	#$10,gl_dn+7
	dbf	d0,gl_ramk2
gl_quit:	rts


gl_clscr:btst.b	#14,$2(a0)
	bne	gl_clscr
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	#$60000,$54(a0)
	move	#63,$58(a0)
	rts

gl_setcol:
	lea	gl_colors,a2
gl_set1:move	(a1)+,2(a2)
	addi	#4,a2
	dbf	d0,gl_set1
	rts

gl_chgscr:	btst.b	#14,$2(a0)
	bne	gl_chgscr
	move.l	scron,d0		;zmien ekrany
	move.l	scroff,d1
	move.l	d0,scroff
	move.l	d1,scron
	move	d1,gl_screen+6
	swap	d1
	move	d1,gL_screen+2
	swap	d1
	add.l	#[gl_heith*gl_row],d1
	move	d1,gl_screen+14
	swap	d1
	move	d1,gl_screen+10
	swap	d1
	add.l	#[gl_heith*gl_row],d1
	move	d1,gl_screen+22
	swap	d1
	move	d1,gl_screen+18
	swap	d1
	add.l	#[gl_heith*gl_row],d1
	move	d1,gl_screen+30
	swap	d1
	move	d1,gl_screen+26
	swap	d1
	add.l	#[gl_heith*gl_row],d1
	move	d1,gl_screen+38
	swap	d1
	move	d1,gl_screen+34
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	d0,$54(a0)
	move	#[5*gl_heith*32]+[gl_row],$58(a0)
	rts

gl_vector:	move	20(a6),d7		;ilosc plaszczyzn
	lea	matrix,a4
	move.l	26(a6),a3
	sf	gl_trbyte
gl_obr1:	move	(a3)+,pkol
	move	(a3)+,d6
	clr	gl_plane
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
	bmi	gl_obr2
	move	#[2*gl_heith*gl_row],gl_plane
gl_obr2:subi	#2,d6
	move	(a3),firstp
	clr.l	prpnt
gl_obr3:move	(a3)+,d4
	move	(a3),d5
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	gl_ldraws
	dbf	d6,gl_obr3
	move	(a3)+,d4
	move	firstp,d5
	lsl	#2,d4
	lsl	#2,d5
	movem	(a4,d4.w),d0/d1
	movem	(a4,d5.w),d2/d3
	bsr	gl_ldraws
gl_koryg:lea	prtab,a2	;wykresl dod.linie z lewej i prawej
	move	prpnt,d4
	bsr	gl_korygm
	lea	letab,a2
	move	lepnt,d4
	bsr	gl_korygm
gl_pomin:	dbf	d7,gl_obr1

gl_fill:	btst.b	#14,$2(a0)
	bne	gl_fill
	clr.l	$64(a0)
	move.l	#$09f00012,$40(a0)
	move.l	scroff,d4
	add.l	#[4*gl_heith*gl_row]-2,d4
	move.l	d4,$54(a0)
	move.l	d4,$50(a0)
	move	#[4*gl_heith*64]+[gl_row/2],$58(a0)

gl_speed:	move	6(a6),d0
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
gl_twodim:	move	16(a6),d0
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

	move	#gl_zoomob,d4	;zooming wstepny
	sub	d3,d4
	muls	d4,d1
	divs	#gl_zoomob,d1
	muls	d4,d2
	divs	#gl_zoomob,d2
	move	4(a6),d3	;dod.srodek z
	move	#gl_zoom,d4	;zooming calosciowy
	sub	d3,d4
	muls	d4,d1
	divs	#gl_zoom,d1
	muls	d4,d2
	divs	#gl_zoom,d2
	addi	(a6),d1		;dodaj srodek
	addi	2(a6),d2
	move	d1,(a3)+
	move	d2,(a3)+
	adda.l	#6,a2
	dbf	d6,gl_twodim
gl_wait2:	btst.b	#14,$2(a0)
	bne	gl_wait2
	rts

gl_korygm:	beq	gl_korend			;koryguj linie z lew. i pra.
	movem	(a2)+,d0-d3
	cmpi	ubor,d1
	bpl	gl_kor1
	cmpi	ubor,d3
	bmi	gl_nokor
	move	ubor,d1
	bra	gl_kord
gl_kor1:cmpi	ubor,d3
	bpl	gl_kord
	move	ubor,d3
gl_kord:cmpi	dbor,d1
	bmi	gl_kor2
	cmpi	dbor,d3
	bpl	gl_nokor
	move	dbor,d1
	bra	gl_kor3
gl_kor2:cmpi	dbor,d3
	bmi	gl_kor3
	move	dbor,d3
gl_kor3:bsr	gl_lindraw
gl_nokor:subi	#8,d4
	bra	gl_korygm
gl_korend:	rts

gl_ldraws:cmpi	rbor,d0		;obetnij do ramki
	bmi	gl_prawo2
	cmpi	rbor,d2
	bpl	gl_noline
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
gl_prdory:	move.l	a1,-(sp)
	lea	prtab,a1
	move	prpnt,d5
	move	rbor,(a1,d5.w)
	move	d4,2(a1,d5.w)
	addi	#4,d5
	move	d5,prpnt
	move.l	(sp)+,a1
	bra	gl_lewo
gl_prawo2:	cmpi	rbor,d2
	bmi	gl_lewo
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
	bra	gl_prdory
gl_lewo:cmpi	lbor,d0
	bpl	gl_lewo2
	cmpi	lbor,d2
	bmi	gl_noline
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
gl_ldorys:	move.l	a1,-(sp)
	lea	letab,a1
	move	lepnt,d5
	move	lbor,(a1,d5.w)
	move	d4,2(a1,d5.w)
	addi	#4,d5
	move	d5,lepnt
	move.l	(sp)+,a1
	bra	gl_gora
gl_lewo2:cmpi	lbor,d2
	bpl	gl_gora
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
	bra	gl_ldorys
gl_gora:	cmpi	ubor,d1
	bpl	gl_gora2
	cmpi	ubor,d3
	bmi	gl_noline
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
	bra	gl_dol
gl_gora2:	cmpi	ubor,d3
	bpl	gl_dol
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
gl_dol:	cmpi	dbor,d1
	bmi	gl_dol2
	cmpi	dbor,d3
	bpl	gl_noline
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
	bra	gl_lindraw1
gl_dol2:cmpi	dbor,d3
	bmi	gl_lindraw1
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
gl_lindraw1:tst.b	gl_trbyte
	beq	gl_lindraw
	move.l	scroff,a5
	adda.l	#[4*gl_heith*gl_row],a5
	move.l	#$ca0000,gl_lfbyte
	move	#$7777,gl_texture
	bra	gl_line
gl_lindraw:cmpi	d1,d3
	beq	gl_noline
	move.l	#$4a0002,gl_lfbyte
	move	#$ffff,gl_texture
	move.l	scroff,a5
	adda	gl_plane,a5
	move	pkol,d5
	btst	#0,d5
	beq	gl_lin1
	bsr	gl_line
gl_lin1:adda.l	#[gl_heith*gl_row],a5
	btst	#1,d5
	beq	gl_noline
	bsr	gl_line
gl_noline:	rts

gl_line:	movem.l	d0-d7,-(sp)	;rys.linie
gl_wait3:	btst	#14,2(a0)
	bne	gl_wait3	
	cmp	d1,d3
	bge	gl_p1
	exg	d2,d0
	exg	d1,d3
gl_p1:	addq	#1,d1
	moveq	#$f,d4	
	and	d2,d4
	sub	d3,d1
	neg	d1
	mulu	#gl_row,d3		;wys. linii * szer. ekranu
	sub	d2,d0
	blt	gl_p5
	cmp	d0,d1
	bge	gl_p4
	moveq	#$19,d7
	bra	gl_p9
gl_p4:	moveq	#$5,d7 
	exg	d0,d1
	bra	gl_p9
gl_p5:	neg	d0
	cmp	d0,d1
	bge	gl_p8
	moveq	#$1d,d7
	bra	gl_p9
gl_p8:	moveq	#$d,d7
	exg	d0,d1
gl_p9:	asl	#1,d1
	asr	#$3,d2
	ext.l	d2
	add.l	d2,d3
	move	d1,d2
 	sub	d0,d2 
	bge	gl_p10
	ori	#$40,d7
gl_p10:	move	d2,d6
	move	d1,$62(a0)
	move	d2,d1	
	sub	d0,d1
	move	d1,$64(a0)
	move	#gl_row,$60(a0)
	addq	#1,d0
	asl	#6,d0
	addq	#2,d0
	ror.l	#4,d4
	or.l	d4,d7
	move	#$8000,$74(a0)
	ori.l	#$b000000,d7		;LF itp
	or.l	gl_lfbyte,d7
	add.l	a5,d3			;rastport
	move.l	d7,$40(a0)
	move	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move	gl_texture,$72(a0)
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

;-----------------------------------------------------------

gl_vtrail:st	gl_trbyte
	lea	sinus,a1
	lea	sinus+$80,a4
	lea	gl_pos1,a2
	lea	gl_poss,a3
	lea	gl_posok,a5
	addi	#12,(a2)
	addi	#4,2(a2)
	addi	#-2,4(a2)
	addi	#6,6(a2)
	addi	#-8,8(a2)
	addi	#-10,10(a2)
	move.l	(a2),(a3)
	move.l	4(a2),4(a3)
	move.l	8(a2),8(a3)

	move	#35,d6
gl_trmain:addi	#12,(a3)
	addi	#-6,2(a3)
	addi	#-14,4(a3)
	addi	#10,6(a3)
	addi	#8,8(a3)
	addi	#16,10(a3)
	andi	#$1fe,(a3)
	andi	#$1fe,2(a3)
	andi	#$1fe,4(a3)
	andi	#$1fe,6(a3)
	andi	#$1fe,8(a3)
	andi	#$1fe,10(a3)

	movem	(a3),d1-d3		;przekrec 1 koniec
	move	(a1,d1.w),d1
	move	(a1,d2.w),d2
	move	(a1,d3.w),d3
	asr	#1,d3
	movem	d1-d3,(a5)
	bsr	gl_trdim
	movem	d1/d2,-(sp)
	movem	6(a3),d1-d3		;przekrec 2 koniec
	move	(a1,d1.w),d1
	move	(a1,d2.w),d2
	move	(a1,d3.w),d3
	asr	#1,d3
	movem	d1-d3,(a5)
	bsr	gl_trdim
	move	d1,d0
	move	d2,d1
	movem	(sp)+,d2/d3
	bsr	gl_ldraws
	dbf	d6,gl_trmain
	rts

gl_trdim:	move	16(a6),d0	;kat
	move	4(a5),d1
	move	(a5),d2		;zxy
	bsr	rotate
	move	14(a6),d0
	move	d2,d3
	move	2(a5),d2	;zyx
	bsr	rotate
	move	12(a6),d0
	exg	d1,d3		;xyz
	bsr	rotate

	move	#gl_zoomob,d4
	sub	d3,d4
	muls	d4,d1
	divs	#gl_zoomob,d1
	muls	d4,d2
	divs	#gl_zoomob,d2
	move	4(a6),d3	;dod.srodek z
	move	#gl_zoom,d4
	sub	d3,d4
	muls	d4,d1
	divs	#gl_zoom,d1
	muls	d4,d2
	divs	#gl_zoom,d2
	addi	(a6),d1		;dodaj srodek
	addi	2(a6),d2
	rts

gl_pos1:dc.w	0,400,30
	dc.w	200,200,300
gl_poss:	blk.w	6,0
gl_posok:	blk.w	3,0


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
dc.w	-120,119,620
dc.w	0,0,0
dc.w	128,128,128
dc.w	7,5
dc.l	szdots,szline
szdots:
dc.w	-256,-256,-128
dc.w	256,-256,-128
dc.w	256,256,-128
dc.w	-256,256,-128
dc.w	-256,-256,128
dc.w	256,-256,128
dc.w	256,256,128
dc.w	-256,256,128
szline:
dc.w	2,4,0,3,7,4
dc.w	2,4,5,6,2,1
dc.w	3,4,2,6,7,3
dc.w	3,4,5,1,0,4
dc.w	1,4,4,7,6,5
dc.w	1,4,0,1,2,3
szescian_cols:
dc.w	0,$90,$c,$909,$90,$70,$9,$707,$c,$50,$6,$505,$909,$30,$3,$303

kufel:
dc.w	-110,90,750
dc.w	-8,6,-6
dc.w	120,10,200
dc.w	21,9
dc.l	kudots,kupla
kudots:
dc.w	-120,140,0
dc.w	-80,140,-80
dc.w	0,140,-120
dc.w	80,140,-80
dc.w	120,140,0
dc.w	80,140,80
dc.w	0,140,120
dc.w	-80,140,80
dc.w	-120,-140,0
dc.w	-80,-140,-80
dc.w	0,-140,-120
dc.w	80,-140,-80
dc.w	120,-140,0
dc.w	80,-140,80
dc.w	0,-140,120
dc.w	-80,-140,80

dc.w	200,140,0
dc.w	200,-120,0
dc.w	120,-100,0
dc.w	180,-100,0
dc.w	180,120,0
dc.w	120,120,0
kupla:
dc.w	1,8,0,1,2,3,4,5,6,7
dc.w	2,4,1,0,8,9
dc.w	3,4,2,1,9,10
dc.w	2,4,3,2,10,11
dc.w	3,4,4,3,11,12
dc.w	2,4,5,4,12,13
dc.w	3,4,6,5,13,14
dc.w	2,4,7,6,14,15
dc.w	3,4,0,7,15,8
dc.w	1,8,17,16,4,21,20,19,18,12
kufel_cols:
dc.w	0,$4d,$4b,$49,$3d,$19,$2d,$2b,$4b,$29,$3d,$3b,$49,$49,$4d,$4b
box_cols:
dc.w	0,$1de,$19b,$158,$c0,$1de,$19b,$158,$80,$1de,$19b,$158,$40,$1de,$19b,$158
dc.w	0,$1de,$19b,$158,$ff0,$1de,$19b,$158,$ff0,$1de,$19b,$158,$ff0,$1de,$19b,$158

