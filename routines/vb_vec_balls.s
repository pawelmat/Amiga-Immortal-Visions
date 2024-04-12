
;		*****************************************	
;		*	  3D GUMI-VECTORBALLS		*
;		*	 ----------------------		*
;		*					*
;		*	   Coding on 29.02.1992		*
;		*	   by  KANE  of SUSPECT		*
;		*****************************************


org	$20000
load	$20000

s:
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,gfxbase
	move.l	d0,a0
	move.l	$32(a0),oldcop
	move.w	$dff002,olddma
	move.w	#%1000000111101111,$dff096

	bsr	vb_vecballs

	move.w	olddma,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.l	gfxbase,a0
	move.l	oldcop,$32(a0)
	movem.l	(sp)+,a0-a6/d0-d7
	rts

gfxbase:	dc.l	0
oldcop:		dc.l	0
olddma:		dc.l	0
gfxname:	dc.b	'graphics.library',0,0

vb_copper:
vb_colors:
dc.l	$1800000,$1820aa0	;no screen,set colors
dc.l	$1840a70,$1860ad0
dc.l	$1880000,$18a00a0
dc.l	$18c0070,$18e00d0
dc.l	$920028,$9400d8,$8e0171,$9037d1
vb_screen:
dc.l	$e00007,$e20000			;btpls
dc.l	$e40007,$e60000
dc.l	$e80007,$ea0000
dc.l	$1020000,$1080000,$10a0000	;bplcon1,modulos
dc.l	$1501ff00,$01003200		;btpls on
dc.l	$ffdffffe
dc.l	$3501ff00,$01000200		;wait,btpls off
dc.l	$fffffffe			;end

;-------------------------------------------------------------------
vb_scron:	dc.l	$60000		    ;adresy zmienianych ekranow
		dc.l	$60000+13800
		dc.l	$60000+27600
vb_scroff:	dc.l	$60000+41400
		dc.l	$60000+55200
		dc.l	$60000+69000
vb_heith=300
vb_row=46
vb_hmid=180
VB_vmid=145
vb_zmid=0
vb_zoom=100

vb_objectnum:	dc.w	0
vb_allobjects=2
VB_objecttab:
dc.l		vb_amiga,vb_krzyz
vb_speeda:		dc.w	0	;szybkosci
vb_speedb:		dc.w	0
vb_speedc:		dc.w	0
vb_anglea:		dc.w	128	;katy
vb_angleb:		dc.w	0
vb_anglec:		dc.w	-64
vb_pointnum:	dc.w	0
vb_pointtab:	blk.l	105,0	;nie wiecej niz 70 punktow
vb_matrix:		blk.l	70,0
vb_priortab:	blk.w	70,0
vb_ztab:		blk.w	70,0
vb_coltab:		blk.w	70,0
vb_maskas:		blk.l	16,0
vb_zlicz:		dc.w	0
vb_mnflag:		dc.w	0	
vb_timer:		dc.w	1
vb_tims:		dc.w	1
vb_ilkas:		dc.w	16
vb_flag:		dc.w	1
;-------------------------------------------------------------------

vb_wblt:btst.b	#14,$2(a0)
	bne	vb_wblt
	rts
vb_vecballs:
	move.l	#$dff000,a0
	bsr	vb_newobject		;inicjuj pierwszy obiekt
	bsr	vb_wblt
	move.l	#$ffffffff,$44(a0)	;maska; i tak zawsze taka
	clr.w	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	vb_scron,$54(a0)
	move.w	#[3*vb_heith*64]+vb_row,$58(a0)
	bsr	vb_wblt
	move.l	#vb_copper,$dff080
	clr	$dff088
