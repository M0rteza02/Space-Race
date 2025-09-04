TWI_SEND:
	push r16
	push r17
	call START_TWI
	call SEND_BYTE
	call STOP_TWI
	pop r17
	pop r16
	ret

START_TWI:
	ldi r16, (1<<TWINT) | (1<<TWSTA) | (1<<TWEN)
	sts TWCR, r16
	call WAIT
	ret

SEND_BYTE:
	lds r16, SLA_W
	lsl r16
	sts TWDR, r16
	call TRANSMIT ; Transmit adress
	lds r16, DATA_TWI
	sts TWDR, r16
	call TRANSMIT ; Transmit data
	ret

STOP_TWI:
	ldi r16, (1<<TWINT) | (1<<TWSTO) | (1<<TWEN)
	sts TWCR, r16
	ret

TRANSMIT:
	ldi r16, (1<<TWINT) | (1<<TWEN)
	sts TWCR, r16
WAIT:
	lds r16, TWCR
	sbrs r16, TWINT
	jmp WAIT
	ret