;
; router_blinking_subroutines.asm
;
; Created: 10/28/2016 6:07:03 PM
; Author : Mario Novak
;
; Zadatak
;
; Implementirajte zadatke 2-4 sa proˇslih vjeˇzbi kao odvojene aktivnosti koje
; se pokre´cu pritiskom na odgovaraju´cu tipku te se izvrˇsavaju dok se
; sljede´ca tipka ne pritisne. Tipka 1 i dalje ima funkciju iz prvog zadatka.
; U main petlji se izvrˇsava polling pinova te pozivi za subrutine za
; aktivnosti i jedan na delay subrutinu
; Subrutine za aktivnosti sadrˇze logiku blinkanja bez delay funkcije
; Potrebno pamtiti koja se aktivnost odvija - kontrolna varijabla
;

.def tmp = r16
.def mod = r20
.def tmp1 = r22
.def prevMod = r21

.cseg

rjmp reset

reset:
	ldi tmp, LOW(RAMEND)
	out SPL, tmp
	ldi tmp, HIGH(RAMEND)
	out SPH, tmp

	; pull up on PINB0
	ldi tmp, (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3)
	out PORTB, tmp

	; B port is input
	ldi tmp, 0x00
	out DDRB, tmp

	; A port is output
	ldi tmp, 0xff
	out DDRA, tmp
	ldi tmp, 0xff
	out PORTA, tmp

	ldi mod, 0x00

main:

	mov prevMod, mod

	sbis PINB, 0
	ldi mod, 0x01

	sbis PINB, 1
	ldi mod, 0x02

	sbis PINB, 2
	ldi mod, 0x04

	sbis PINB, 3
	ldi mod, 0x08

	rcall router
	rcall delay

    rjmp main

resetPorts:

	ldi tmp, 0xff

	sbrc mod, 2
	ldi tmp, 0b11101111

	out PORTA, tmp

	ret

router:

	cp mod, prevMod
	breq nastavi

	rcall resetPorts

	nastavi:

		sbrc mod, 0
		rcall prog0

		sbrc mod, 1
		rcall prog1

		sbrc mod, 2
		rcall prog2

		sbrc mod, 3
		rcall prog3

	ret

prog0:
	in tmp, PORTA
	ldi tmp1, 0x01
	eor tmp, tmp1
	out PORTA, tmp
	ret

prog1:
	in tmp, PORTA
	ldi tmp1, 0x08
	eor tmp, tmp1
	out PORTA, tmp
	ret

prog2:
	in tmp, PORTA
	rol tmp
	out PORTA, tmp
	ret

prog3:
	ldi tmp, 0xff
	out PORTA, tmp
	rcall delay
	ldi tmp, 0b11110111
	out PORTA, tmp
	ret

delay:
	clr r17
	clr r18
	ldi r19, 15

	delay_cnt:
		dec r17
		brne delay_cnt
			dec r18
			brne delay_cnt
				dec r19
				brne delay_cnt
	ret