vb_control:
	cmpi.b	#$ff,$dff006
	bne	vb_control
	bsr	vb_vector			;vector routine
	cmpi	#$aaaa,vb_tims
	bne	vb_control
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
	dc.w	$FF05,$FF04,$FF03,$FF02,$FF01,$FF01,$FF01,$FF01
	dc.w	$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04,$FF05
	dc.w	$FF06,$FF08,$FF09,$FF0B,$FF0D,$FF0F,$FF11,$FF14
	dc.w	$FF16,$FF19,$FF1B,$FF1E,$FF21,$FF24,$FF28,$FF2B
	dc.w	$FF2F,$FF32,$FF36,$FF3A,$FF3E,$FF42,$FF47,$FF4B
	dc.w	$FF4F,$FF54,$FF59,$FF5E,$FF62,$FF67,$FF6D,$FF72
	dc.w	$FF77,$FF7C,$FF82,$FF87,$FF8D,$FF93,$FF98,$FF9E
	dc.w	$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8,$FFCE
	dc.w	$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA,$0000
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0032,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0062,$0068,$006D,$0073,$0079,$007E,$0084,$0089
	dc.w	$008E,$0093,$0099,$009E,$00A2,$00A7,$00AC,$00B1
	dc.w	$00B5,$00B9,$00BE,$00C2,$00C6,$00CA,$00CE,$00D1
	dc.w	$00D5,$00D8,$00DC,$00DF,$00E2,$00E5,$00E7,$00EA
	dc.w	$00EC,$00EF,$00F1,$00F3,$00F5,$00F7,$00F8,$00FA
	dc.w	$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF,$00FF
;-------------------------------------------------------------------

vb_vector:
	lea	vb_scron,a1		;zmien ekrany
	lea	vb_scroff,a2
	move.l	(a1),d0
	move.l	(a2),d1
	move.l	d0,(a2)
	move.l	d1,(a1)
	move.w	d1,vb_screen+6
	swap	d1
	move.w	d1,vb_screen+2
	move.l	4(a1),d0
	move.l	4(a2),d1
	move.l	d0,4(a2)
	move.l	d1,4(a1)
	move.w	d1,vb_screen+14
	swap	d1
	move.w	d1,vb_screen+10
	move.l	8(a1),d0
	move.l	8(a2),d1
	move.l	d0,8(a2)
	move.l	d1,8(a1)
	move.w	d1,vb_screen+22
	swap	d1
	move.w	d1,vb_screen+18
vb_wait1:btst.b	#14,$2(a0)
	bne	vb_wait1
	clr.w	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	(a2),$54(a0)
	move.w	#[3*vb_heith*32]+[vb_row],$58(a0)

	move.w	vb_speeda,d0		;pododawaj szybkosci
	add.w	d0,vb_anglea	
	move.w	vb_speedb,d0
	add.w	d0,vb_angleb
	move.w	vb_speedc,d0
	add.w	d0,vb_anglec

	lea	sinus,a1
	lea	sinus+128,a4
	lea	vb_pointtab,a2
	lea	vb_matrix,a3
	lea	vb_ztab,a5
	move.w	vb_pointnum,d6
vb_twodim:move.w vb_anglea,d0
	move.w	(a2),d1
	move.w	2(a2),d2
	jsr	rotate
	move.w	vb_angleb,d0
	move.w	d2,d3
	move.w	4(a2),d2
	jsr	rotate
	move.w	vb_anglec,d0
	exg	d1,d3
	exg	d2,d3
	jsr	rotate
	exg	d1,d3
	addi.w	#vb_zmid,d3

	move.l	#vb_zoom,d4
	sub.w	d3,d4
	muls	d4,d1
	divs	#vb_zoom,d1
	muls	d4,d2
	divs	#vb_zoom,d2
	addi.w	#vb_hmid,d1	;dodaj srodek x i y
	addi.w	#vb_vmid,d2
	move.w	d1,(a3)+	;zapisz x,y w matrycy
	move.w	d2,(a3)+
	move.w	d3,(a5)+
	adda.l	#6,a2
	dbf	d6,vb_twodim
	
	lea	vb_priortab,a4
	move.w	vb_pointnum,d1
	move.w	d1,d3
	lea	vb_ztab,a5
