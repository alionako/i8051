Button_1 	EQU R0
Button_2 	EQU R1
Button_3	EQU R2

Button_1_mins 	EQU 070H
Button_2_mins 	EQU 071H
Button_3_mins	EQU 072H

seconds 		EQU R3
minutes 		EQU R4
ten_minutes		EQU R5

Button_1_Port 		EQU P2.4
Button_2_Port 		EQU P2.5
Button_3_Port		EQU P2.6
Clear_Result_Port	EQU P2.7
Result_Port     	EQU P3.0

org 0h
jmp START
org 30h

START:
	mov P0,#0
	mov P1,#0
	mov P2,#0
	mov P3,#0
	mov R0,#0
	mov R1,#0
	mov R2,#0
	mov R3,#0
	mov R4,#0
	mov R5,#0
	mov R6,#0
	mov R7,#0
	setb P2.0
	setb P2.1
	setb P2.2
	setb P2.3
	setb P2.4
	setb P2.5
	setb P2.6
	setb P2.7
	setb P3.0
		
MAIN:
mov P0, #0
mov P1, #0
	jnb Button_1_Port, BUTTON1_PRESS
	jnb Button_2_Port, BUTTON2_PRESS
	jb Button_3_Port, RES_PORT 
		jmp BUTTON3_PRESS
RES_PORT: 
	jb Result_Port, CLEAR_RES_PORT 
		jmp SHOW_RESULT
CLEAR_RES_PORT:
	jb Clear_Result_Port, MAIN
		jmp CLEAR_RESULTS
	jmp MAIN
	
CLEAR_MESSAGE:
	mov P0, #0
	mov P1, #0
	setb P0.0
	call LETTER_C
	mov P0, #0
	mov P1, #0
	setb P0.1
	call LETTER_L
	mov P0, #0
	mov P1, #0
	setb P0.2
	call LETTER_R
ret
	
BUTTON1_PRESS:
	mov P0, #0
	mov P1, #0
	setb P0.0
	call DIGIT_ONE
	mov a, Button_1
	call ONE_SECOND_DELAY
	inc a
	mov Button_1, a
	cjne a, #60, INC_SEC_1
		mov a, Button_1_mins
		inc a
		mov Button_1_mins, a
		mov Button_1, #0
	INC_SEC_1:
	mov Button_1, a
	jb Button_2_Port, CHECK12 
	call INC_BUTTON2
	CHECK12:
	jb Button_3_Port, CHECK13 
	call INC_BUTTON3
	CHECK13:
	jnb Button_1_Port, BUTTON1_PRESS
	jmp MAIN

BUTTON2_PRESS:
	mov P0, #0
	mov P1, #0
	setb P0.0
	call DIGIT_TWO
	mov a, Button_2
	call ONE_SECOND_DELAY
	inc a
	mov Button_2, a
	cjne a, #60, INC_SEC_2
		mov a, Button_2_mins
		inc a
		mov Button_2_mins, a
		mov Button_2, #0
	INC_SEC_2:
	mov Button_2, a
	jb Button_1_Port, CHECK21
	call INC_BUTTON1
	CHECK21:
	jb Button_3_Port, CHECK23 
	call INC_BUTTON3
	CHECK23:
	jnb Button_2_Port, BUTTON2_PRESS
	jmp MAIN
	
BUTTON3_PRESS:
	mov P0, #0
	mov P1, #0
	setb P0.0
	call DIGIT_THREE
	mov a, Button_3
	call ONE_SECOND_DELAY
	inc a
	mov Button_3, a
	cjne a, #60, INC_SEC_3
		mov a, Button_3_mins
		inc a
		mov Button_3_mins, a
		mov Button_3, #0
	INC_SEC_3:
	mov Button_3, a
	jb Button_1_Port, CHECK31 
	call INC_BUTTON1
	CHECK31:
	jb Button_2_Port, CHECK32 
	call INC_BUTTON2
	CHECK32:
	jnb Button_3_Port, BUTTON3_PRESS
	jmp MAIN	
	
SHOW_RESULT:
	call SHOW_FIRST_TIME
	mov P0, #0
	mov P1, #0
	call SHOW_SECOND_TIME
	mov P0, #0
	mov P1, #0
	call SHOW_THIRD_TIME
	mov P0, #0
	mov P1, #0
	jmp MAIN
	
DELAY: 
		mov 30h,#12
M1:		mov 31h,#20
M2:		djnz 31h,M2
		djnz 30h,M1
ret	

ONE_SECOND_DELAY:
		mov 50h,#191
M3:		mov 51h,#254
M4:		djnz 51h,M4
		djnz 50h,M3
ret

INC_BUTTON1:
	mov a, Button_1
	inc a
	cjne a, #60, INC_Button_1
		mov a, Button_1_mins
		inc a
		mov Button_1_mins, a
	INC_Button_1:
	mov Button_1, a
ret

INC_BUTTON2:
	mov a, Button_2
	inc a
	cjne a, #60, INC_Button_2
		mov a, Button_2_mins
		inc a
		mov Button_2_mins, a
	INC_Button_2:
	mov Button_2, a
ret

INC_BUTTON3:
	mov a, Button_3
	inc a
	cjne a, #60, INC_Button_3
		mov a, Button_3_mins
		inc a
		mov Button_3_mins, a
	INC_Button_3:
	mov Button_3, a
ret

