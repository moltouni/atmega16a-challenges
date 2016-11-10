;
; interrupts_two_modes_run_blink.asm
;
; Created: 11/10/2016 12:00:04 PM
; Author : Mario Novak
;

/*
    CHALLENGE

    INT0
        - running LED lights
    INT1
        - blink (1010 1010)

    Delay between each action is 1 second.
*/

.def tmp1 = r16
.def tmp2 = r17
.def mode = r21
.def prevMode = r22

.equ delay_cnt = 19

.org 0x002
	rjmp int0_sub
.org 0x004
	rjmp int1_sub

.cseg
	rjmp reset

reset:
	ldi tmp1, LOW(RAMEND)
	out SPL, tmp1

	ldi tmp1, HIGH(RAMEND)
	out SPH, tmp2

	ldi tmp1, 0xff
	out DDRA, tmp1

	; turn off all LEDs
	ldi tmp1, 0xff
	out PORTA, tmp1

	; set mode to 0 - running LEDS
	ldi mode, 0x01
	mov prevMode, mode

	; prepare INT0 and INT1 interrupts
	ldi tmp1, (1 << INT0) | (1 << INT1)
	out GICR, tmp1

	ldi tmp1, (1 << ISC00) | (1 << ISC01) | (1 << ISC10) | (1 << ISC11)
	out MCUCR, tmp1

	sei


main:

	sbrc mode, 0
	rcall run

	sbrc mode, 1
	rcall blink

	rcall delay

    rjmp main

int0_sub:
	mov prevMode, mode
	ldi mode, 0x01
	rcall router
	reti

int1_sub:
	mov prevMode, mode
	ldi mode, 0x02
	rcall router
	reti

routerResetLeds:
	sbrc mode, 0
	ldi tmp1, 0xff
	sbrc mode, 1
	ldi tmp1, 0b10101010
	out PORTA, tmp1
	reti


router:
	cp mode, prevMode
	brne routerOut
	rcall routerResetLeds
routerOut:
	reti

blink:
	in tmp1, PORTA
	ldi tmp2, 0xff
	eor tmp1, tmp2
	out PORTA, tmp1
	reti

run:
	rcall runResetLeds
	in tmp1, PORTA
	clc
	rol tmp1
	out PORTA, tmp1
	reti

runResetLeds:
	in tmp1, PORTA
	cpi tmp1, 0x00
	brne leaveAsItIs
	ldi tmp1, 0xff
	out PORTA, tmp1
leaveAsItIs:
	reti

delay:
	clr r18
	clr r19
	ldi r20, delay_cnt

	delay_sub:
		dec r18
		brne delay_sub
			dec r19
			brne delay_sub
				dec r20
				brne delay_sub

	reti