vb_prior1:	moveq	#0,d2	
	move.w	(a5)+,d0
	move.w	d2,vb_mnflag
vb_prior2:	addq	#1,d2
	cmp.w	(a5),d0
	ble	vb_prior3
	move.w	d2,vb_mnflag
	move.w	(a5),d0
vb_prior3:	adda.l	#2,a5
	cmpi.w	d2,d3
	bne	vb_prior2
	move.w	vb_mnflag,d0
	move.w	d0,(a4)+
	lea	vb_ztab,a5
	lsl.w	#1,d0
	move.w	#$7777,(a5,d0)
	dbf	d1,vb_prior1

	move.w	vb_pointnum,d6
	move.w	d6,d4
	lsl	#1,d4
	lea	vb_matrix,a3
	lea	vb_scroff,a1
	lea	vb_priortab,a4
	lea	vb_coltab,a5
	clr.l	d5
	clr.l	d1
vb_drawit:	clr.l	d2
	move.w	(a4,d4),d5
	lsl	#1,d5
	move.w	(a5,d5),d7
	lsl	#1,d5
	move.w	(a3,d5),d1
	move.w	2(a3,d5),d2
	cmpi.w	#0,d1
	blt	vb_drcont
	cmpi.w	#0,d2
	blt	vb_drcont
	cmpi.w	#vb_heith-16,d2
	bgt	vb_drcont
	cmpi.w	#350,d1
	bgt	vb_drcont
vb_makeball:
	move.l	(a1),a2
	mulu	#vb_row,d2
	move.w	d1,d0
	andi.w	#$f,d0
	ror.w	#4,d0
	lsr.w	#3,d1
	add.l	d1,d2
	adda.l	d2,a2
vb_wait2:btst.b	#14,$2(a0)	
	bne	vb_wait2
	move.l	#vb_mas1,$50(a0)
	move.l	#vb_maskas,$4c(a0)
	move.l	a2,$48(a0)
	move.l	a2,$54(a0)
	clr.l	$62(a0)
	move.w	#vb_row-4,$60(a0)
	move.w	#vb_row-4,$66(a0)
	move.w	d0,$42(a0)
	move.w	#%0000111111100010,d1
	or.w	d0,d1
	move.w	d1,$40(a0)
	move.w	#16*64+2,$58(a0)
	move.l	4(a1),a2
	adda.l	d2,a2
vb_wait3:	btst.b	#14,$2(a0)
	bne	vb_wait3
	move.l	#vb_mas2,$50(a0)
	move.l	#vb_maskas,$4c(a0)
	move.l	a2,$48(a0)
	move.l	a2,$54(a0)
	move.w	#16*64+2,$58(a0)
	move.l	8(a1),a2
	adda.l	d2,a2
	cmpi.w	#0,d7
	beq	vb_wait5
vb_wait4:	btst.b	#14,$2(a0)
	bne	vb_wait4
	move.l	#vb_mas3,$50(a0)
	move.l	#vb_maskas,$4c(a0)
	move.l	a2,$48(a0)
	move.l	a2,$54(a0)
	move.w	#16*64+2,$58(a0)
	bra	vb_drcont
vb_wait5:	btst.b	#14,$2(a0)
	bne	vb_wait5
	move.l	#vb_mas4,$50(a0)
	move.l	#vb_maskas,$4c(a0)
	move.l	a2,$48(a0)
	move.l	a2,$54(a0)
	move.w	#16*64+2,$58(a0)
vb_drcont:	subq	#2,d4
	dbf	d6,vb_drawit

vb_checktime:
	subi.w	#1,vb_timer
	cmpi.w	#0,vb_timer
	bne	vb_quit
	move.w	#3,vb_timer
	cmpi.w	#1,vb_flag
	beq	vb_fadein
	move.w	vb_ilkas,d0
	lsl.w	#2,d0
	lea	vb_maskas,a1
	adda.w	d0,a1
	clr.w	(a1)
	addi.w	#1,vb_ilkas
	cmpi.w	#17,vb_ilkas
	bne	vb_quit	
	bsr	vb_newobject
	move.w	#1,vb_flag
	subi.w	#1,vb_ilkas
	move.w	#10,vb_timer
