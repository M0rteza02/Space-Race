;
; Speaker.asm
;
; Created: 2023-02-11 13:41:59
; Author : Elias
;

/*
.dseg

counter:
.byte 1

.cseg 

.org 0x0000
    jmp setup
	
.org 0x001C
    jmp timer0
	
setup:
    ldi		r16,LOW(RAMEND)   
    out		SPL,r16
    ldi		r16,HIGH(RAMEND)  
    out		SPH,r16           
    ldi		r16, $ff
    out		DDRB,r16  
	
	ldi		r16, (3<<COM1A0) | (1<<WGM11) ; set WGM11, WGM10, and COM1B0 bits in TCCR1A
	sts		TCCR1A, r16
	ldi		r16, (1<<COM1A1) | (1<<WGM11) | (1<<CS10) ; Set PWM mode and clock prescaler to 8
    sts		TCCR1B, r16

	ldi		r16, (1 << WGM01) | (0 << WGM00)
	out		TCCR0A, r16
	ldi		r16, (1 << OCIE0A)
	sts		TIMSK0, r16
	ldi		r16, (1 << CS02) | (0 << WGM02) ; Set prescale to 256
	out		TCCR0B, r16
	ldi		r16, 250
	out		OCR0A, r16
	sei
	
main:
    call	orig_lookup_low
	call	orig_lookup_high
	call	changed_lookup_low
	call	changed_lookup_high
    call	duty_cycle
	inc		r29
    cpi		r29, 4
    breq	next_frequency  
	jmp		main

next_frequency:
	clr		r18
	clr		r19
	clr		r20
	clr		r28
	clr		r29
	jmp		main

duty_cycle:
	sts     ICR1H, r21 
    sts     ICR1L, r24
    sts     OCR1AH, r25
    sts     OCR1AL, r26
    ret
	
timer0:
	lds		r16, counter
	inc		r16
	cpi		r16, 10
	brne	timer0_done
	clr		r16

timer0_done:
	sts		counter, r16
    reti
	
orig_lookup_low:
	push	ZH
	push	ZL
	ldi		ZH,HIGH(orig_tones_low*2)
	ldi		ZL,LOW(orig_tones_low*2)
	add		ZL, r20
	lpm		r24,Z
	inc		r20
	pop		ZL
	pop		ZH
	ret

orig_lookup_high:
	push	ZH
	push	ZL
	ldi		ZH,HIGH(orig_tones_high*2)
	ldi		ZL,LOW(orig_tones_high*2)
	add		ZL, r28
	lpm		r21,Z
	inc		r28
	pop		 ZL
	pop		ZH
	ret

changed_lookup_low:
	push	ZH
	push	ZL
	ldi		ZH,HIGH(changed_tones_low*2)
	ldi		ZL,LOW(changed_tones_low*2)
	add		ZL, r19
	lpm		r26,Z
	inc		r19
	pop		ZL
	pop		ZH
	ret

changed_lookup_high:
	push	ZH
	push	ZL
	ldi		ZH,HIGH(changed_tones_high*2)
	ldi		ZL,LOW(changed_tones_high*2)
	add		ZL, r18
	lpm		r25,Z
	inc		r18
	pop		ZL
	pop		ZH
	ret

	; Freq: 1000Hz, 1250Hz, 1500Hz and 1750Hz with a prescaler of 8 
orig_tones_low:
	 .db $D0, $40, $32, $74 
orig_tones_high:
	 .db $07, $06, $05, $04

changed_tones_low:
	 .db $A0, $80, $64, $E8
changed_tones_high:
	 .db $0F, $0C, $08, $08
*/


