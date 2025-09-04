	.equ VMEM_SZ = 32
	.equ SCREEN_1 = 0
	.equ SCREEN_2 = 8
	.equ SCREEN_3 = 16
	.equ SCREEN_4 = 24
	.equ ROW_1 = 0
	.equ ROW_2 = 1
	.equ ROW_3 = 2
	.equ ROW_4 = 3
	.equ ROW_5 = 4
	.equ ROW_6 = 5
	.equ ROW_7 = 6
	.equ ROW_8 = 7
	.equ MENU_START = 1
	.def ZERO_REG = r25
	.equ freq  = 150 ; Victory beep pitch
	.equ time = 50 ; Victory beep length
	
	.dseg
	.org SRAM_START
	WHO_IS_THE_WINNER: .byte 1
	P1_POS: .byte 1
	P2_POS:	.byte 1
	VMEM_R: .byte VMEM_SZ
	VMEM_G: .byte VMEM_SZ
	VMEM_B: .byte VMEM_SZ
	PLAYER_TURN: .byte 1
	TEXT: .byte VMEM_SZ
	CROWN: .byte VMEM_SZ
	MENU_SELECTION: .byte 1
	ROW_INDEX: .byte 1
	ASTEROIDS: .byte VMEM_SZ
	SPACE_FOR_MEMORY: .byte 10; f�r att TWI ska funka r�tt
	P1_SCORE: .byte 1
	P2_SCORE: .byte 1
	SCREEN_INDEX: .byte 1
	SLA_W: .byte 1
	DATA_TWI: .byte 1
	INDEX: .byte 1
	SEED: .byte 1
	delay_byte: .byte 1 

	.cseg
	.org 0x00
	jmp START
	.org 0x001A
	jmp MOVE_ASTEROIDS
	.org 0x0020
	jmp MUX
	
	.include "HW_INIT.asm"
	.include "SPI.asm"
	.include "MUX.asm"
	.include "JOYSTICK.asm"
	.include "SCORE.asm"
	.include "SEG_DISPLAY.asm"
	.include "TWI.asm"
	.include "ASTEROIDS.asm"
	.include "sound.asm"
	.include "Collision.asm"
START:
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi		r16, $FF
	out		DDRB, r16
	clr ZERO_REG
	ldi r16, ROW_8
	sts P1_POS, r16
	ldi r16, ROW_8
	sts P2_POS, r16
	ldi r16, MENU_START
	sts MENU_SELECTION, r16
	clr r19
	sts WHO_IS_THE_WINNER,ZERO_REG
	sts delay_byte,ZERO_REG

	call SPI_INIT
	call HW_INIT
	sei

MAIN:
	call ERASE_VMEM
	call CLEAR_CROWN
	call SETUP_CROWN
	ldi r16, MENU_START
	sts MENU_SELECTION, r16
	sts P1_SCORE, ZERO_REG
	sts P2_SCORE, ZERO_REG
	sts PLAYER_TURN, ZERO_REG
	call ERASE_MENU
	call CLEAR_ASTEROIDS
	sts P1_SCORE, ZERO_REG
	sts P2_SCORE, ZERO_REG
	call UPDATE_SEG 
	call START_MENU
	ldi r16,255
	sts delay_byte,r16
	call GET_KEY
	sts WHO_IS_THE_WINNER,ZERO_REG  
RUN:
	call JOYSTICK
	call CHECK_SCORE
	call CHECK_COLLISION
	lds r16, WHO_IS_THE_WINNER
	cpi r16, $00
	brne main
	rjmp RUN

START_MENU:
	ldi r16, 0b00111000
	sts TEXT+(SCREEN_1 + ROW_1), r16
	ldi r16,0b00001111
	sts TEXT+(SCREEN_1 + ROW_2), r16
	ldi r16,0b00000010
	sts TEXT+(SCREEN_1 + ROW_3), r16
	ldi r16,0b00000010
	sts TEXT+(SCREEN_1 + ROW_4), r16
	ldi r16,0b00000011
	sts TEXT+(SCREEN_1 + ROW_5), r16
	ldi r16,0b00000010
	sts TEXT+(SCREEN_1 + ROW_6), r16
	ldi r16,0b11111100
	sts TEXT+(SCREEN_2 + ROW_2), r16
	ldi r16,0b01000000
	sts TEXT+(SCREEN_2 + ROW_3), r16
	ldi r16,0b10000000
	sts TEXT+(SCREEN_2 + ROW_4), r16
	ldi r16,0b00000110
	sts TEXT+(SCREEN_2 + ROW_1), r16
	ldi r16,0b00000110
	sts TEXT+(SCREEN_4 + ROW_8), r16
	ldi r16,0b00111100
	sts TEXT+(SCREEN_4 + ROW_7), r16
	ldi r16,0b01000000
	sts TEXT+(SCREEN_4 + ROW_6), r16
	ldi r16,0b10000000
	sts TEXT+(SCREEN_4 + ROW_5), r16
	ldi r16,0b00000011
	sts TEXT+(SCREEN_3 + ROW_4), r16
	ldi r16,0b00000010
	sts TEXT+(SCREEN_3 + ROW_3), r16
	ldi r16,0b00000010
	sts TEXT+(SCREEN_3 + ROW_5), r16
	ldi r16,0b00000010
	sts TEXT+(SCREEN_3 + ROW_6), r16
	ldi r16,0b00001110
	sts TEXT+(SCREEN_3 + ROW_7), r16
	ldi r16,0b00111000
	sts TEXT+(SCREEN_3 + ROW_8), r16
	ret
SETUP_CROWN:
	ldi r16, 0b0001010
	sts CROWN + (SCREEN_1 + ROW_1), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_1 + ROW_2), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_1 + ROW_1), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_1 + ROW_2), r16
	ldi r16, 0b00001111
	sts CROWN + (SCREEN_1 + ROW_3), r16
	ldi r16, 0b11111000
	sts CROWN + (SCREEN_2 + ROW_3), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_2 + ROW_2), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_2 + ROW_1), r16
	ldi r16, 0b0101000
	sts CROWN + (SCREEN_4 + ROW_7), r16
	ldi r16, 0b01011000
	sts CROWN + (SCREEN_4 + ROW_6), r16
	ldi r16, 0b10001000
	sts CROWN + (SCREEN_4 + ROW_5), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_4 + ROW_8), r16
	ldi r16, 0b0001010
	sts CROWN + (SCREEN_3 + ROW_7), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_3 + ROW_8), r16
	ldi r16, 0b00001101
	sts CROWN + (SCREEN_3 + ROW_6), r16
	ldi r16, 0b00001000
	sts CROWN + (SCREEN_3 + ROW_5), r16
	ret
ERASE_MENU:
	clr r16
	clr r17
	ldi ZH, HIGH(TEXT)
	ldi ZL, LOW(TEXT)
	call CLEAR
	ret
CLEAR_CROWN:
	clr r16
	clr r17
	ldi ZH, HIGH(CROWN)
	ldi ZL, LOW(CROWN)
	call CLEAR
	ret

CLEAR:
	st Z+, r16
	inc r17
	cpi r17, VMEM_SZ
	brne CLEAR
	clr r16
	clr r17
	ret
GET_KEY:
	sbic PIND, 1
	jmp GET_KEY
	clr r16
	sts MENU_SELECTION, r16
	ret
ROW:
	.db 0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F