vb_quit:	rts
vb_fadein:	lea	vb_maska,a1
	lea	vb_maskas,a2
	move.w	vb_ilkas,d0
	lsl	#2,d0
	move.l	(a1,d0.w),(a2,d0.w)
	subi.w	#1,vb_ilkas
	bpl	vb_quit
	move.w	#0,vb_ilkas
	move.w	#0,vb_flag	
	move.w	vb_tims,vb_timer
	rts

rotate:				;obracanie plaszczyzn
	rol.w	#1,d0		;kat w slowach
	andi.l	#$1fe,d0
	move.w	d1,d4		;x
	move.w	d2,d5		;y
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
	move.w	d5,d2		;y' do d2
	rts	

vb_newobject:			;inicjacja nowego obiektu
	move.w	vb_objectnum,d0
	cmpi.w	#vb_allobjects,d0	;jesli wszystkie to znow pierwszy
	bne	vb_new2
	move	#$aaaa,vb_tims
	rts
vb_new2:	lsl.w	#2,d0
	lea	vb_objecttab,a1
	move.l	(a1,d0.w),a1
	move.w	(a1)+,d0	;ilosc kulek
	move.l	(a1)+,vb_speeda
	move.w	(a1)+,vb_speedc
	move.w	(a1)+,vb_tims
	subq	#1,d0		;wartosc dla dbf
	move.w	d0,vb_pointnum
	lea	vb_pointtab,a2
	lea	vb_coltab,a3
vb_new3:	move.l	(a1)+,(a2)+	;skopiuj 3 slowa (x,y,z)
	move.w	(a1)+,(a2)+
	move.w	(a1)+,(a3)+
	dbf	d0,vb_new3
	move	#7,d0
	lea	vb_colors,a2
vb_new4:move	(a1)+,2(a2)
	adda.l	#4,a2
	dbf	d0,vb_new4
	addi.w	#1,vb_objectnum	;nastaw na nastepny obiekt
	rts

vb_maska:
dc.w	%0000011111100000,0
dc.w	%0001111111111000,0
dc.w	%0011111111111100,0
dc.w	%0111111111111110,0
dc.w	%0111111111111110,0
dc.w	$ffff,0,$ffff,0,$ffff,0,$ffff,0,$ffff,0,$ffff,0
dc.w	%0111111111111110,0
dc.w	%0111111111111110,0
dc.w	%0011111111111100,0
dc.w	%0001111111111000,0
dc.w	%0000011111100000,0
vb_mas1:
dc.w	%0000011101000000,0
dc.w	%0001111110100000,0
dc.w	%0011111111010000,0
dc.w	%0111111111101000,0
dc.w	%0111111111010000,0
dc.w	%1111111111101000,0
dc.w	%1111111111110100,0
dc.w	%1111111111101000,0
dc.w	%1111111111101000,0
dc.w	%1111111111110100,0
dc.w	%1111111111101000,0
dc.w	%0111111111010000,0
dc.w	%0111111111101000,0
dc.w	%0011111111010000,0
dc.w	%0001111110100000,0
dc.w	%0000011101000000,0
vb_mas2:
dc.w	%0000000010100000,0
dc.w	%0000010101011000,0
dc.w	%0000111000101100,0
dc.w	%0011110000010110,0
dc.w	%0011001000101110,0
dc.w	%0011100000010111,0
dc.w	%0111010000001011,0
dc.w	%0110100000010111,0
dc.w	%0110100000010111,0
dc.w	%0111010000001011,0
dc.w	%0011100000010111,0
dc.w	%0011001000101110,0
dc.w	%0011110000010110,0
dc.w	%0000111000101100,0
dc.w	%0000010101011000,0
dc.w	%0000000010100000,0
vb_mas3:
dc.w	%0000011111100000,0
dc.w	%0001111111111000,0
dc.w	%0011111111111100,0
dc.w	%0111111111111110,0
dc.w	%0111111111111110,0
dc.w	$ffff,0,$ffff,0,$ffff,0,$ffff,0,$ffff,0,$ffff,0
dc.w	%0111111111111110,0
dc.w	%0111111111111110,0
dc.w	%0011111111111100,0
dc.w	%0001111111111000,0
dc.w	%0000011111100000,0
vb_mas4:
dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;---------------------------O B J E C T S----------------------------


vb_krzyz:
dc.w	24
dc.w	-2,1,3
dc.w	300

dc.w	-60,15,10,0
dc.w	-45,30,10,1
dc.w	-45,15,10,1
dc.w	-45,0,10,1
dc.w	-30,15,10,0
dc.w	-15,15,10,0
dc.w	0,60,10,0
dc.w	0,45,10,0
dc.w	0,30,10,0
dc.w	0,15,10,0
dc.w	0,0,10,0
dc.w	0,-15,10,0
dc.w	0,-30,10,0
dc.w	0,-45,10,0
dc.w	0,-60,10,0
dc.w	0,-75,10,0
dc.w	0,-90,10,0
dc.w	0,-105,10,0
dc.w	15,15,10,0
dc.w	30,15,10,0
dc.w	45,30,10,1
dc.w	45,15,10,1
dc.w	45,0,10,1
dc.w	60,15,10,0
dc.w	0,$aa0,$a70,$ad0,0,$a0,$70,$d0

vb_amiga:
dc.w	62,-2,-3,2,200

dc.w	-150,0,0,0
dc.w	-150,10,0,0
dc.w	-150,20,0,0
dc.w	-150,30,0,1
dc.w	-150,40,0,1
dc.w	-135,20,0,0
dc.w	-135,40,0,1
dc.w	-120,20,0,0
dc.w	-120,40,0,1
dc.w	-105,0,0,0
dc.w	-105,10,0,0
dc.w	-105,20,0,0
dc.w	-105,30,0,1
dc.w	-105,40,0,1

dc.w	-75,0,0,0
dc.w	-75,10,0,0
dc.w	-75,20,0,0
dc.w	-75,30,0,1
dc.w	-75,40,0,1
dc.w	-60,40,0,1
dc.w	-45,20,0,0
dc.w	-45,30,0,1
dc.w	-45,40,0,1
dc.w	-30,40,0,1
dc.w	-15,0,0,0
dc.w	-15,10,0,0
dc.w	-15,20,0,0
dc.w	-15,30,0,1
dc.w	-15,40,0,1

dc.w	15,0,0,0
dc.w	15,10,0,0
dc.w	15,20,0,0
dc.w	15,30,0,1
dc.w	15,40,0,1

dc.w	45,0,0,0
dc.w	45,10,0,0
dc.w	45,20,0,0
dc.w	45,30,0,1
dc.w	45,40,0,1
dc.w	60,0,0,0
dc.w	60,40,0,1
dc.w	75,0,0,0
dc.w	75,20,0,0
dc.w	75,40,0,1
dc.w	90,0,0,0
dc.w	90,10,0,0
dc.w	90,20,0,0
dc.w	90,40,0,1

dc.w	120,0,0,0
dc.w	120,10,0,0
dc.w	120,20,0,0
dc.w	120,30,0,1
dc.w	120,40,0,1
dc.w	135,20,0,0
dc.w	135,40,0,1
dc.w	150,20,0,0
dc.w	150,40,0,1
dc.w	165,0,0,0
dc.w	165,10,0,0
dc.w	165,20,0,0
dc.w	165,30,0,1
dc.w	165,40,0,1
dc.w	0,$888,$666,$777,0,$a00,$700,$d00

