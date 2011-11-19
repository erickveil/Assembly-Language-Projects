
COMMENT*
	bcd.asm
	Erick Veil
	10-31-2011
	
*

EXTRN	PUTDEC$:FAR
EXTRN	GETDEC$:FAR
EXTRN	PUTSTRNG:FAR
EXTRN	NEWLINE:FAR
EXTRN	PAUSE:FAR
EXTRN	CLEAR:FAR
EXTRN	BLANKS:FAR
EXTRN	GETSTRNG:FAR

PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG
	digbot	dw	21
	digtop	dw	21
	top		db	21 dup (0)
	bottom	db	21 dup (0)
	product	db	21 dup (0)
	CARRY	db	0
	MSG_PAUSE	db	'Press a key to continue..' ;25
	PROMPT_TOP	db	'Enter the first number:  ' ;25
	PROMPT_BOT	db	'Enter the second number: ' ;25
	HEAD		db	'*** BCD Multiplication by Erick Veil ***' ;40

.CODE 
	ASSUME	DS:DSEG,ES:DSEG
MAIN	PROC	FAR
	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	MOV		ES,AX

	call	BODY
	
.EXIT
MAIN	ENDP

BODY		PROC	NEAR PUBLIC
	PUSHF

	call	HEADER
	call	INPUTTOP
	call	INPUTBOT
	call	NEWLINE
	call	BCDMUL
	call	PRINTPRODUCT
	lea		di,MSG_PAUSE
	mov		cx,25
	call	PAUSE	
	
	POPF
	RET
BODY		ENDP

HEADER		PROC	NEAR PUBLIC
	PUSHF

	call	NEWLINE	
	mov		cx,40
	lea		di, HEAD
	call	PUTSTRNG	
	call	NEWLINE
	call	NEWLINE
	
	POPF
	RET
HEADER		ENDP

INPUTBOT		PROC	NEAR PUBLIC
	PUSHF
	
	; prompt
	mov		cx,25
	lea		di, PROMPT_BOT
	call	PUTSTRNG	
	; get input as string
	lea		di,bottom
	mov		cx,digbot
	call	GETSTRNG	
	; convert input array to integer array
	lea		di,bottom
	mov		cx,digbot
	push	cx
	call	STRTOINT
	
	POPF
	RET
INPUTBOT		ENDP

INPUTTOP		PROC	NEAR PUBLIC
	PUSHF
	
	; prompt
	mov		cx,25
	lea		di, PROMPT_TOP
	call	PUTSTRNG	
	; get input as string
	lea		di,top
	mov		cx,digbot
	call	GETSTRNG	
	; convert input array to integer array
	lea		di,top
	mov		cx,digtop
	push	cx
	call	STRTOINT
	
	POPF
	RET
INPUTTOP		ENDP

; converts string of ascii to array of integers
; load the start of the array into di, push the size of the array to the stack
STRTOINT		PROC	NEAR PUBLIC		max:word
	PUSHF

	; dx is element for searching
	mov		dx,max
	; cx is element for printing
	mov		cx,max
	dec		cx
	; bx is memory offset
	mov		bx,0
	; ah is 0 constant for code requirements
	mov		ah,0

	strintloop:
		dec		dx
		mov		bx,dx	
		; check for trailing zeros (ascii zeros = 48)
		cmp		[di+bx],ah
		je		strintloop

		; digit is ascii number, convert it
		mov		al,[di+bx]
		sub		al,48
		; place converted number in appropriate element
		mov		bx,cx
		mov		[di+bx],al
		; move to next print element
		dec		cx
		; check to see if whole search completed	
		cmp		dx,0
		jne		strintloop
		; search completed, fill rest of array with zeros
		cmp		cx,0
		jne		startfill
		jmp		donefill
		loopfill:
			dec		cx
		startfill:
			mov		bx,cx
			mov		[di+bx],ah
			; check if whole array filled
			cmp		cx,0
			jne		loopfill
		donefill:	
	POPF
	RET
STRTOINT		ENDP

; di set to element place, bh is value before halving
; test (di not lsb) and (bh is odd)
; if true, di+1 = +5
SETBORROW		PROC	NEAR PUBLIC uses ax bx
	PUSHF
	
	; skip if lsb
	mov		bx,digbot
	dec		bx
	cmp		di,bx
	je		endborrow
		; skip if even
		mov		al,bottom[di]
		cbw
		push	ax
		call	EVENODD
		cmp		ax,0
		je	endborrow
			add		bottom[di+1],5	
	endborrow:			
	
	POPF
	RET
SETBORROW		ENDP

ADDLOOP		PROC	NEAR PUBLIC uses di bx cx
	PUSHF
	
	; di is element. 20 max
	mov		di,digtop
	; ch is carry
	mov		ch,0
	add_loop:
		dec		di
		mov		bh,top[di]
		mov		bl,product[di]
		; add digits plus carry
		add		bl,bh
		add		bl,ch
		; check for carry
		cmp		bl,10
		jl		noaddcarry
			; set carry 1
			mov		ch,1
			sub		bl,10
			jmp		endaddcarry
		noaddcarry:
			; set carry 0
			mov		ch,0	
		endaddcarry:
			; stick the sum in the array
			mov		product[di],bl

			; next element
			cmp		di,0
	jne		add_loop
	
		
	POPF
	RET
