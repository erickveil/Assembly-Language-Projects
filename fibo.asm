
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
	TEMP	db	72 dup (0)
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
	
	lea		di,MSG_PROMPT
	mov		cx,54
	call	PUTSTRNG
	call	GETDEC$
	; ax holds the max number of iteraions
	
	; intitialization
	mov		AUGEND[di],1
	mov		ADDEND[di],1
	; bx holds the current number of iteration loops
	mov		bx,0
	iteration_loop:
		; cx counts sumation loop iterations
		mov		cx,71
		mov		di,cx
		summand_loop:
			mov		di,cx
			; add with carry: A=A+B+carry
			push	ax
			mov		al,ADDEND[di]
			add		al,AUGEND[di]
			add		al,CARRY
			mov		ADDEND[di],al
			pop		ax
			cmp		ADDEND[di],10		
			jb		else_no_carry		
			; carry 
				mov		CARRY,1
				sub		ADDEND[di],10
				jmp		endif_carry
			else_no_carry:
				mov		CARRY,0
			endif_carry:
				call	SWAP_ARRAY
				dec		cx
				cmp		cx,0
		jne		summand_loop
		; overflow check
		cmp		CARRY,0
		je		end_summation
			; here, we are at array position 0, and carry = 1
			lea		di,MSG_OVER
			mov		cx,18
			call	PUTSTRNG
			jmp		end_iteration
	end_summation:
		inc		bx
		cmp		ax,bx
		jne		iteration_loop	
	end_iteration:	
		call	REPORT	
		call	NEWLINE
		mov		cx,25
		lea		di,MSG_PAUSE
		call	PAUSE	
.EXIT
MAIN	ENDP

; prints the addend array
REPORT	PROC	NEAR PUBLIC
	PUSHF
	
	mov		cx,72
	print_loop:
		dec		cx
		mov		di,cx
		mov		al,ADDEND[di]
		cbw
		mov		bh,0
		call	PUTDEC$
		
	cmp		cx,0
	jne		print_loop
	
	POPF
	RET
REPORT	ENDP

; swaps the addend and augend arrays
SWAP_ARRAY	PROC	NEAR PUBLIC	uses ax cx di
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
END		MAIN


