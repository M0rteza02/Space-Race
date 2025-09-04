.equ P1_CHAN = PC3
.equ P2_CHAN = PC1

JOYSTICK:
	push r16
	push r17
	// Player 1
	clr r16
	sts PLAYER_TURN, r16
	lds r16, ADMUX
	andi r16, 0xFC
	ori r16, P1_CHAN
	call AD_CONVERSION
	lds r17, P1_POS
	call MOVE_PLAYER
	sts P1_POS, r17
	ldi r16, 0x10
	// Player 2
	ldi r16, 0x01
	sts PLAYER_TURN, r16
	lds r16, ADMUX
	andi r16, 0xFC
	ori r16, P2_CHAN
	call AD_CONVERSION
	lds r17, P2_POS
	call MOVE_PLAYER
	sts P2_POS, r17
	ldi r16, 0x08
	pop r17
	pop r16
	ret

AD_CONVERSION:
	sts ADMUX, r16
	lds r16, ADCSRA
	ori r16, (1<<ADSC)
	sts ADCSRA, r16
wait_adc:
	lds r16, ADCSRA
	sbrc r16, ADSC
	jmp wait_adc
	lds r16, ADCH
	ret

MOVE_PLAYER:
	// Kollar om joystick rr sig upp/ner
	cpi r16, 0x03
	breq up
	cpi r16, 0x00
	breq down
	jmp move_done
down:
	inc r17
	cpi r17, ROW_8 + 1
	breq reset
	cpi r17, 24
	breq move_screen
	jmp move_done
up:
	dec r17
	cpi r17, ROW_1 - 1
	breq limit
	cpi r17, 15
	breq point
	jmp move_done
limit:
	ldi r17, ROW_8 + 16
	jmp move_done
move_screen:
	ldi r17, ROW_1
	jmp move_done
point:
	call SOUND_TOP
	call ADD_POINT
reset:
	ldi r17, ROW_8
move_done:
	ret
