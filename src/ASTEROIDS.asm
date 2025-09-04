SPAWN_ASTEROID:
	push r16
	push r17
	push r18
	push YH
	push YL
	lds r16, SEED
	lds r17, ROW_INDEX
	mov r18, r17
random_loop:
	eor r16, r17
	add r16, r17
	dec r18
	brne random_loop
	ldi r17, 0x07
	and r16, r17
	cpi r16, 8
	brge subtract
	jmp spawn
subtract:
	subi r16, 8
spawn:
	ldi YH, HIGH(ASTEROIDS)
	ldi YL, LOW(ASTEROIDS)
	lds r17, SCREEN_INDEX
	ldi r18, 16
	mul r17, r18
	add YL, r0
	adc YH, ZERO_REG
	add YL, r16
	adc YH, ZERO_REG
	ld r16, Y
	ori r16, 0x80
	st Y, r16
	pop YL
	pop YH
	pop r18
	pop r17
	pop r16
	ret

CLEAR_ASTEROIDS:
	push ZH
	push ZL
	clr r16
	clr r17
	ldi ZH, HIGH(ASTEROIDS)
	ldi ZL, LOW(ASTEROIDS)
	call CLEAR
	pop ZL
	pop ZH
	ret


MOVE_ASTEROIDS:
	push r16
	in r16, SREG
	push r16
	push r17
	push YH
	push YL
	clr r16
	ldi YH, HIGH(ASTEROIDS)
	ldi YL, LOW(ASTEROIDS)
shift:
	ld r17, Y
	lsr r17
	brcc no_carry
	cpi r16, SCREEN_4
	brge no_carry
	cpi r16, SCREEN_3
	brge carry
	cpi r16, SCREEN_2
	brge no_carry
carry:
	adiw YL, 8
	ld r18, Y     
	ori r18, 0x80
	st Y, r18
	subi YL, 8
no_carry:       
	st Y+, r17
	inc r16
	cpi r16, VMEM_SZ
	brne shift
	lds r16, SCREEN_INDEX
	inc r16
	cpi r16, 3
	brne move_asteroids_done
	clr r16
move_asteroids_done:
	sts SCREEN_INDEX, r16
	call SPAWN_ASTEROID
	lds r16, SEED
	lds r17, ROW_INDEX
	eor r16, r17
	add r16, r17
	sts SEED, r16
	pop YL
	pop YH
	pop r17
	pop r16
	out SREG, r16
	pop r16
	reti

	