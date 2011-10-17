EXTRN	PUTDEC$:FAR
EXTRN	PUTBIN:FAR
EXTRN	NEWLINE:FAR

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
	
	ROT_1	DW	10
	ROT_2	DW	9
	ROT_4	DW	7
	ROT_8	DW	3
	
	TESTVAL	DW	00FFH

.CODE 
	ASSUME	DS:DSEG
MAIN	PROC	FAR

	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	
	MOV		AX,TESTVAL
	MOV		BL,0
	CALL	PUTDEC$
	
	CALL	NEWLINE	
	
	MOV		BL,1
	CALL	PUTBIN
		
	CALL	NEWLINE	
	
	PUSH	TESTVAL
	CALL	SETUP
	
	CALL	PUTBIN
	CALL	NEWLINE	
	
	PUSH	AX
	CALL	ENCODING
	
	CALL	PUTBIN
		
.EXIT
MAIN	ENDP

COMMENT*
	ENCODING
	Erick Veil
	10-17-11
	PRE: Pass 11 bit value with the data bits set but not parity bits
		via stack
	POST: Returns 11 bit value with all parity bits set via AX
*
ENCODING	PROC	NEAR PUBLIC	PACKET:WORD
	PUSHF
	
	PUSH	PACKET
	PUSH	MASK_8
	PUSH	ROT_8
	CALL	MASKING
	
	PUSH	AX
	PUSH	MASK_4
	PUSH	ROT_4
	CALL	MASKING

	PUSH	AX
	PUSH	MASK_2
	PUSH	ROT_2
	CALL	MASKING
	
	PUSH	AX
	PUSH	MASK_1
	PUSH	ROT_1
	CALL	MASKING
	
	POPF
	RET
ENCODING	ENDP

COMMENT*
	MASKING
	Erick Veil
	10-17-11
	PRE: Pass via the stack: PACKET as an 11 bit vlaue with data 
		bits set, BMASK as 11 bit value for the parity mask to be 
		used, then PSHIFT, which is the number of places to 
		shift the parity bit in order to set it. This number is 
		11 minus the final position of the parity bit.
	POST: Returns the 11 bit PACKET via AX with one of the 
	parity bits set
*
MASKING	PROC	NEAR PUBLIC	PACKET:WORD, BMASK:WORD, PSHIFT:BYTE
	PUSHF
	
	MOV		AX,PACKET
	AND		AX,BMASK
	PUSH	AX
	CALL	PARITY
	MOV		CL,PSHIFT
	ROL		AX,CL
	OR		AX,PACKET
	
	POPF
	RET
MASKING	ENDP

COMMENT*
	SETUP
	Erick Veil
	10-16-11
	PRE: Pass PACKET via the stack, a 7 bit value to be encoded
	POST: Returns via AX an 11 bit value with the data bits set, 
	ready for parity bits to be set.
*
SETUP	PROC	NEAR PUBLIC	PACKET:WORD
	PUSHF
	
	MOV		AX,PACKET
	AND		AX,MASK_A
	MOV		CODE,AX
	
	MOV		AX,PACKET
	AND		AX,MASK_B
	ROL		AX,1
	OR		CODE,AX
		
	MOV		AX,PACKET
	AND		AX,MASK_C
	MOV		CL,2
	ROL		AX,CL
	OR		AX,CODE
	
	POPF
	RET
SETUP	ENDP

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