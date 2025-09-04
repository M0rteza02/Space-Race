CHECK_SCORE:
	push r16
	lds r16, P1_SCORE
	cpi r16, 3
	breq WINNER_P1
	lds r16, P2_SCORE
	cpi r16, 3
	breq WINNER_P2
	jmp continue_game
WINNER_P1:
	ldi r16,$01
	jmp WINNER
WINNER_P2:
	ldi r16,$02
WINNER:
	sts WHO_IS_THE_WINNER,r16
	ldi r16, ROW_8
	sts P1_POS,r16
	sts P2_POS,r16
	call winning_sound
continue_game:
	pop r16
	ret
	


ADD_POINT:
	push r16
	lds r16, PLAYER_TURN
	cpi r16, 0
	brne add_p2
	lds r16, P1_SCORE
	inc r16
	sts P1_SCORE, r16
	jmp point_done
add_p2:
	lds r16, P2_SCORE
	inc r16
	sts P2_SCORE, r16
point_done:
	call UPDATE_SEG
	pop r16
	ret