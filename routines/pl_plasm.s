
;		*****************************************	
;		*	 INTERFERENCE RGB PLASM		*
;		*	 ----------------------		*
;		*					*
;		*      	  Coding on 09.04.1992		*
;		*	  by  KANE  of SUSPECT		*
;		*****************************************
;Use RMB to change plasm or LMB to exit...

org	$20000
load	$20000

s:
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	#pl_copper,$dff080
	move	$dff002,olddma
	ori	#$8000,olddma
	move	#%1000001111100000,$dff096
	move	$dff01c,oldint
	move	#$7fff,$dff09a
	move	#$8020,$dff09a

	bsr	pl_plasm

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
pl_border:
dc.l	$a001ff00,$18000a0
dc.l	$a101ff00,$1800000
dc.l	$a301ff00,$01005300
dc.l	$a301ff00,$01000300
dc.l	$a501ff00,$18000a0
dc.l	$a601ff00,$1800000
dc.l	$ffdffffe
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

pl_isitall:	dc.w	0
pl_conti:	dc.w	0
pl_counter:	dc.w	3000
pl_oldlev:	dc.l	0
pl_plaaddr:	dc.l	plasm1
pl_coladdr:	dc.l	pl_coltab
pl_addval:	dc.w	1

pl_obnum:		dc.w	0
pl_obtab:		dc.l	plasm5,plasm2,plasm3,plasm4,plasm1,plasm6,0

pl_clrit:		dc.l	0,0,0,0,0,0,0
pl_point:		dc.w	0
;cirflag:	dc.w	1
pl_endflag:	dc.w	0
even
;-------------------------------------------------------------------

pl_plasm:
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
	bsr	pl_ramka2
pl_quit:move	#$4000,$dff09a
	move.l	pl_oldlev,$6c
	move	#$c000,$dff09a
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
;	st	cirflag
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
;	clr	cirflag
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
;	tst	cirflag
;	bne	pu2
;	bsr	circle
pl_pu2:	addi	#3,d0
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
	bne	pl_quit
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
	subi	#$22,pl_shft+2
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


pl_fonts=$50000
>extern	"df0:.store/ohm_font.raw",pl_fonts,-1

