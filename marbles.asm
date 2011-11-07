COMMENT*
	marbles.asm
	Erick Veil
	10-31-2011
	for each cup looked at, if it is empty, add a marble, if it is full, 
	take a marble. N=1 on the first iteration, N=2 on the second, etc. 
	Check every Nth cup until N=500. Observe what cups have marbles.
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
	CUPS	dw	31 dup (0)
	CUPS_SZ	dw	4 ; twice the number of word elements in CUPS
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
	
	mov		bx,0
	mov		ax,CUPS[bx]
	push	ax
	push	bx
	call	TOGGLE
	
	
	call	NEWLINE
	call	REPORT
	
	
	call	NEWLINE
	lea		di,MSG_PAUSE
	mov		cx,25
	call	PAUSE
	
	
.EXIT
MAIN	ENDP
COMMENT*
	TOGGLE
	Erick Veil
	11-07-11
	PRE:	pass 16 bit sequence via stack, 
		PASS should be set to N, the iteration number 
		and every Nth cup to check
	POST: 
*
TOGGLE	PROC	NEAR PUBLIC	CUP_WORD:WORD,SUBSCRIPT:WORD
	PUSHF
	
	mov	ax,SUBSCRIPT
	call	PUTDEC$
	call	NEWLINE
	
	; couter ax = 16/N
	mov		bx,PASS
	mov		ax,16
	mov		dx,0
	div		bx
	
	mov		bx,CUP_WORD
	
		
	toggle_loop:
		; each iteration, look at a place, flip its bit only
		xor		bx,B_MASK		
		
		; move toggle bit over N
		mov		cx,PASS
		ror		B_MASK,cl	; after PASS 127, this will cause problems	
		
		; next iteration
		dec		ax
		cmp		ax,0
	jne		toggle_loop
	; set the changed word back in the array
		
		push	ax
		push	bx
		mov		ax,bx
		mov		bl,1
		call	PUTBIN
		call	NEWLINE
		pop		bx
		pop		ax
		
	mov		CUPS[SUBSCRIPT],bx
		; though SUBSCRIPT = 0..
		push	ax
		push	bx
		mov		ax,CUPS[0]
		mov		bl,1
		call	PUTBIN
		call	NEWLINE
		pop		bx
		pop		ax
		; .. CUPS[SUBSCRIPT] != CUPS[0]
		push	ax
		push	bx
		mov		ax,CUPS[SUBSCRIPT]
		mov		bl,1
		call	PUTBIN
		call	NEWLINE
		pop		bx
		pop		ax
	
	POPF
	RET
	
TOGGLE	ENDP

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
	SET_ELEMENT_VAL
	Erick Veil
	11-07-11
	PRE: pass the array subscript via the stack, then pass the 
	arrray name that starts the memory offset
	eg: lea dx,ARRAY..push dx
	Then pass the value to set
	POST: sets the contents of ARRAY at element SUBSCRIPT to VAL
*
SET_ELEMENT_VAL	PROC	NEAR PUBLIC uses di, SUBSCRIPT:WORD, ARRAY:WORD, VAL:WORD
	PUSHF
	
	mov	di,ARRAY
	add	di,SUBSCRIPT
	;mov	[di],VAL
		
	POPF
	RET
SET_ELEMENT_VAL	ENDP

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
