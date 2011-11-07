COMMENT*
	array.asm
	Erick Veil
	10-31-2011
	
	Input numeric date and learn the day of the week.
	An exercise showing the use of simulated arrays
	using memory offsets in asm

*

EXTRN	GETDEC$:FAR
EXTRN	PUTDEC$:FAR
EXTRN	PUTSTRNG:FAR
EXTRN	NEWLINE:FAR
EXTRN	PUTBIN:FAR
EXTRN	PAUSE:FAR
EXTRN	CLEAR:FAR
EXTRN	BLANKS:FAR

PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG
	; each bit is a cup. 1 = marble, 0 = empty
	CUPS	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	CUPS_SZ	dw	6 ; twice the number of word elements in CUPS
	B_MASK	dw	1000000000000000b
	MSG_PAUSE	db	'Press a key to continue..' ;25
	REP_VAL	dw	0
	DELIM	db	', '
	PASS	dw	1
	
	
.CODE 
	ASSUME	DS:DSEG,ES:DSEG
MAIN	PROC	FAR
	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	MOV		ES,AX
	
	call	NEWLINE
	call	REPORT
	
	call	NEWLINE
	lea		di,MSG_PAUSE
	mov		cx,25
	call	PAUSE
	
	
.EXIT
MAIN	ENDP

COMMENT*
	REPORT
	Erick Veil
	10-28-11
	PRE: CUPS array set up with bits to read
	POST: prints to screen the position of each bit that is turned on
*
REPORT	PROC	NEAR PUBLIC uses ax bx cx dx
	PUSHF
	
	mov		cx,0	;count number of array places
	offset_loop:
		push	cx
		lea		dx,CUPS
		push	dx
		call 	GET_ELEMENT_VAL
		
		; ax now holds word from array
		mov		REP_VAL,ax
		
		mov		bx,1	;offset bit mask place 
		display_loop:
			; mask current bit and test for 0 or 1
			and	ax,B_MASK
			cmp	ax,0
			je	skip_print
				; masked value is not 0, so print the cup number
				mov		ax,bx	;move cup number for printing
				call	PUTDEC$
				;print deliminator
				push	cx
				lea		di,DELIM
				mov		cx,2
				call	PUTSTRNG
				pop		cx
			skip_print:
				; advance mask bit to next place in the word
				inc	bx
				ror	B_MASK,1
				;restore ax to word for next comparison
				mov		ax,REP_VAL
		; if bit mask is not at position 1, loop within word.
		; else loop to next array element
		cmp	bx,17
		jne	display_loop
	; increment array element and loop array if not at the end
	inc	cx
	inc	cx	; each element is 8 bits, but we read in 16
	cmp	cx,CUPS_SZ
	jne	offset_loop		
	; else, we're done
	
	POPF
	RET
	
REPORT	ENDP

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
	mov	ax,[di]
		
	POPF
	RET
GET_ELEMENT_VAL	ENDP

COMMENT*
	PRINT_MEMBER
	Erick Veil
	10-28-11
	PRE: pass the start location of the string via the stack, then pass the 
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


END		MAIN
