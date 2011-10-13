


EXTRN	PUTHEX:FAR
EXTRN	PUTDEC$:FAR
EXTERN	PUTBIN:FAR
EXTERN	NEWLINE:FAR

PAGE		80,132
.MODEL		SMALL, C
.STACK		64
.DATA
	TEST_WRD	DW	15
.CODE 

MAIN	PROC	FAR	PUBLIC

	MOV		AX,	SEG	DGROUP
	MOV		DS,AX
	
	
	; print in decimal
	MOV		AX,TEST_WRD
	MOV		BH,0
	CALL	PUTDEC$
	
	; Make call
	MOV		BX,TEST_WRD
	PUSH	BX
	CALL 	BITCOUNT

	; the count
	CALL	NEWLINE
	MOV		BH,0
	CALL	PUTDEC$
	
	; the number in bin
	CALL	NEWLINE
	MOV		BL,1
	MOV		AX,TEST_WRD
	CALL	PUTBIN
	
	CALL	NEWLINE
	
	
	
.EXIT
MAIN	ENDP

COMMENT*
	BITCOUNT
	Erick Veil
	10-13-11
	Counts the number of bits in a 16 bit binary word
	word is passed on the stack
	Value returned in AL
*
BITCOUNT	PROC	NEAR PUBLIC USES CX BX, BINVAL:WORD
	MOV		BX,BINVAL	; working value
	MOV		CX,16		; 16 bit count
	SUB		AX,AX		; holds number of 1s
	ROTATE:
		ROL		BX,1
		JNC		NEXT
		; if 1
		INC		AL
	NEXT:
		LOOP	ROTATE	
	RET
BITCOUNT	ENDP

COMMENT*
	EVENODD
	Erick Veil
	10-13-11
	Pre: pass a number via the stack
	Post: returns 0 if even, 1 if odd
*
EVENODD		PROC	NEAR PUBLIC	ONESCOUNT:WORD
	
EVENODD		ENDP

; Procs here
	
END		MAIN