sound_main:
cli

	push   r20
	push  r21
	push r22
	push	r23
	ldi		r20, time
	ldi		r21, freq
	call	start_sound
	pop r23
	pop r22
	pop r21
	pop  r20 
sei
	ret
SOUND_TOP:
cli

	push   r20
	push  r21
	push r22
	push	r23
	ldi		r20, 25
	ldi		r21, 150
	call	start_sound
	pop r23
	pop r22
	pop r21
	pop  r20 
sei
	ret
start_sound:
	sbi		PORTB,1
	call	delay3
	cbi		PORTB,1
	call	delay3
	dec		r20
	brne	start_sound
	ret
delay3:
	mov		r23, r21
Inner_delay:
	ldi		r22, 25
loop:
	dec		r22
	brne	loop
	dec		r23
	brne	Inner_delay
	ret


winning_sound:
cli
	push	r16
	push	r17
	push	r18
	push	r19
winning_loop:
	call	freq_lookup
	call	time_lookup
	inc     r19
	cpi		r19, 10
	brne	winning_melody
	pop		r16
	pop		r17
	pop		r18
	pop		r19
sei
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
  .db 190, 140, 100, 125, 120, 115, 200, 75, 175, 0

time_table:
	.db 50, 75, 75, 50, 50, 50, 50, 100, 100, 50