
.module ws2812test

PINOUT = 0
MAP_LOCATION = 0x100 ; needs to be 256 pword aligned

.include "pdk.asm"
.include "map.asm"

.area DATA (ABS)
.org 0x00

dither_p:           .ds 1
dither_p_hi:        .ds 1
wave_p:             .ds 1
wave_p_hi:          .ds 1
i:                  .ds 1
r:                  .ds 1
bytecount:          .ds 1
brightness:         .ds 1

.org 0x10
dither_map:         .ds 16 ; must be address 0x00

.area CODE (ABS)
.org 0x00

	clock_8mhz
	easypdk_calibrate 8000000, 3300

.macro nop2 ?l0
	goto l0
	l0:
.endm

.macro ani_init
	mov a, #0
	mov pa, a
	mov pac, a
	set1 pac, #PINOUT

	mov dither_map+0, a

	mov a,  #8
	mov dither_map+1, a

	mov a,  #4
	mov dither_map+2, a

	mov a,  #12
	mov dither_map+3, a

	mov a,  #2
	mov dither_map+4, a

	mov a,  #10
	mov dither_map+5, a

	mov a,  #6
	mov dither_map+6, a

	mov a,  #14
	mov dither_map+7, a

	mov a,  #1
	mov dither_map+8, a

	mov a,  #9
	mov dither_map+9, a

	mov a,  #5
	mov dither_map+10, a

	mov a,  #13
	mov dither_map+11, a

	mov a,  #3
	mov dither_map+12, a

	mov a,  #11
	mov dither_map+13, a

	mov a,  #7
	mov dither_map+14, a

	mov a,  #15
	mov dither_map+15, a

	mov a, #(dither_map-16)
	mov dither_p, a
	clear dither_p_hi
	mov a, #(MAP_LOCATION >> 8)
	mov wave_p_hi, a
	clear wave_p
	mov a, #wave_p
	mov sp, a

	clear i
.endm

ani_init

start:

mov a, i
mov r, a
dzsn dither_p
sub a, #3
add a, #3
mov i, a

mov a, #(64*3)       ; need to be a multiple of 16 not to mess up dithering
mov bytecount, a

loop:
	               set0 pa, #PINOUT     ; 7 + 1
	nop2                                ; 8 + 2

	               set1 pa, #PINOUT     ; 0 + 1
	mov a, r                            ; 1 + 1
	mov wave_p, a                       ; 2 + 1
	               set0 pa, #PINOUT     ; 3 + 1
	add a, #99                          ; 4 + 1
	mov r, a                            ; 5 + 1
	ldsptl                              ; 6 + 2
	mov brightness, a                   ; 8 + 1
	mov a, #15                          ; 9 + 1

	               set1 pa, #PINOUT     ; 0 + 1
	and dither_p, a                     ; 1 + 1
	set1 dither_p, #4                   ; 2 + 1
	               set0 pa, #PINOUT     ; 3 + 1
	idxm a, dither_p                    ; 4 + 2
	add brightness, a                   ; 6 + 1
	inc dither_p                        ; 7 + 1
	set0 dither_p, #4                   ; 8 + 1
	nop                                 ; 9 + 1

	               set1 pa, #PINOUT     ; 0 + 1
	nop2                                ; 1 + 2
	               set0 pa, #PINOUT     ; 3 + 1
	nop2                                ; 4 + 2
	nop2                                ; 6 + 2
	nop2                                ; 8 + 2

	               set1 pa, #PINOUT     ; 0 + 1
	nop2                                ; 1 + 2
	               set0 pa, #PINOUT     ; 3 + 1
	nop2                                ; 4 + 2
	nop2                                ; 6 + 2
	nop2                                ; 8 + 2

	               set1 pa, #PINOUT     ; 0 + 1
	nop                                 ; 1 + 1
	t1sn brightness, #7                 ; 2 + 1
	               set0 pa, #PINOUT     ; 3 + 1
	nop2                                ; 4 + 2
    nop                                 ; 6 + 1
	               set0 pa, #PINOUT     ; 7 + 1
	nop2                                ; 8 + 2


	               set1 pa, #PINOUT     ; 0 + 1
	nop                                 ; 1 + 1
	t1sn brightness, #6                 ; 2 + 1
	               set0 pa, #PINOUT     ; 3 + 1
	nop2                                ; 4 + 2
    nop                                 ; 6 + 1
	               set0 pa, #PINOUT     ; 7 + 1
	nop2                                ; 8 + 2


	               set1 pa, #PINOUT     ; 0 + 1
	nop                                 ; 1 + 1
	t1sn brightness, #5                 ; 2 + 1
	               set0 pa, #PINOUT     ; 3 + 1
	nop2                                ; 4 + 2
    nop                                 ; 6 + 1
	               set0 pa, #PINOUT     ; 7 + 1
	nop2                                ; 8 + 2


	               set1 pa, #PINOUT     ; 0 + 1
	nop                                 ; 1 + 1
	t1sn brightness, #4                 ; 2 + 1
	               set0 pa, #PINOUT     ; 3 + 1
	dzsn bytecount                      ; 4 + 1
	goto loop                           ; 5 + 2
;   nop                                 ; 6 + 1
mov a, #249                ;  1
	               set0 pa, #PINOUT     ; 7 + 1
;	nop2                                ; 8 + 2

waitloop:
nop
nop2                       ; 2n
nop2                       ; 2n
nop2                       ; 2n
dzsn a                     ;  n - 1
goto waitloop              ;  2

goto start

.org MAP_LOCATION*2
	color_map

