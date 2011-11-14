
COMMENT*
	fibo.asm
	Erick Veil
	10-31-2011
	
*

EXTRN	PUTDEC$:FAR
EXTRN	GETDEC$:FAR
EXTRN	PUTSTRNG:FAR
EXTRN	NEWLINE:FAR
EXTRN	PAUSE:FAR
EXTRN	CLEAR:FAR

PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG
	AUGEND	db	72 dup (0)
	ADDEND	db	72 dup (0)
	CARRY	db	0
	MSG_PAUSE	db	'Press a key to continue..' ;25
	MSG_OVER	db	'Overflow detected.' ;18
	MSG_PROMPT	db	'Enter the number of Fibionacci iterations to perform: ' ;54

.CODE 
	ASSUME	DS:DSEG,ES:DSEG
MAIN	PROC	FAR
	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	MOV		ES,AX
	
	call	BODY
	
	
.EXIT
MAIN	ENDP

BODY	PROC	NEAR PUBLIC
	PUSHF
	
	; input
	call	NEWLINE
	lea		di,MSG_PROMPT
	mov		cx,54
	call	PUTSTRNG
	call	GETDEC$
	; ax holds the max number of iteraions
	
	; intitialization
	mov		di,71
	mov		AUGEND[di],1
	mov		ADDEND[di],1
	
	; main loop
	call	ITLOOP
	
	; output
	call	REPORT	
	call	NEWLINE
	mov		cx,25
	lea		di,MSG_PAUSE
	call	PAUSE
	
	POPF
	RET
BODY	ENDP

ITLOOP	PROC	NEAR PUBLIC
	PUSHF
	
	; bx holds the current number of iteration loops
	; ax holds the maximum loops
	mov		bx,0
	iteration_loop:	
		call	ADDARRAY		
		; overflow check		
		cmp		CARRY,0
		je		end_summation
			; here, we are at array position 0, and carry = 1
			call	NEWLINE
			lea		di,MSG_OVER
			mov		cx,18
			call	PUTSTRNG
			call	NEWLINE
			jmp		end_iteration
	end_summation:
		inc		bx		
		cmp		ax,bx
		jne		iteration_loop	
	end_iteration:	
	
	POPF
	RET
ITLOOP	ENDP


ADDARRAY	PROC	NEAR PUBLIC	uses ax cx bx di
	PUSHF
	
	; cx counts sumation loop iterations
	mov		cx,71
	summand_loop:	
		mov		di,cx
		; add with carry: A=A+B+carry
		mov		al,ADDEND[di]
		add		al,AUGEND[di]
		add		al,CARRY		
		mov		ADDEND[di],al		
		cmp		ADDEND[di],10
		jb		else_no_carry
		; carry 
			mov		CARRY,1
			sub		ADDEND[di],10
			mov		ADDEND[di-1],1
			jmp		endif_carry
		else_no_carry:
			mov		CARRY,0
		endif_carry:
			call	SWAP_ARRAY
			
	; next loop
	dec		cx
	cmp		cx,0
	jne		summand_loop
	
	POPF
	RET
ADDARRAY	ENDP

; swaps the addend and augend arrays
SWAP_ARRAY	PROC	NEAR PUBLIC	uses ax bx cx di
	PUSHF
	
	mov		cx,72
	swap_loop:
		dec		cx
		mov		di,cx
		mov		al,ADDEND[di]
		mov		bl,AUGEND[di]
		mov		ADDEND[di],bl
		mov		AUGEND[di],al
	cmp		cx,0
	jne		swap_loop
	
	POPF
	RET
SWAP_ARRAY	ENDP

; prints the addend array
REPORT	PROC	NEAR PUBLIC	uses ax cx bx di
	PUSHF
	
	call	NEWLINE
	mov		cx,0
	print_loop:

		mov		di,cx
		mov		al,AUGEND[di]
		cbw
		
		; remove trailing zeros
		cmp		bl,1
		je		skip_check
		cmp		AUGEND[di],0
		je		skip_trails		
		mov		bl,1
		skip_check:
		mov		bh,0
		call	PUTDEC$		
		skip_trails:
			inc		cx		
	cmp		cx,72
	jne		print_loop
	call	NEWLINE
	
	POPF
	RET
REPORT	ENDP


END		MAIN