SHOW_DIGITS:
	mov P0, #0
	mov P1, #0
	setb P0.2
	setb P0.5
	call MINUS
	mov a, seconds
	mov b,#10
	div ab
	mov P0, #0
	mov P1, #0
	setb P0.6
	call COMPARE_DIGIT
	mov a,b
	mov P0, #0
	mov P1, #0
	setb P0.7
	call COMPARE_DIGIT
	mov a, minutes
	mov b,#10
	div ab
	mov P0, #0
	mov P1, #0
	setb P0.3
	call COMPARE_DIGIT
	mov a,b
	mov P0, #0
	mov P1, #0
	setb P0.4
	call COMPARE_DIGIT
	mov a, ten_minutes
	mov b, #10
	div ab
	mov P0, #0
	mov P1, #0
	setb P0.0
	call COMPARE_DIGIT
	mov a,b
	mov P0, #0
	mov P1, #0
	setb P0.1
	call COMPARE_DIGIT
ret

COMPARE_DIGIT:
		cjne a, #0, IS_ONE
		call ZERO
	IS_ONE:
		cjne a, #1, IS_TWO
		call DIGIT_ONE
	IS_TWO:
		cjne a, #2, IS_THREE
		call DIGIT_TWO
	IS_THREE:
		cjne a, #3, IS_FOUR
		call DIGIT_THREE
	IS_FOUR:
		cjne a, #4, IS_FIVE
		call DIGIT_FOUR
	IS_FIVE:
		cjne a, #5, IS_SIX
		call DIGIT_FIVE
	IS_SIX:
		cjne a, #6, IS_SEVEN
		call DIGIT_SIX
	IS_SEVEN:
		cjne a, #7, IS_EIGHT
		call DIGIT_SEVEN
	IS_EIGHT:
		cjne a, #8, IS_NINE
		call DIGIT_EIGHT
	IS_NINE:
		cjne a, #9, SKIP
		call DIGIT_NINE
	SKIP:
ret

SHOW_DIGITS_FIVE_SEC:
	mov 40h,#14
M5:	mov 41h,#24
M6:	call SHOW_DIGITS
	djnz 41h,M6
	djnz 40h,M5
ret
		
SHOW_FIRST_TIME:
	mov a, Button_1	
	mov seconds, a
	mov a, Button_1_mins
	mov b, #60
	div ab
	mov minutes, b
	mov a, minutes
	mov b, #10
	div ab
	mov ten_minutes, a
	call SHOW_DIGITS_FIVE_SEC
ret

SHOW_SECOND_TIME:
	mov a, Button_2	
	mov seconds, a
	mov a, Button_2_mins
	mov b, #60
	div ab
	mov minutes, b
	mov a, minutes
	mov b, #10
	div ab
	mov ten_minutes, a	
	call SHOW_DIGITS_FIVE_SEC
ret

SHOW_THIRD_TIME:
	mov a, Button_3	
	mov seconds, a
	mov a, Button_3_mins
	mov b, #60
	div ab
	mov minutes, b
	mov a, minutes
	mov b, #10
	div ab
	mov ten_minutes, a
	call SHOW_DIGITS_FIVE_SEC
ret

CLEAR_RESULTS:
	mov Button_1, #0
	mov Button_2, #0
	mov Button_3, #0
	mov Button_1_mins, #0
	mov Button_2_mins, #0
	mov Button_3_mins, #0
	call CLEAR_MESSAGE
	jmp MAIN

DIGIT_ONE:
	setb P1.1
	setb P1.2
	call DELAY
ret

DIGIT_TWO:
	setb P1.0
	setb P1.1
	setb P1.3
	setb P1.4
	setb P1.6
	call DELAY
ret
	
DIGIT_THREE:
	setb P1.0
	setb P1.1
	setb P1.2
	setb P1.3
	setb P1.6	
	call DELAY
ret
	
DIGIT_FOUR:
	setb P1.1
	setb P1.2
	setb P1.5
	setb P1.6
	call DELAY
ret
	
DIGIT_FIVE:
	setb P1.0
	setb P1.2
	setb P1.3
	setb P1.5
	setb P1.6
	call DELAY	
ret
	
DIGIT_SIX:
	setb P1.0
	setb P1.2
	setb P1.3
	setb P1.4
	setb P1.5
	setb P1.6
	call DELAY
ret
	
DIGIT_SEVEN:
	setb P1.0
	setb P1.1
	setb P1.2
	call DELAY
ret
	
DIGIT_EIGHT:
	setb P1.0
	setb P1.1
	setb P1.2
	setb P1.3
	setb P1.4
	setb P1.5
	setb P1.6
	call DELAY
ret
	
DIGIT_NINE:
	setb P1.0
	setb P1.1
	setb P1.2
	setb P1.3
	setb P1.5
	setb P1.6
	call DELAY
ret
	
DIGIT_NULL:
	setb P1.0
	setb P1.1
	setb P1.2
	setb P1.3
	setb P1.4
	setb P1.6
	call DELAY
ret

ZERO:
	setb P1.0
	setb P1.1
	setb P1.2
	setb P1.3
	setb P1.4
	setb P1.5
	call DELAY
ret
	
MINUS:
	setb P1.6
	call DELAY
ret
	
LETTER_C:
	setb P1.0
	setb P1.3
	setb P1.4
	setb P1.5	
	setb P0.0
	call DELAY
ret

LETTER_L:
	setb P1.3
	setb P1.4
	setb P1.5
	setb P0.1
	call DELAY
ret
	
LETTER_R:
	setb P1.0
	setb P1.4
	setb P1.5
	call DELAY
ret

END