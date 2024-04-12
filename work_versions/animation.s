
;   ANIM REPLAYER CODED TO DEMO PREPARED FOR ZYWIEC C-PARTY
;	    CODED BY KANE AND PILLAR FROM SCT'92.


LoadTo=$40000
TamTo=$c25000

Load8=$60000
tamto2=$40000

>extern	"df0:part28f",Loadto,-1
>extern	"df0:part8L",Load8,-1

mt_data=$30000
>extern	"CODE DISK_3:.store/mod.half_time.pro",mt_data,-1

;-------------------------------------------------------------------

org	$20000
load	$20000

raster: macro
wait?0:	cmp.b	#$fe,$dff006
	bne	wait?0
	cmpi.b	#$ff,$dff006
	bne	wait?0+12
	endm

s:
;	lea	Loadto,a0
;	lea	Tamto,a1
;	move.l	#248564,d0
;	bsr	decrunch
;rts

;	lea	Load8,a0
;	lea	Tamto2,a1
;	move.l	#72408,d0
;	bsr	decrunch
;rts


;----------------------------glowny kod-------------------------

s_code:	move.l	(sp)+,return	;aby umozliwic wyjscie z przerwania
	movem.l	a0-a6/d0-d7,-(sp)
	move	$dff002,olddma
	ori	#$8000,olddma
	move	$dff01c,oldint
	ori	#$8000,oldint
	move	#$3ff,$dff096
	move	#$7fff,$dff09a
	bsr	mt_init
	move.l	$6c,oldlev
	move.l	#newlev,$6c
	move	#$c020,$dff09a
	move	#%1000011111110000,$dff096

	bsr	MAIN

quit:	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	$32(a0),$dff080
	move	olddma,$dff096
	move	#$7fff,$dff09a
	move	#$4000,$dff09a
	move.l	oldlev,$6c
	move	#$c000,$dff09a
	bsr	mt_end
	move.l	oldint,$dff09a
	movem.l	(sp)+,a0-a6/d0-d7
	move.l	return,a0
	jmp	(a0)		;jak mowi Pillar 'fajrant'

newlev:	movem.l	d0-d7/a0-a6,-(sp)
	bsr	mt_music
	movem.l	(sp)+,d0-d7/a0-a6
	btst	#6,$bfe001
	bne	nopress
	move	(sp)+,storee
	move.l	(sp)+,adress
	move.l	#quit,-(sp)
	move	storee,-(sp)
nopress:move	#$20,$dff09c
	rte

storee:		dc.w	0
adress:		dc.l	0

return:		dc.l	0
oldint:		dc.w	0
olddma:		dc.w	0
oldlev:		dc.l	0


MAIN:	move.l	#copperx,$dff080
	clr	$dff088
Mloop:	bsr.s	Siner
	bsr.L	scroll1			;main looooooooop
	tst	nodalej
	bne	start
	bra.s	Mloop

nodalej:	dc.w	0
;*----------------------------------------------------

Siner:	moveq	#0,d0
	move.w	Angle,d0
	lsl.w	#1,d0
	lea	Sin,a0
	lea	LSH,a1
	adda.w	d0,a0
	moveq	#28,d6
left:	move.w	(a0)+,2(a1)
	adda.l	#24,a1
	dbf	d6,left
	addq.w	#1,angle
	cmp.w	#41,angle
	bge.s	ustol
	rts
Ustol:	move.w	#0,angle
	rts

;*----------------------------------------------------
; SCROLL 1

Scroll1:cmp.w	#1,Con1
	beq.s	Shifter1
	move.l	textpointer1,a0
	moveq	#0,d1
	move.l	#43,d7
Wszyst1:moveq	#0,d0
	move.l	#7,d6
	lea	font,a1
	lea	$70000,a2

	move.b	(a0)+,d0
	tst.b	d0
	bne.L	lltart
	move	#-1,nodalej
	rts
lltart:	sub.w	#32,d0
	mulu	#8,d0
