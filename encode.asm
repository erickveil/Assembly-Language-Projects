EXTRN	PUTDEC$:FAR

PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG
	CODE	DW	0000000000000000B
	MASK_A	DW	0000000000000111B
	MASK_B	DW	0000000000111000B
	MASK_C	DW	0000000001000000B
	
	MASK_1	DW	0000010101010101B
	MASK_2	DW	0000001100110011B
	MASK_4	DW	0000000011110000B
	MASK_8	DW	0000000000001111B

.CODE 
	ASSUME	DS:DSEG
MAIN	PROC	FAR

	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	
	PUSH	MASK_1
	CALL	PARITY
	
	MOV		BL,0
	CALL	PUTDEC$

	
.EXIT
MAIN	ENDP

COMMENT*
	PARITY
	Erick Veil
	10-16-11
	PRE: PUSH value to be processed
	POST: Counts the number of set bits in the value passed
		and returns wether there is an even or odd number 
		of them via AX.
*
PARITY	PROC	NEAR PUBLIC	BITVAL:WORD
	PUSHF
	
	PUSH	BITVAL
	CALL	BITCOUNT
	PUSH	AX
	CALL	EVENODD
	
	POPF
	RET
PARITY	ENDP

COMMENT*
	BITCOUNT
	Erick Veil
	10-13-11
	Counts the number of bits in a 16 bit binary word
	word is passed on the stack
	Value returned in AL
*
BITCOUNT	PROC	NEAR PUBLIC USES CX BX, BINVAL:WORD
	PUSHF
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
	POPF
	RET
BITCOUNT	ENDP

COMMENT*
	EVENODD
	Erick Veil
	10-13-11
	Pre: pass a number via the stack
	Post: returns via AX 0 if even, 1 if odd
*
EVENODD		PROC	NEAR PUBLIC	USES CX, ONESCOUNT:WORD
	PUSHF
	MOV		AX,ONESCOUNT
	AND		AX,1
	POPF
	RET
EVENODD		ENDP

; Procs here

END		MAIN