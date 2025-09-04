CHECK_COLLISION:
	call CHECK_COLLISION_P1
	call CHECK_COLLISION_P2
	ret
CHECK_COLLISION_P1:
	push r16
	push r17
	push XH
	push XL
	lds r16,P1_POS 
	ldi XH,HIGH(ASTEROIDS)
	ldi XL,LOW(ASTEROIDS)
	add XL, r16
	adc XH, ZERO_REG
	ld r17, X
	andi r17, $10
	cpi r17, $10
	brne DONE_COLLISION
LOSE_P1:
	ldi r17, ROW_8
	sts P1_POS, r17
	call sound_main
DONE_COLLISION:
	pop XL
	pop XH
	pop r17
	pop r16
	ret

CHECK_COLLISION_P2:
	push r16
	push r17
	push XH
	push XL
	lds r16,P2_POS 
	ldi XH,HIGH(ASTEROIDS)
	ldi XL,LOW(ASTEROIDS)
	adiw XL,SCREEN_2
	add XL, r16
	adc XH, ZERO_REG
	ld r17, X
	andi r17, $08
	cpi r17, $08
	brne DONE_COLLISION1
LOSE_P2:
	ldi r17, ROW_8
	sts P2_POS, r17
	call sound_main
DONE_COLLISION1:
	pop XL
	pop XH
	pop r17
	pop r16
	ret