Litera1:move.b	0(a1,d0.w),0(a2,d1.w)		
	adda.l	#44,a2
	addq.w	#1,d0
	dbf	d6,litera1
	addq.w	#1,d1
	dbf	d7,wszyst1
	
	add.l	#1,textpointer1
	move.w	#1,Con1
	rts

UsText1:move.l	#text,textpointer1
	rts

Shifter1:
	cmpi.b	#250,$dff006
	bne.s	shifter1
	move.l	#$70000,d1	;src. / dest.
	move.l	#$70000,d2
	move.w	#%1000100100001000,d3 
	bsr.s	Shift
	subq.w	#1,Con1
	rts

Con1:		dc.w	0
TextPointer1:	dc.l 	text

;*--------------------------------------------------------
; BLITTER SHIFTER ROUTINE (((((S))))) !


shift:	bsr.s	waitblt
	lea	$dff000,a6
	clr.w	$dff042
	move.l	d1,$50(a6)		;src
	move.l	d2,$54(a6)		;dest
	move.w	d3,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.w	#$0000,$64(a6)		;A mod
	move.w	#$0000,$66(a6)		;D mod
	move.w	#%0000001000010101,$58(a6)
	bsr.s	waitblt
	rts

;*------------------------------------------------------
; WAIT BLIITER .

Waitblt:btst	#6,$dff002
	bne	Waitblt
	rts

;------------------------------------------------------

; 			ANIMACJA


start:	lea	colr,a0
	move.l	#24,d7
fdx:	move.w	2(a0),d0
	tst.w	d0
	beq.s	dolp
hopsiup:subq.w	#$0001,d0
	move.w	d0,2(a0)
dolp:	adda.l	#24,a0
	dbf	d7,fdx


	move	#3216,d0
	lea	$70000,a0
clrit:	move.l	#0,(a0)+
	dbf	d0,clrit

	raster
	move.l	#copper,$dff080
	clr	$dff088

	lea	pasek1,a0
	lea	pasek2,a1
	move	#$a0,d0
	move	#$a1,d1
pdx:	raster
	move.b	d0,(a0)
	move	d0,d2
	addi	#1,d2
	move.b	d2,8(a0)
	move.b	d1,(a1)
	move	d1,d2
	addi	#1,d2
	move.b	d2,8(a1)
	subi	#2,d0
	addi	#2,d1
	cmpi	#$5a,d0
	bne	pdx
	lea	wlacz,a0
	move.b	#$60,(a0)
	move.b	#$e0,8(a0)
	move.b	#$53,6(a0)
		
	move.l	APointer,a0		;kopiuj klatke
	move.l	(a0),a0
	move.l	Ekran,a1
	move.l	#12864,d0
cp:	move.b	(a0)+,(a1)+
	dbf	d0,cp

	bsr.L	ColIN

;-----------------------ANIMACJA  -  KONTROLA--------------------

	move	#3,Alicz
	move	#2,Await
	move.l	#4,Adod
	bsr	Anim
	move	#3,Alicz
	move.l	#-4,Adod
	bsr	Anim
	move	#1,Alicz
	move	#1,Await
	bsr	Anim
	move	#1,Alicz
	move	#0,Await
	bsr	Anim
	move	#1,Alicz
	move	#1,Await
	bsr	Anim
	move	#1,Alicz
	move	#2,Await
	bsr	Anim
	move	#1,Alicz
	move	#3,Await
	bsr	Anim
	move	#1,Alicz
	move.l	#4,Adod
	bsr	Anim
	move	#3,Alicz
	move	#2,Await
	bsr	Anim

	move	#50,d0
ppwi:	raster
	dbf	d0,ppwi

	bsr.L	ColOut

	lea	wlacz,a0
	move.b	#3,6(a0)
	move.b	#$a1,(a0)
	move.b	#$a1,8(a0)
	lea	pasek1,a0
	lea	pasek2,a1
	move	#$5a,d0
	move	#$e5,d1