/*
.dseg

counter:
.byte 1

storage:
.byte 1

.cseg 

.org 0x0000
    jmp setup
	
.org 0x001C
    jmp timer0_l1

setup:
    ldi		r16,LOW(RAMEND)   
    out		SPL,r16
    ldi		r16,HIGH(RAMEND)  
    out		SPH,r16           
    ldi		r16, $ff
    out		DDRB,r16  

	ldi		r16, (3<<COM1A0) | (1<<WGM11) | (0<<WGM10) 
	sts		TCCR1A, r16
	ldi		r16, (1<<WGM11) | (1<<WGM12) | (1<<WGM13) | (1<<CS11)
	sts		TCCR1B, r16
	
	;ldi		r16, 0
	;sts		TCNT1H, r16 
	;ldi		r16, 0 
	;sts		TCNT1L, r16
	;ldi     r16, (1 << TOIE1)    
	;sts     TIMSK1, r16  
	       
	
	
	ldi		r16, (1 << WGM01) | (1 << WGM00) | (1 << COM0A1) | (0 << COM0A0)
	out		TCCR0A, r16
	ldi     r16, (1 << CS02) | (1 << CS00) | (1 << WGM02) | (1 << COM0B1) | (0 << COM0B0)  ; Set prescale to 64
	out		TCCR0B, r16
	ldi		r16, (1 << OCIE0A)
	sts		TIMSK0, r16
	ldi		r16, 255
	out		OCR0A, r16
	

	sts		counter, r2
	sts		storage, r2
	
	ldi		r27, 0x13
	ldi		r28, 0x88
	sts     OCR1AH, r27
	sts     OCR1AL, r28
	
	sei
	
main:	
	jmp		main
	
timer0_l1:
	push	r16
	in		r16, SREG
	push	r16
count1:
	call	lookup
	lds		r16, counter
	inc		r16
	cpi		r16, 1
	brne	timer0_done
	clr		r16
timer0_done:
	sts		counter, r16
	pop		r16
	out		SREG, r16
	pop		r16	
    reti
	
lookup:
	push	ZH
	push	ZL
	ldi		ZH,HIGH(tones*2)
	ldi		ZL,LOW(tones*2)
	lds		r20, storage
	add		ZL, r20

	lpm		r21,Z+
	lpm		r22,Z+
	lpm		r23,Z+
 	lpm		r24,Z+

	sts     ICR1H, r23
	sts     ICR1L, r24
	sts     OCR1AH, r21
	sts     OCR1AL, r22

	inc		r20
	inc		r20
	inc		r20
	inc		r20
	cpi		r20, 16
	breq	clear
	sts		storage, r20
	pop		ZL
	pop		ZH
	ret

clear:	
	clr		r20
	ret

	tones:
  ; OCRAH, OCRAL, ICRAH, ICRAL for 200 Hz
  .db 0x09, 0xC4, 0x27, 0x10
  ; OCRAH, OCRAL, ICRAH, ICRAL for 400 Hz
  .db 0x0D, 0x05, 0x13, 0x88
  ; OCRAH, OCRAL, ICRAH, ICRAL for 300 Hz
  .db 0x13, 0x88, 0x1A, 0x0A

*/
;----------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------- Winning sound ------------------------------------------------------
/*

start:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	ldi		r16, $FF
	out		DDRB, r16

main:
	call	start_sound
done:
	call	delay
	cbi		PORTB,1
	call	delay
	jmp		done
	ret

start_sound:
	call	freq_lookup
	call	time_lookup
	cpi		r20, 13
	breq	done
melody:
	sbi		PORTB,1
	call	delay
	cbi		PORTB,1
	call	delay
	dec		r16
	brne	melody
	jmp		start_sound

freq_lookup:
	push	ZL
	push	ZH
	ldi		ZH,HIGH(freq_table*2)
	ldi		ZL,LOW(freq_table*2)
	add		ZL, r20 
	lpm		r18, Z
	pop		ZL
	pop		ZL
	ret

time_lookup:
	push	ZL
	push	ZH
	ldi		ZH,HIGH(time_table*2)
	ldi		ZL,LOW(time_table*2)
	add		ZL, r20 
	lpm		r16, Z
	inc		r20
	pop		ZL
	pop		ZL
	ret

delay:
	push	r16
	mov		r16, r18
Inner_delay:
	ldi		r17, 50
loop:
	dec		r17
	brne	loop
	dec		r16
	brne	Inner_delay
	pop		r16
	ret

freq_table:
	.db 200, 230, 190, 140, 100, 125, 120, 115, 200, 75, 175, 175

time_table:
	.db 50, 50, 50, 75, 75, 50, 50, 50, 50, 100, 100, 100, 100

	*/





	
start:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	ldi		r16, $FF
	out		DDRB, r16
	
main:
	call	winning_sound
done:
	call	winning_delay
	cbi		PORTB,1
	call	winning_delay
	jmp		done
	ret

winning_sound:
	push	r16
	push	r17
	push	r18
	push	r19
winning_loop:
	call	freq_lookup
	call	time_lookup
	cpi		r19, 10
	brne	winning_melody
	pop		r16
	pop		R17
	pop		r18
	pop		r19
	ret
winning_melody:
	sbi		PORTB,1
	call	winning_delay
	cbi		PORTB,1
	call	winning_delay
	dec		r16
	brne	winning_melody
	jmp		winning_loop

freq_lookup:
	push	ZL
	push	ZH
	ldi		ZH,HIGH(freq_table*2)
	ldi		ZL,LOW(freq_table*2)
	add		ZL, r19 
	lpm		r18, Z
	pop		ZL
	pop		ZL
	ret

time_lookup:
	push	ZL
	push	ZH
	ldi		ZH,HIGH(time_table*2)
	ldi		ZL,LOW(time_table*2)
	add		ZL, r19 
	lpm		r16, Z
	inc		r19
	pop		ZL
	pop		ZL
	ret

winning_delay:
	push	r16
	mov		r16, r18
winning_inner_delay:
	ldi		r17, 50
winning_spiral:
	dec		r17
	brne	winning_spiral
	dec		r16
	brne	winning_inner_delay
	pop		r16
	ret

freq_table:
	.db 190, 140, 100, 125, 120, 115, 200, 75, 175

time_table:
	.db 50, 75, 75, 50, 50, 50, 50, 100, 100, 50
	
;----------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------ Death sound ---------------------------------------------------------
/*
.equ freq  = 150 ; Victory beep pitch
.equ time = 50 ; Victory beep length

start:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	ldi		r16, $FF
	out		DDRB, r16

main:
	ldi		r16, time
	ldi		r18, freq
	call	start_sound
done:
	call	delay
	cbi		PORTB,1
	call	delay
	jmp		done
	ret

start_sound:
	sbi		PORTB,1
	call	delay
	cbi		PORTB,1
	call	delay
	dec		r16
	brne	start_sound
	jmp		done

delay:
	push	r16
	mov		r16, r18
Inner_delay:
	ldi		r17, 50
loop:
	dec		r17
	brne	loop
	dec		r16
	brne	Inner_delay
	pop		r16
	ret
	*/