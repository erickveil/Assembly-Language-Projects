COMMENT*
	PARITY
	Erick Veil
	10-13-11
	Counts the number of bits in a 16 bit binary word
	returns the binary of the word, the number of set bits
	and wether the number is even or odd.
	Loops to conduct 5 tests, then exits.
*

EXTRN	PUTHEX:FAR
EXTRN	PUTDEC$:FAR
EXTERN	PUTBIN:FAR
EXTERN	NEWLINE:FAR
EXTERN	GETDEC$:FAR
EXTERN	PAUSE:FAR
EXTERN	PUTSTRNG:FAR
EXTERN	CLEAR:FAR

PAGE		80,132
.MODEL		SMALL, BASIC
.STACK		64

.CONST
	HEAD		DB	'*** Parity.asm by Erick Veil ***'	;32
	PROMPT		DB	'Enter a number: '	;16
	MSG_BIN		DB	'Binary:         '	;16
	MSG_NUM		DB	'Set Bits:       '	;16
	MSG_EVN		DB	'Even number of bits.'	;20
	MSG_ODD		DB	'Odd Number of bits.'	;19
	MSG_CONT	DB	'Press a key to continue.. '	;26
.CODE 

MAIN	PROC	FAR	PUBLIC

	MOV		AX,	SEG	DGROUP
	MOV		ES,AX
	
	;headder
	CALL	CLEAR
	LEA		DI,HEAD
	MOV		CX,32
	CALL	PUTSTRNG
	CALL	NEWLINE
	CALL	NEWLINE
	
	MOV		CX,5	; test 5 values then quit
	MAIN_LOOP:	
		PUSH	CX	; counter save
			;Prompt
			LEA		DI,PROMPT
			MOV		CX,16
			CALL	PUTSTRNG
			CALL	GETDEC$

			; print the number in bin
			LEA		DI,MSG_BIN
			CALL	PUTSTRNG
			MOV		BL,1
			CALL	PUTBIN
			
			; Make call
			PUSH	AX
			CALL 	BITCOUNT

			; print the count
			CALL	NEWLINE
			LEA		DI,MSG_NUM
			CALL	PUTSTRNG
			MOV		BH,0
			CALL	PUTDEC$
			
			; even or odd?	
			PUSH	AX
			CALL	EVENODD
			CALL	PRINTRES
			
		POP	CX	;retreive counter
	LOOP	MAIN_LOOP
	
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

COMMENT*
	PRINTRES
	Erick Veil
	10-13-11
	Pre: pass a number via AX
	Post: prints result of evenodd test and pauses the loop
*
PRINTRES		PROC	NEAR PUBLIC
	; print the result
			CALL	NEWLINE
			CMP		AX,1
			JE		ODD
			
			;EVEN:
			LEA		DI,MSG_EVN
			MOV		CX,20
			CALL	PUTSTRNG
			JMP		FINISH

			ODD:
			LEA		DI,MSG_ODD
			MOV		CX,19
			CALL	PUTSTRNG

			FINISH:
			CALL	NEWLINE
			LEA		DI,MSG_CONT
			MOV		CX,26
			CALL	PAUSE	
			CALL	NEWLINE		
	RET
PRINTRES		ENDP

; Procs here
	
END		MAIN