pdx2:	raster
	move.b	d0,(a0)
	move	d0,d2
	addi	#1,d2
	move.b	d2,8(a0)
	move.b	d1,(a1)
	move	d1,d2
	addi	#1,d2
	move.b	d2,8(a1)
	addi	#2,d0
	subi	#2,d1
	cmpi	#$a0,d0
	bne	pdx2
	move.b	#$a0,(a0)
	move.b	#$a1,8(a0)
	move.b	#$a2,(a1)
	move.b	#$a3,8(a1)

	move	#20,d0
pwwiq:	raster
	dbf	d0,pwwiq

	move.l	#9,d7
pdy:	raster
	subi	#$11,6(a0)
	subi	#$11,6(a1)
	dbf	d7,pdy

	move	#200,d0
ppwiq:	raster
	dbf	d0,ppwiq
	rts


;---------- INICJACJA : 1 KLATKA ----------------------------

Anim:	move	Await,d0
Anim2:	raster
	dbf	d0,Anim2
	eor.l	#12864,ekran	;NORMALNA PETLA ....
	move.l	ekran,a1
	move.l	Apointer,a0
	move.l	(a0),a0
	move.l	#3216,d0
cp2:	move.l	(a0)+,(a1)+
	dbf	d0,cp2

	move.l	Ekran,d0
	lea	Screen,a0
	move.l	#4,d1
bpl:	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#2560,d0
	adda.l	#8,a0
	dbf	d1,bpl

	lea	Colors,a0
	move.l	ekran,a1
	adda.l	#12800,a1
	move.l	#31,d0
COLS:	move.w	(a1)+,2(a0)
	adda.l	#4,a0
	dbf	d0,COLS
	move.l	Adod,d0
	add.l	d0,Apointer
	move.l	Apointer,a0
	lea	TabEnd,a1
	lea	Tabstrt,a2
	cmpa.l	a0,a2
	beq	nakoniec
	cmpa.l	a0,a1
	bne.s	HejHop
	move.l	#Atable,Apointer
	subi	#1,Alicz
	bra	hejhop
nakoniec:move.l	#Tabend-4,Apointer
	subi	#1,Alicz

Hejhop:	tst	Alicz
	bne	Anim
	rts

Gfxname:	dc.b	"graphics.library",0,0
Ekran:		dc.l	$70000
APointer:	dc.l	Atable
Adod:		dc.l	0
Await:		dc.w	0
Alicz:		dc.w	0

;-------------------wchodzenie kolorow---------------------

ColIN:	move	#15,d0
setcol:	lea	colors,a1
	move.l	Ekran,a2
	adda.l	#12800,a2
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

;-------------------wychodzenie kolorow---------------------

ColOut:	move	#15,d0
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

;-------------------------------------------------------------------
;	FUCKLESS DATAS COMING UP ......


copper:	dc.l $01200000,$01220000,$01240000,$01260000,$01280000,$012a0000
	dc.l $012c0000,$012e0000,$01300000,$01320000,$01340000,$01360000
	dc.l $01380000,$013a0000,$013c0000,$013e0000
	dc.l $00920060,$009400a8,$008e0171,$009037d1,$01800000
	dc.l $01020000,$01040000,$01080000,$010a0000	

screen:	dc.l	$00e00007,$00e20000
	dc.l	$00e40007,$00e60000+[2560]
	dc.l	$00e80007,$00ea0000+[2*2560]
	dc.l	$00ec0007,$00ee0000+[3*2560]
	dc.l	$00f00007,$00f20000+[4*2560]

pasek1:	dc.l	$a001ff00,$018000aa	; pasek gorny
	dc.l	$a101ff00,$01800000

colors:	dc.l	$01800000,$01820000,$01840000,$01860000
	dc.l	$01880000,$018a0000,$018c0000,$018e0000
	dc.l	$01900000,$01920000,$01940000,$01960000
	dc.l	$01980000,$019a0000,$019c0000,$019e0000
	dc.l	$01a00000,$01a20000,$01a40000,$01a60000
	dc.l	$01a80000,$01aa0000,$01ac0000,$01ae0000
	dc.l	$01b00000,$01b20000,$01b40000,$01b60000
	dc.l	$01b80000,$01ba0000,$01bc0000,$01be0000

