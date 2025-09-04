MUX:
	push r16
	in r16, SREG
	push r16
	push r17
	push ZH
	push ZL
	lds r16, SEED
	inc r16
	sts SEED, r16
	lds r16, MENU_SELECTION
	cpi r16, MENU_START
	brne game_on
	call ERASE_VMEM
	lds r17,WHO_IS_THE_WINNER   ; kollar om man ska skicka CROWN eller START_MENU till sk�rmen.
	cpi r17, $00
	brne UPDATE_CROWN_MUX
	jmp UPDATE_START_MENU1
UPDATE_CROWN_MUX: ; Update CROWN i vmen_G eller vmem_R
	call UPDATE_CROWN
	jmp player_done
UPDATE_START_MENU1:
	call UPDATE_START_MENU
	jmp player_done
game_on:
	call ERASE_VMEM
	call UPDATE_ASTEROIDS
	call UPDATE_P1
	call UPDATE_P2
player_done:
	lds r17, ROW_INDEX
	cpi r17, 8
	brne continue_mux
	clr r17
	sts ROW_INDEX, r17
continue_mux:
	cbi PORT_SPI, SS
	ldi r16, SCREEN_4
	rcall SEND
	ldi r16, SCREEN_3
	rcall SEND
	ldi r16, SCREEN_2
	rcall SEND
	ldi r16, SCREEN_1
	rcall SEND
	sbi PORT_SPI, SS
	inc r17
	sts ROW_INDEX, r17
	lds r17, INDEX
	inc r17
	sts INDEX, r17
	cpi r17, 32
	brne DONE12
	clr r17
	sts INDEX, r17

DONE12:
	pop ZL
	pop ZH
	pop r17
	pop r16
	out SREG, r16
	pop r16
	reti

ERASE_VMEM:
	push ZH
	push ZL
	clr r16
	clr r17
	ldi ZH, HIGH(VMEM_R)
	ldi ZL, LOW(VMEM_R)
	call CLEAR
	ldi ZH, HIGH(VMEM_G)
	ldi ZL, LOW(VMEM_G)
	call CLEAR
	ldi ZH, HIGH(VMEM_B)
	ldi ZL, LOW(VMEM_B)
	call CLEAR
	pop ZL
	pop ZH
	ret

UPDATE_P1:
	ldi r16, 0x10
	lds r17, P1_POS
	ldi YH, HIGH(VMEM_G)
	ldi YL, LOW(VMEM_G)
	adiw YL, SCREEN_1
	add YL, r17
	adc YH, ZERO_REG
	st Y, r16
	ret

UPDATE_P2:
	ldi r16, 0x08
	lds r17, P2_POS
	ldi YH, HIGH(VMEM_R)
	ldi YL, LOW(VMEM_R)
	adiw YL, SCREEN_2
	add YL, r17
	adc YH, ZERO_REG
	st Y, r16
	ret

UPDATE_ASTEROIDS:
	push r18
	push XH
	push XL
	ldi r16, 32
	ldi YH, HIGH(VMEM_B)
	ldi YL, LOW(VMEM_B)
	ldi XH, HIGH(ASTEROIDS)
	ldi XL, LOW(ASTEROIDS)
loop_update_asteroids:
	ld r18, X+
	st Y+, r18
	dec r16
	brne loop_update_asteroids
	pop XL
	pop XH
	pop	r18
	ret


UPDATE_CROWN:
	push r18
	push XH
	push XL
	lds r17, WHO_IS_THE_WINNER
	cpi r17, $01
	breq WINNER_IS_P1
	ldi YH, HIGH(VMEM_R)
	ldi YL, LOW(VMEM_R)
	call WINNER_LOOP
	jmp UPDATE_CROWN_DONE
WINNER_IS_P1:
	ldi YH, HIGH(VMEM_G)
	ldi YL, LOW(VMEM_G)
	call WINNER_LOOP
UPDATE_CROWN_DONE:
lds r16,delay_byte
	dec r16
	breq  delay_done
	sts delay_byte,r16
	jmp DONE_CROWN
delay_done:
	sts WHO_IS_THE_WINNER,ZERO_REG
DONE_CROWN:
	pop XL
	pop XH
	pop r18
	ret
WINNER_LOOP:
	ldi XH, HIGH(CROWN)
	ldi XL, LOW(CROWN)
	ldi r16, 32
CROWN_LOOP:
	ld r18, X+
	st Y+, r18
	dec r16
	brne CROWN_LOOP
	ret

UPDATE_START_MENU:
	push r18
	push XH
	push XL
UPDATE_MENU1:
	ldi YH, HIGH(VMEM_G)
	ldi YL, LOW(VMEM_G)
	call	UPDATE_COLOR
	ldi YH, HIGH(VMEM_B)
	ldi YL, LOW(VMEM_B)
	call	UPDATE_COLOR
MENU_DONE:
	pop XL
	pop XH
	pop r18
	ret
UPDATE_COLOR:
	ldi XH, HIGH(TEXT)
	ldi XL, LOW(TEXT)
	ldi r16, 32
loop_start_menu:
	ld r18, X+
	st Y+, r18
	dec r16
	brne loop_start_menu
   ret


SEND:
	lds r17, ROW_INDEX
	ldi ZH, HIGH(VMEM_B)
	ldi ZL, LOW(VMEM_B)
	add r17, r16
	add ZL, r17
	adc ZH, ZERO_REG
	ld r16, Z
	call MASTER_TRANSMIT
	ldi ZH, HIGH(VMEM_G)
	ldi ZL, LOW(VMEM_G)
	add ZL, r17
	adc ZH, ZERO_REG
	ld r16, Z
	call MASTER_TRANSMIT
	ldi ZH, HIGH(VMEM_R)
	ldi ZL, LOW(VMEM_R)
	add ZL, r17
	adc ZH, ZERO_REG
	ld r16, Z
	call MASTER_TRANSMIT
	ldi ZH, HIGH(ROW*2)
	ldi ZL, LOW(ROW*2)
	lds r17, ROW_INDEX
	add ZL, r17
	adc ZH, ZERO_REG
	lpm r16, Z
	call MASTER_TRANSMIT
	ret	
	



