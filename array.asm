COMMENT*

*

EXTRN	GETDEC$:FAR
EXTRN	PUTDEC$:FAR
EXTRN	PUTBIN:FAR
EXTRN	PUTOCT:FAR
EXTRN	PUTSTRNG:FAR
EXTRN	NEWLINE:FAR
EXTRN	PAUSE:FAR
EXTERN	CLEAR:FAR

PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG
	MON_STRT	db	0,8,17,23,29,33,37,42,49,59,67,76
	MON_OFST	db	0,3,3,6,1,4,6,2,5,0,3,5
	MON_LEN		db	31,28,31,30,31,30,31,31,30,31,30,31
	MONTH_LST		db	'January$February$March$April$May$Jun$July$August$September$October$November$December$'
	DAY_STRT	db	0,7,14,22,32,41,48
	DAY_LST		db	'Sunday$Monday$Tuesday$Wednesday$Thursday$Friday$Saturday$'
	CENT_OFST	db	0,6
	PROMPT_YR	db	'Enter the year: $'
	PROMPT_MO	db	'Enter the month: $'
	PROMPT_DT	db	'Enter the date: $'
	ERR_DATE	db	'Date must be between 1 and $'
	ERR_YEAR	db	'Year must be between 1901 and 2029.$'
	ERR_MO		db	'Month must be a number from 1 to 12.$'
	IN_MONTH	dw	0
	IN_YEAR		dw	0
	IN_DATE		dw	0
	
	
.CODE 
	ASSUME	DS:DSEG,ES:DSEG
MAIN	PROC	FAR
	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	MOV		ES,AX
	
	call	NEWLINE
	
	call	VALID_YEAR
	mov		IN_YEAR,ax
	
	call	VALID_MONTH
	mov		IN_MONTH,ax
	
	mov	ax,IN_YEAR
	push	ax
	mov	ax,IN_MONTH
	push	ax
	call	VALID_DATE
	mov		IN_DATE,ax
	
	push	IN_YEAR
	call	GET_YEARDEC
	push	ax
	call 	GET_NUM_LY
	call	PUTDEC$
	call	NEWLINE
	
	
	mov	ax,1
	
	lea		dx,MON_STRT
	push	ax
	push	dx
	call	GET_ELEMENT_VAL	
	
	lea		dx, MONTH_LST
	push	ax
	push	dx
	call 	PRINT_MEMBER
	
	
.EXIT
MAIN	ENDP

COMMENT*
	GET_NUM_LY
	Erick Veil
	10-28-11
	PRE: Pass the year_dec via the stack
	POST: returns the leap year modifier via ax
		this is the number of ly in the current century
*
GET_NUM_LY	PROC	NEAR PUBLIC	YEAR:WORD	
	PUSHF
	
	mov	dx,0
	mov	ax,YEAR
	mov	bx,4
	div	bx	
	
	POPF
	RET	
GET_NUM_LY	ENDP

COMMENT*
	GET_YEARDEC
	Erick Veil
	10-28-11
	PRE: Pass the year via the stack
	POST: returns the last two digits of the year via ax
*
GET_YEARDEC	PROC	NEAR PUBLIC	YEAR:WORD	
	PUSHF
	
	mov	dx,0
	mov	ax,YEAR
	mov	bx,100
	div	bx
	mov	ax,dx	
	
	POPF
	RET
	
GET_YEARDEC	ENDP

COMMENT*
	CALC_WEEKDAY
	Erick Veil
	10-28-11
	PRE: 
	POST: 
*
CALC_WEEKDAY	PROC	NEAR PUBLIC	
	PUSHF
	
	mov	cx,IN_DATE
	
	push	IN_YEAR
	call	CENTMOD
	add	cx,ax
	
	push	IN_MONTH
	call	MONTH_OFF
	add	cx,ax
	
	
	
	POPF
	RET
	
CALC_WEEKDAY	ENDP

COMMENT*
	VALID_MONTH
	Erick Veil
	10-28-11
	PRE: none
	POST: prompts user for a month, and validates that it 
		is between 1 and 12. Decrements month by 1 and 
		returns the result via ax
*
VALID_MONTH	PROC	NEAR PUBLIC
	PUSHF
	
	PROMPT:
		mov		ax,0
		lea		dx, PROMPT_MO
		push	ax
		push	dx
		call 	PRINT_MEMBER
		call	GETDEC$

		cmp	ax,1
		jb	INVALID
		cmp	ax,12
		ja	INVALID
		jmp	VALID
	
	INVALID:
		mov		ax,0
		lea		dx, ERR_MO
		push	ax
		push	dx
		call 	PRINT_MEMBER
		call	NEWLINE
		jmp		PROMPT
		
	VALID:
		dec	ax
	POPF
	RET
	
VALID_MONTH	ENDP

COMMENT*
	VALID_YEAR
	Erick Veil
	10-28-11
	PRE: none
	POST: prompts user toenter a year and makes sure 
	it's in range, retuning a valid year on ax
*
VALID_YEAR	PROC	NEAR PUBLIC
	PUSHF
	
	PROMPT:
		mov		ax,0
		lea		dx, PROMPT_YR
		push	ax
		push	dx
		call 	PRINT_MEMBER
		call	GETDEC$

		cmp	ax,1901
		jb	INVALID
		cmp	ax,2029
		ja	INVALID
		jmp	VALID
	
	INVALID:
		mov		ax,0
		lea		dx, ERR_YEAR
		push	ax
		push	dx
		call 	PRINT_MEMBER
		call	NEWLINE
		jmp		PROMPT
		
	VALID:
	
	POPF
	RET
	