wlacz:	dc.l	$a101ff00,$01000300	;i juz 5 bpl.
	dc.l	$a101ff00,$01000300

pasek2:	dc.l	$a101ff00,$018000aa	; pasek dolny
	dc.l	$a101ff00,$01800000
	dc.l	$fffffffe

;-------- TABLICA KOLEINYCH KLATEK -----------


tabstrt:dc.l	0
Atable:	dc.l	tamto
	dc.l	tamto+12864
	dc.l	tamto+[2*12864]
	dc.l	tamto+[3*12864]
	dc.l	tamto+[4*12864]
	dc.l	tamto+[5*12864]
	dc.l	tamto+[6*12864]
	dc.l	tamto+[7*12864]
	dc.l	tamto+[8*12864]
	dc.l	tamto+[9*12864]
	dc.l	tamto+[10*12864]
	dc.l	tamto+[11*12864]
	dc.l	tamto+[12*12864]
	dc.l	tamto+[13*12864]
	dc.l	tamto+[14*12864]
	dc.l	tamto+[15*12864]
	dc.l	tamto+[16*12864]
	dc.l	tamto+[17*12864]
	dc.l	tamto+[18*12864]
	dc.l	tamto+[19*12864]
	dc.l	tamto+[20*12864]
	dc.l	tamto+[21*12864]
	dc.l	tamto+[22*12864]
	dc.l	tamto+[23*12864]
	dc.l	tamto+[24*12864]
	dc.l	tamto+[25*12864]
	dc.l	tamto+[26*12864]
	dc.l	tamto+[27*12864]
	dc.l	tamto2
	dc.l	tamto2+[12864]
	dc.l	tamto2+[2*12864]
	dc.l	tamto2+[3*12864]
	dc.l	tamto2+[4*12864]
	dc.l	tamto2+[5*12864]
	dc.l	tamto2+[6*12864]
	dc.l	tamto2+[7*12864]
TabEnd:	dc.l	0


Text:	dc.b "                                          "
	dc.b "AFTER A LONG LOADING AND DECRUNCHING JUST "
	dc.b "ENJOY AN EXCELLENT 36-FRAME TEMPLE ANIMATION "
	DC.B "CREATED BY  ARTB... PLEASE SIT COMFORTABLY AND WATCH ...."
	dc.b "...............                             "
	DC.B "                                   ",0
even

Copperx:dc.w $0180,$0000,$0182,$0000
	dc.w $008e,$0171,$0090,$37d1
	dc.w $0092,$0030,$0094,$00d8
	dc.w $0120,$0000,$0122,$0000
	dc.w $0124,$0000,$0126,$0000
	dc.w $0128,$0000,$012a,$0000
	dc.w $012c,$0000,$012e,$0000
	dc.w $0130,$0000,$0132,$0000
	dc.w $0134,$0000,$0136,$0000
	dc.w $0138,$0000,$013a,$0000
	dc.w $013c,$0000,$013e,$0000

	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0001
lsh:	dc.w $0102,$0000
	dc.w $1801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
