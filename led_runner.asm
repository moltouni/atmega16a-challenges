;
; LEDRunner.asm
;
; Created: 11/10/2016 12:00:04 PM
; Author : Mario Novak
;

; Napravite program koji pali LED-ice od zadnje ka prvoj puˇstaju´ci
; prethodne upaljene sa vremenom izmedu paljenja dvije diode od 250 ms.
; Poˇcetno stanje su sve LED-ice ugaˇsene, a kada se sve LED-ice upale,
; krenuti od poˇcetnog stanja. Priloˇziti proraˇcun delay funkcije.


.def tmp1 = r16
.def tmp2 = r17

.equ delay_cnt = 19

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

main:

	rcall run
	rcall delay
	rcall resetLeds

    rjmp main

run:
	in tmp1, PORTA
	clc
	rol tmp1
	out PORTA, tmp1
	reti

resetLeds:
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
