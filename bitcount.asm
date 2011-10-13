


EXTRN	PUTHEX:FAR
EXTRN	PUTDEC$:FAR
EXTERN	PUTBIN:FAR
EXTERN	NEWLINE:FAR
EXTERN	GETDEC$:FAR
EXTERN	PAUSE:FAR
EXTERN	PUTSTRNG:FAR

PAGE		80,132
.MODEL		SMALL, C
.STACK		64
.DATA
	HEAD		DB	'*** Parity.asm by Erick Veil ***'	;32
	PROMPT		DB	'Enter a number: '	;16
	MSG_BIN		DB	'Binary:         '	;16
	MSG_NUM		DB	'Set Bits:       '	;16
	MSG_EVN		DB	'Even number of bits.'	;20
	MSG_ODD		DB	'Odd Number of bits.'	;19
.CODE 

MAIN	PROC	FAR	PUBLIC

	MOV		AX,	SEG	DGROUP
	MOV		DS,AX
	
	
	; print in decimal
	MOV		AX,TEST_WRD
	MOV		BH,0
	CALL	PUTDEC$
	; print the number in bin
	CALL	NEWLINE
	MOV		BL,1
	CALL	PUTBIN
	
	; Make call
	MOV		BX,TEST_WRD
	PUSH	BX
	CALL 	BITCOUNT

	; print the count
	CALL	NEWLINE
	MOV		BH,0
	CALL	PUTDEC$
	
	; even or odd?	
	PUSH	AX
	CALL	EVENODD
	
	; print the result
	CALL	NEWLINE
	MOV		BH,0
	CALL	PUTDEC$
	
	
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
	Post: returns via AX 0 if even, 1 if odd
*
EVENODD		PROC	NEAR PUBLIC	ONESCOUNT:WORD
	MOV		AX,ONESCOUNT
	AND		AX,1
	RET
EVENODD		ENDP

; Procs here
	
END		MAIN