ADDLOOP		ENDP

DUBLOOP		PROC	NEAR PUBLIC uses bx cx di
	PUSHF
	
	; di is element. 20 max
	mov		di,digtop
	; ch is carry
	mov		ch,0
	
	dub_loop:
		dec		di
		mov		bh,top[di]
		
		shl		bh,1
		add		bh,ch
		call	SETCARRY
		
		mov		top[di],bh
	cmp		di,0
	jne		dub_loop
	
	POPF
	RET
DUBLOOP		ENDP

; test bh for more than one digit
; if found, set ch to tend place and bh to ones
SETCARRY		PROC	NEAR PUBLIC
	PUSHF
	
	cmp		bh,10
	jl		nocarry
		mov		ch,1
		sub		bh,10
		jmp		endcarry
	nocarry:
		mov		ch,0
	endcarry:
	
	POPF
	RET
SETCARRY		ENDP

BLNK		PROC	NEAR PUBLIC uses bx dx
	PUSHF
	
	mov		bh,0
	mov		dx,1
	call	BLANKS
	
	POPF
	RET
BLNK		ENDP

HAFLOOP		PROC	NEAR PUBLIC uses bx di
	PUSHF
	
	; di is element. 10 max
	mov		di,digbot
	; ch is carry
	mov		ch,0
	
	haf_loop:
		dec		di
		mov		bl,bottom[di]
		
		call	SETBORROW
		shr		bl,1
		
		mov		bottom[di],bl
	cmp		di,0
	jne		haf_loop
	
	POPF
	RET
HAFLOOP		ENDP

; returns via al: 0 id empty array, 1 if not empty
GETISZERO		PROC	NEAR PUBLIC uses bx di
	PUSHF
	
	; di is element. 10 max
	mov		di,digbot
	; al is flag 0 = empty array
	mov		al,0	
	zero_loop:
		dec		di
		;check element for 0
		mov		bl,bottom[di]	
		cmp		bl,0
		je		iszero
			; not zero, set flag and break
			mov		al,1
			jmp		loop_break
		iszero:
	cmp		di,0
	jne		zero_loop
	loop_break:
	
	POPF
	RET
GETISZERO		ENDP

; pass top value in bh, bottom value in bl
; returns accumulated value in cl and shifted values in bh and bl
BCDMUL		PROC	NEAR PUBLIC
	PUSHF
	
	main_loop:
		mov	di,digbot
		dec	di
		; test lsb for odd/even
		mov		al,bottom[di]
		cbw
		push	ax
		call	EVENODD
		cmp		ax,0
		je		noadd
		; odd, add to accumulator
			call	ADDLOOP
		noadd:		
		; double top, add carry
		call	DUBLOOP
		; half bottom, add borrows
		call	HAFLOOP
	; continue until bottom value is zero

;call	NEWLINE
	call	GETISZERO
	cmp		al,0
	jne		main_loop	
	
	POPF
	RET
BCDMUL		ENDP

PRINTPRODUCT	PROC	NEAR PUBLIC uses ax bx di
	PUSHF
	
	; di is element
	mov		di,0
	; ah is trailing zero flag
	mov		ah,0
	printloop:
		; if zero, check trailing zero flag
		cmp		product[di],0
		jne		validprint
		; if flag = 0, skip this print
		cmp		ah,0
		je		nextprint	
		validprint:
			; print digits
			mov		al,product[di]
			cbw
			mov		bh,0
			call	PUTDEC$
			; set trailing flag
			mov		ah,1
	; next element
	nextprint:
	inc		di
	cmp		di,digtop
	jne		printloop
	call	NEWLINE
	call	NEWLINE
	
	POPF
	RET

PRINTPRODUCT	ENDP

PRINTTOP	PROC	NEAR PUBLIC uses ax bx di
	PUSHF
	
	; di is element
	mov		di,0
	printloop:
		mov		al,top[di]
		cbw
		mov		bh,0
		call	PUTDEC$
	inc		di
	cmp		di,digtop
	jne		printloop
	call	NEWLINE
	
	POPF
	RET

PRINTTOP	ENDP

PRINTBOTTOM	PROC	NEAR PUBLIC uses ax bx di
	PUSHF
	
	; di is element
	mov		di,0
	printloop:
		mov		al,bottom[di]
		cbw
		mov		bh,0
		call	PUTDEC$
	inc		di
	cmp		di,digbot
	jne		printloop
	call	NEWLINE
	
	POPF
	RET

PRINTBOTTOM	ENDP


COMMENT*
	EVENODD
	Erick Veil
	10-13-11
	Pre: pass a number via the stack
	Post: returns via AX 0 if even, 1 if odd
*
EVENODD		PROC	NEAR PUBLIC	ONESCOUNT:WORD
	PUSHF
	MOV		AX,ONESCOUNT
	AND		AX,1
	POPF
	RET
EVENODD		ENDP



END		MAIN