colr:	dc.w $0182,$0001
	dc.w $0102,$0000
	dc.w $2001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0002
	dc.w $0102,$0000
	dc.w $2801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0003
	dc.w $0102,$0000
	dc.w $3001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0004
	dc.w $0102,$0000
	dc.w $3801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0005
	dc.w $0102,$0000
	dc.w $4001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0006
	dc.w $0102,$0000
	dc.w $4801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0007
	dc.w $0102,$0000
	dc.w $5001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0008
	dc.w $0102,$0000
	dc.w $5801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0009
	dc.w $0102,$0000
	dc.w $6001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000a
	dc.w $0102,$0000
	dc.w $6801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000b
	dc.w $0102,$0000
	dc.w $7001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000c
	dc.w $0102,$0000
	dc.w $7801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000d
	dc.w $0102,$0000
	dc.w $8001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000e
	dc.w $0102,$0000
	dc.w $8801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000f
	dc.w $0102,$0000
	dc.w $9001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000e
	dc.w $0102,$0000
	dc.w $9801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000d
	dc.w $0102,$0000
	dc.w $a001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000c
	dc.w $0102,$0000
	dc.w $a801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000b
	dc.w $0102,$0000
	dc.w $b001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$000a
	dc.w $0102,$0000
	dc.w $b801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0009
	dc.w $0102,$0000
	dc.w $c001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0008
	dc.w $0102,$0000
	dc.w $c801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0007
	dc.w $0102,$0000
	dc.w $d001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0006
	dc.w $0102,$0000
	dc.w $d801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0005
	dc.w $0102,$0000
	dc.w $e001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0004
	dc.w $0102,$0000
	dc.w $e801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0003
	dc.w $0102,$0000
	dc.w $f001,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$1200
	dc.w $0182,$0002
	dc.w $0102,$0000
	dc.w $f801,$fffe
	dc.w $00e0,$0007,$00e2,$0000,$0100,$0200
	dc.w $0182,$0000
	dc.w $0102,$0000
	dc.w $ffff,$fffe

Angle:	dc.w 0

Sin:
	dc.w	$0008,$0009,$000A,$000B,$000C,$000D,$000E,$000F
	dc.w	$000F,$000F,$000F,$000F,$000F,$000F,$000E,$000D
	dc.w	$000D,$000C,$000A,$0009,$0008,$0008,$0007,$0006
	dc.w	$0004,$0003,$0003,$0002,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0002,$0003,$0004,$0005,$0006,7
	dc.w	$0008,$0009,$000A,$000B,$000C,$000D,$000E,$000F
	dc.w	$000F,$000F,$000F,$000F,$000F,$000F,$000E,$000D
	dc.w	$000D,$000C,$000A,$0009,$0008,$0008,$0007,$0006
	dc.w	$0004,$0003,$0003,$0002,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0002,$0003,$0004,$0005,$0006,7

