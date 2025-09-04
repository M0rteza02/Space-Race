UPDATE_SEG:
	push r16
	push r17
	lds r17, P1_SCORE
	call LOOKUP
	ldi r16, 0x24 ; Vänster display
	sts SLA_W, r16
	call TWI_SEND
	lds r17, P2_SCORE
	call LOOKUP
	ldi r16, 0x25 ; Höger display
	sts SLA_W, r16
	call TWI_SEND
	pop r17
	pop r16
	ret

LOOKUP:
	push	r16
	in		r16, SREG
	push	r16
	push	ZH
	push	ZL
	ldi		ZH,HIGH(SEG_TAB*2)
	ldi		ZL,LOW(SEG_TAB*2)
	add		ZL,r17
	adc		ZH, ZERO_REG
	lpm		r16,Z
	sts		DATA_TWI, r16
	pop		ZL
	pop		ZH
	pop		r16
	out		sreg,r16
	pop		r16
	ret	

SEG_TAB:
	.db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71