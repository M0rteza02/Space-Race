	.equ SS = PB2
	.equ MOSI = PB3
	.equ SCK = PB5
	.equ DDR_SPI = DDRB
	.equ PORT_SPI = PORTB

SPI_INIT:
	ldi r16, (1<<SPE) | (1<<MSTR)|(1<<SPR1) | (1<<SPR0)
	out SPCR, r16
	ldi r16,(0<<SPI2X)
	out SPSR,r16
	ret

MASTER_TRANSMIT:
	out SPDR, r16
transmit_loop:
	in r16, SPSR
	sbrs r16, SPIF
	rjmp transmit_loop
	ret
	