FONT:
dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;" "
dc.b	$EE,$EE,$EE,$EE,$EE,$00,$EE,$00	;"!"
dc.b	$66,$EE,$EE,$CC,$00,$00,$00,$00	;"""
dc.b	$6C,$FE,$FE,$6C,$FE,$FE,$6C,$00	;"#"
dc.b	$18,$7E,$F0,$7C,$1E,$FC,$30,$00	;"$"
dc.b	$E6,$EE,$DC,$38,$76,$EE,$CE,$00	;"%"
dc.b	$7C,$EE,$EE,$7C,$EE,$EE,$76,$00	;"&"
dc.b	$38,$38,$30,$00,$00,$00,$00,$00	;"'"
dc.b	$1C,$38,$70,$70,$70,$38,$1C,$00	;"("
dc.b	$70,$38,$1C,$1C,$1C,$38,$70,$00	;")"
dc.b	$18,$5A,$3C,$FF,$3C,$5A,$18,$00	;"*"
dc.b	$00,$18,$18,$7E,$7E,$18,$18,$00	;"+"
dc.b	$00,$00,$00,$00,$18,$38,$38,$30	;","
dc.b	$00,$00,$00,$7E,$7E,$00,$00,$00	;"-"
dc.b	$00,$00,$00,$00,$38,$38,$38,$00	;"."
dc.b	$03,$07,$0E,$1C,$38,$70,$E0,$C0	;"/"
dc.b	$7C,$EE,$EE,$FE,$EE,$EE,$7C,$00	;"0"
dc.b	$38,$38,$38,$78,$38,$38,$FE,$00	;"1"
dc.b	$FC,$EE,$0E,$7C,$E0,$FE,$FE,$00	;"2"
dc.b	$FC,$EE,$0E,$1C,$0E,$EE,$FC,$00	;"3"
dc.b	$EE,$EE,$EE,$7E,$0E,$0E,$0E,$00	;"4"
dc.b	$FE,$EE,$E0,$FC,$0E,$EE,$FC,$00	;"5"
dc.b	$7E,$EE,$E0,$FC,$EE,$EE,$7C,$00	;"6"
dc.b	$FE,$EE,$0E,$3C,$38,$38,$38,$00	;"7"
dc.b	$7C,$EE,$EE,$7C,$EE,$EE,$7C,$00	;"8"
dc.b	$7C,$EE,$EE,$7E,$0E,$EE,$FC,$00	;"9"
dc.b	$38,$38,$38,$00,$38,$38,$38,$00	;":"
dc.b	$38,$38,$38,$00,$18,$38,$38,$30	;";"
dc.b	$1C,$38,$70,$E0,$70,$38,$1C,$00	;"<"
dc.b	$00,$7E,$7E,$00,$7E,$7E,$00,$00	;"="
dc.b	$70,$38,$1C,$0E,$1C,$38,$70,$00	;">"
dc.b	$FC,$EE,$0E,$3C,$38,$00,$38,$00	;"?"
dc.b	$7C,$EE,$EE,$EE,$EE,$E0,$7E,$00	;"@"
dc.b	$7C,$EE,$EE,$FE,$EE,$EE,$EE,$00	;"A"
dc.b	$FC,$EE,$EE,$FC,$EE,$EE,$FC,$00	;"B"
dc.b	$7C,$EE,$EE,$E0,$EE,$EE,$7C,$00	;"C"
dc.b	$FC,$EE,$EE,$EE,$EE,$EE,$FC,$00	;"D"
dc.b	$7E,$EE,$E0,$F0,$E0,$EE,$7E,$00	;"E"
dc.b	$7E,$EE,$E0,$F0,$E0,$E0,$E0,$00	;"F"
dc.b	$7C,$EE,$E0,$EE,$EE,$EE,$7E,$00	;"G"
dc.b	$EE,$EE,$EE,$FE,$EE,$EE,$EE,$00	;"H"
dc.b	$FE,$38,$38,$38,$38,$38,$FE,$00	;"I"
dc.b	$FE,$EE,$0E,$3E,$0E,$EE,$7C,$00	;"J"
dc.b	$EE,$EE,$EE,$FC,$EE,$EE,$EE,$00	;"K"
dc.b	$E0,$E0,$E0,$E0,$E0,$EE,$7E,$00	;"L"
dc.b	$C6,$EE,$FE,$EE,$EE,$EE,$EE,$00	;"M"
dc.b	$CE,$EE,$FE,$EE,$EE,$EE,$EE,$00	;"N"
dc.b	$7C,$EE,$EE,$EE,$EE,$EE,$7C,$00	;"O"
dc.b	$FC,$EE,$EE,$FC,$E0,$E0,$E0,$00	;"P"
dc.b	$7C,$EE,$EE,$EE,$EE,$EE,$7E,$00	;"Q"
dc.b	$FC,$EE,$EE,$FC,$EE,$EE,$EE,$00	;"R"
dc.b	$7E,$EE,$E0,$7C,$0E,$EE,$FC,$00	;"S"
dc.b	$FE,$38,$38,$38,$38,$38,$7C,$00	;"T"
dc.b	$EE,$EE,$EE,$EE,$EE,$EE,$7E,$00	;"U"
dc.b	$EE,$EE,$EE,$EE,$EC,$F8,$70,$00	;"V"
dc.b	$EE,$EE,$EE,$EE,$FE,$EE,$C6,$00	;"W"
dc.b	$EE,$EE,$EE,$7C,$EE,$EE,$EE,$00	;"X"
dc.b	$EE,$EE,$EE,$7C,$38,$38,$7C,$00	;"Y"
dc.b	$FE,$EE,$0E,$7C,$E0,$EE,$FE,$00	;"Z"

;-------------------------------muzyka--------------------

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


;-----------------DECRUNCH-------------------------------------

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

end:

