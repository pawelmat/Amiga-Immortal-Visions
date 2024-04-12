

;		*****************************************
;		*       SINUS COLOUR FLOAT TRAIL	*
;		*      Coding by KANE of SUSPECT	*
;		*	     on 20.02.1992		*
;		*****************************************
org $30000
load $30000

s:
	movem.l	a0-a6/d0-d7,-(sp)
	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,gfxbase
	move.l	d0,a0
	move.l	$32(a0),oldcop
	move.l	#tl_copper,$32(a0)
;	jsr	-132(a6)
	move.w	$dff002,olddma
	move.w	#%1000000111101111,$dff096

	bsr	tl_setup

	move.w	olddma,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.l	gfxbase,a0
	move.l	oldcop,$32(a0)
	move.l	4,a6
;	jsr	-138(a6)
	movem.l	(sp)+,a0-a6/d0-d7
	rts

gfxbase:	dc.l	0
oldcop:		dc.l	0
olddma:		dc.l	0
gfxname:	dc.b	'graphics.library',0,0

tl_copper:
dc.l	$920028,$9400d8,$8e0000,$90ffff
tl_cols:
dc.l	$1800000,$1820000,$1840000,$1860000
dc.l	$1880000,$18a0000,$18c0000,$18e0000
tl_scrn:
dc.l	$e00007,$e20000,$e40007,$e60000,$e80007,$ea0000
dc.l	$1020000,$1080000,$10a0000
dc.l	$4a01ff00,$01003200
dc.l	$fe01ff00,$01000200
dc.l	$fffffffe

;-------------------------------------------------------------------
tl_screen=$70000
tl_scron:	dc.l	tl_screen
		dc.l	tl_screen+8280
		dc.l	tl_screen+16560
tl_scroff:	dc.l	tl_screen+24840
		dc.l	tl_screen+33120
		dc.l	tl_screen+41400

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
tl_texture:	dc.w	0
tl_brflag:		dc.b	1
tl_ilval:		dc.b	0
tl_timer:		dc.w	1	;licznik czasu
tl_timval:		dc.w	0
tl_andcol:		dc.w	0
tl_colnum:		dc.w	0
tl_coltab:		blk.w	8,0	;tablica kolorow
;-------------------------------------------------------------------
tl_setup:
	move.l	#$dff000,a0
	move.l	#$ffffffff,$44(a0)	
	bsr	tl_newobject
tl_control:
	cmpi.b	#$ff,$dff006
	bne	tl_control
	bsr	tl_trail
	cmpi	#$aaaa,tl_timval
	beq	tl_out
	btst.b	#6,$bfe001
	bne	tl_control
tl_out:	rts

tl_trail:
	lea	tl_scron,a1	;pozamieniaj ekrany
	lea	tl_scroff,a2
	move.l	(a1),d0
	move.l	(a2),d1
	move.l	d1,(a1)
	move.l	d0,(a2)
	move	d1,tl_scrn+6
	swap	d1
	move	d1,tl_scrn+2
	move.l	4(a1),d0
	move.l	4(a2),d1
	move.l	d1,4(a1)
	move.l	d0,4(a2)
	move	d1,tl_scrn+14
	swap	d1
	move	d1,tl_scrn+10
	move.l	8(a1),d0
	move.l	8(a2),d1
	move.l	d1,8(a1)
	move.l	d0,8(a2)
	move	d1,tl_scrn+22
	swap	d1
	move	d1,tl_scrn+18
tl_wait1:	btst.b	#14,$2(a0)	;czysc screen off
	bne	tl_wait1
	clr	$66(a0)
	move.l	#$1000000,$40(a0)
	move.l	(a2),$54(a0)
	move	#[3*tl_heith*64]+[tl_row/2],$58(a0)

	lea	tl_sinus,a1	;oblicz pozycje 1 linii (4 punkty)
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
tl_trloop:	move.l	tl_scroff,tl_drawaddr
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
	move	#$ffff,tl_texture
	btst	#0,d6
	bne	tl_tr1
	move.w	#0,tl_texture
tl_tr1:	bsr	tl_makeline
	add.l	#8280,tl_drawaddr
	move.w	#$ffff,tl_texture
	btst	#1,d6
	bne	tl_tr2
	move.w	#0,tl_texture
tl_tr2:	bsr	tl_makeline
	add.l	#8280,tl_drawaddr
	move.w	#$ffff,tl_texture
	btst	#2,d6
	bne	tl_tr3
	move.w	#0,tl_texture
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

tl_bright:	addi.b	#1,tl_ilval	;pojasnij kolory 
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
	movem.l	d0-d7,-(sp)
wait2:	btst	#14,2(a0)
	bne	wait2	
	cmp.w	d1,d3
	bge	p1
	exg	d2,d0
	exg	d1,d3
p1:	addq	#1,d1
	moveq	#$f,d4	
	and.w	d2,d4
	sub.w	d3,d1
	neg.w	d1
	mulu	#tl_row,d3		;wys. linii * szer. ekranu
	sub.w	d2,d0
	blt	p5
	cmp.w	d0,d1
	bge	p4
	moveq	#$19,d7
	bra	p9
p4:	moveq	#$5,d7 
	exg	d0,d1
	bra	p9
p5:	neg.w	d0
	cmp.w	d0,d1
	bge	p8
	moveq	#$1d,d7
	bra	p9
p8:	moveq	#$d,d7
	exg	d0,d1
p9:	asl.w	#1,d1
	asr.w	#$3,d2
	ext.l	d2
	add.l	d2,d3
	move.w	d1,d2
 	sub.w	d0,d2 
	bge	p10
	ori.w	#$40,d7
p10:	move.w	d2,d6
	move.w	d1,$62(a0)
	move.w	d2,d1	
	sub.w	d0,d1
	move.w	d1,$64(a0)
	move.w	#tl_row,$60(a0)	;szerokosc ekranu
	addq.w	#1,d0
	asl.w	#6,d0
	addq.w	#2,d0
	ror.l	#4,d4
	or.l	d4,d7
	move.w	#$8000,$74(a0)
	ori.l	#$bca0000,d7
	add.l	tl_drawaddr,d3	;rastport
	move.l	d7,$40(a0)
	move.w	d6,$52(a0)
	move.l	d3,$48(a0)
	move.l	d3,$54(a0)
	move.w	tl_texture,$72(a0)
	move.w	d0,$58(a0)
	movem.l	(sp)+,d0-d7
	rts

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
dc.w	63		;ilosc linii - najlepiej wielokrotnosc 7
dc.w	70		;czas obiektu na ekranie
dc.w	$0ff		;ktore kolory uzywane (RGB)
dc.w	$ee,$cc,$aa,$88,$66,$44,$22	;7 kolorow od jasnego do ciemnego-musza byc rowne wartosci RGB (wybrane wyzej)!!!
dc.w	20,250,760,800	;poczatkowe katy x1,y1,x2,y2
dc.w	34,-18,20,-28	;szybkosc calosci
dc.w	8,-6,4,-10	;szybkosc poszczegolnych linii

tl_ob2:
dc.w	63
dc.w	70
dc.w	$f0f
dc.w	$f0f,$d0d,$b0b,$909,$707,$505,$303
dc.w	200,26,60,900
dc.w	30,-10,20,-16
dc.w	10,-4,8,-12

tl_ob3:
dc.w	70
dc.w	70
dc.w	$f00
dc.w	$f00,$e00,$d00,$b00,$900,$700,$400
dc.w	200,526,960,340
dc.w	16,-18,36,-6
dc.w	10,-14,18,-2

tl_ob4:
dc.w	77
dc.w	70
dc.w	$f0
dc.w	$f0,$d0,$b0,$90,$70,$50,$30
dc.w	2,100,600,700
dc.w	10,-28,46,-16
dc.w	6,-4,8,-12

tl_ob5:
dc.w	70
dc.w	70
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