VALID_YEAR	ENDP

COMMENT*
	MONTH_OFF
	Erick Veil
	10-28-11
	PRE: pass the month via the stack
	POST: gets the offset modifier for the month
*
MONTH_OFF	PROC	NEAR PUBLIC uses dx bx, MON:WORD,YEAR:WORD
	PUSHF
	
	; check if leapyear
		mov	ax,YEAR
		push	ax
		call	GET_IS_LY
		cmp	ax,0
		jne	FROM_LIST
	
	; check if jan
		mov	ax,MON
		cmp	ax,0
		jne	FROM_LIST
		mov	ax,6
		jmp	DONE
		
	; check if feb
		mov	ax,MON
		cmp	ax,1
		jne	FROM_LIST
		mov	ax,2
		jmp	DONE
		
	; get value from array
	FROM_LIST:
		mov	ax,MON
		lea		dx,CENT_OFST
		push	ax
		push	dx
		call	GET_ELEMENT_VAL	

	DONE:
	
	POPF
	RET
	
MONTH_OFF	ENDP

COMMENT*
	CENTMOD
	Erick Veil
	10-28-11
	PRE: pass the year via the stack
	POST: gets a century modifier for the formula from an 
		array. 0 = 1900s, 6 = 2000s and returns it via ax
*
CENTMOD	PROC	NEAR PUBLIC uses dx bx, YEAR:WORD
	PUSHF
	
	; determine element, based on 1900s 0r 2000s
	mov	ax,YEAR
	mov	dx,0
	mov	bx,100
	div	bx
	sub	ax,19
	
	; get value from array
	lea		dx,CENT_OFST
	push	ax
	push	dx
	call	GET_ELEMENT_VAL	
	
	POPF
	RET
	
CENTMOD	ENDP

COMMENT*
	VALID_DATE
	Erick Veil
	10-28-11
	PRE: 
	POST: 
*
VALID_DATE	PROC	NEAR PUBLIC uses dx bx, YEAR:WORD, MON:WORD
	PUSHF
	
	; prompt for the day
	PROMPT:
		mov	ax,0
		lea	dx,PROMPT_DT
		push	ax
		push	dx
		call 	PRINT_MEMBER
		call	GETDEC$
		
	; get the month, check if feb		
		push	ax
		mov	bx,MON
		cmp	bx,1
		jne	LOOKUP_END	

	; check for leap year
		mov	bx,YEAR
		push	bx
		call	GET_IS_LY
		cmp	ax,0
		jne	LOOKUP_END
		
	; adjust for leap year
		; store legnth in bx
		mov	bx,29
		jmp	VALIDATE
		
	;get the legnth of the month from array
	LOOKUP_END:
		mov	bx,MON
		lea	dx,MON_LEN
		push	bx
		push	dx
		call	GET_ELEMENT_VAL
		; store legnth in bx
		mov	bx,ax
			
	; validate date in range
	;ax=entered date, bx=month end
	VALIDATE:
		pop	ax
		cmp	ax,bx
		ja	INVALID
		cmp	ax,1
		jb	INVALID
		jmp	VALID		
	
	INVALID:
		mov	ax,0
		lea	dx,ERR_DATE
		push	ax
		push	dx
		call 	PRINT_MEMBER
		mov	ax,bx
		mov	bh,0
		call	PUTDEC$
		call	NEWLINE
		jmp	PROMPT
		
	VALID:
	
	POPF
	RET
	
VALID_DATE	ENDP

COMMENT*
	GET_IS_LY
	Erick Veil
	10-28-11
	PRE: Pass the year via the stack
	POST: Retrns 0 if a leap year, non 0 if not
*
GET_IS_LY	PROC	NEAR PUBLIC uses dx bx, YEAR:WORD
	PUSHF
	
	mov	dx,0
	mov	ax,YEAR
	mov	bx,4
	div	bx
	mov ax,dx
	
	POPF
	RET
	
GET_IS_LY	ENDP

COMMENT*
	PRINT_MEMBER
	Erick Veil
	10-28-11
	PRE: pass the start location via the stack, then pass the 
	arrray name that starts the memory offset
	POST: prints the element at subscript. 
	Elements separated by $
*
PRINT_MEMBER	PROC	NEAR PUBLIC uses dx, SUBSCRIPT:WORD, ARRAY:WORD
	PUSHF

	mov	dx,ARRAY
	add	dx,SUBSCRIPT
	mov	ah,09
	int	21H
	
	POPF
	RET
	
PRINT_MEMBER	ENDP

COMMENT*
	GET_ELEMENT_VAL
	Erick Veil
	10-28-11
	PRE: pass the array subscript via the stack, then pass the 
	arrray name that starts the memory offset
	eg: lea dx,ARRAY..push dx
	POST: returns the contents of ARRAY at element SUBSCRIPT
*
GET_ELEMENT_VAL	PROC	NEAR PUBLIC uses di, SUBSCRIPT:WORD, ARRAY:WORD
	PUSHF
	
	mov	di,ARRAY
	add	di,SUBSCRIPT
	mov	al,[di]
	cbw
	
	POPF
	RET
GET_ELEMENT_VAL	ENDP


END		MAIN
