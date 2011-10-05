    
;===================================================================
;                   RAND.ASM
;      r a n d o m   n u m b e r   g e n e r a t o r
;
; GENERATES PSEUDO-RANDOM INTEGERS IN THE RANGE LOWER TO UPPER
; INPUT:  TWO STACK PARAMETERS - LOWER AND UPPER ENDS OF RANGE
; OUTPUT: AX-REG CONTAINS RANDOM INTEGER
; CALLING SEQUENCE:     PUSH    <LOWER END OF RANGE>
;                       PUSH    <UPPER END OF RANGE>
;                       CALL    RANDOM
;===================================================================
.MODEL	SMALL,BASIC

	EXTRN		PUTHEX:FAR
	EXTRN		PUTDEC$:FAR
	EXTRN		NEWLINE:FAR

	FALSE		EQU	0
	TRUE		EQU	1
.FARDATA RAND_DATA
	SEED		DW		?
	MULTIPLIER	DW		25173
	ADDEND		DW		13849
	FIRST_CALL	DB		TRUE

.CODE	RAND
	ASSUME		DS:RAND_DATA
	RANDOM	PROC	FAR PUBLIC USES CX DX DS,
					LOWER:WORD, UPPER:WORD
					
		PUSHF
		MOV	AX,SEG RAND_DATA
		MOV	DS,AX
		
		.IF	FIRST_CALL == TRUE
			MOV		FIRST_CALL,FALSE
			MOV		SEED,DX
		.ENDIF
		
		MOV		AX,SEED
		MUL		MULTIPLIER
		ADD		AX,ADDEND
		MOV		SEED,AX
		MOV		CX,UPPER
		SUB		CX,LOWER
		INC		CX
		MUL		CX
		ADD		DX,LOWER
		MOV		AX,DX
		POPF
		RET
	RANDOM     ENDP

	COMMENT *
		RESEED
		Erick Veil
		10-04-11
		
		BL=0 use clock to seed
		BL=any other number, use AX to seed
	*
	RESEED		PROC	FAR	PUBLIC
		CMP		BL,1
		JE		alt_seed
		
		clock_seed:
			MOV		AH,0		;SEED = LOWER HALF OF
			INT		1AH			;TIME OF DAY CLOCK
			JMP		cont
		alt_seed:
			MOV		DX,AX		; Seed = AX passed value

		cont:
			RET
	RESEED		ENDP
	END

