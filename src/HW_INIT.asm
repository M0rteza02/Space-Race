HW_INIT:
	// Clock select, clk/64
	ldi r16, (0<<CS02) | (1<<CS01) | (1<<CS00)
	out TCCR0B, r16
	// Timer Overflow interrupt enabled
	ldi r16, (1<<TOIE0)
	sts TIMSK0, r16

	// Clock select, clk/64
	ldi r16, (0<<CS12) | (1<<CS11) | (1 <<CS10)
	sts TCCR1B, r16
	// Timer Overflow interrupt enabled
	ldi r16, (1<<TOIE1)
	sts TIMSK1, r16

	// ADC
	ldi r16, (1<<REFS0) | (0<<ADLAR)
	sts ADMUX, r16
	ldi r16, (1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0)
	sts	ADCSRA, r16

	// TWI
	ldi r16, 0xFF
	sts TWBR, r16
	ret
