;	randmain.asm
;	calls the random procedure
;	erick veil
;	9-30-11
	PAGE    80,132
;===================================================================
	DOSSEG
	.MODEL  SMALL,BASIC,FARSTACK
	
	;externals
	EXTRN   RANDOM:FAR
	EXTRN   RESEED:FAR
	EXTRN	PUTDEC$:FAR
	EXTRN	PUTHEX:FAR
	EXTRN	PUTSTRNG:FAR
	EXTRN	NEWLINE:FAR
	EXTERN	PAUSE:FAR
	EXTERN	CLEAR:FAR
	
	.STACK  256	; stack segment
	
	.CONST
		DELIM		DB	', '
		THEEND		DB	'Press any key to finish..'
		HEAD		DB	'*** Randmain.asm By Erick Veil ***'
		BAT1_MSG_A	DB	'Batch 1: 5555h'			;14
		BAT2_MSG_A	DB	'Batch 2: Clock'
		BAT1_MSG_B	DB	'Batch 1 totals for 5555h:' ;25
		BAT2_MSG_B	DB	'Batch 2 totals for clock:'	;25
		TOT_MSG		DB	'Combined totals:'			;16
		EV_MSG		DB	'Evens: '					;7
		OD_MSG		DB	', Odds: '					;8
		HI_MSG		DB	', Highs: '					;9
		LO_MSG		DB	', Lows: '					;8
	.DATA
		;variables
		UPPER		DW	0
		LOWER		DW	0
		BATCH		DW  0
		;data collection
		FIRST_HIGH	DW	0
		FIRST_LOW	DW	0
		FIRST_EVEN	DW	0
		FIRST_ODD	DW	0
		
		SECOND_HIGH	DW	0
		SECOND_LOW	DW	0
		SECOND_EVEN	DW	0
		SECOND_ODD	DW	0
		
		TOTAL_HIGH	DW	0
		TOTAL_LOW	DW	0
		TOTAL_EVEN	DW	0
		TOTAL_ODD	DW	0

	.CODE
randmain:
	;set up data stack pointer
	MOV     AX,SEG DGROUP
	MOV     ES,AX
	
	MOV		LOWER,0
	MOV		UPPER,9999

	; Headding
	CALL	CLEAR
	MOV 	CX,34
	LEA		DI,HEAD
	CALL 	PUTSTRNG
	CALL	NEWLINE
	CALL	NEWLINE

	MOV		BL,1
	MOV 	AX,5555h
	
	MOV		CX,2
	batch_loop:
		MOV BATCH,CX
		
		batch_heads:
			CALL BATHEAD


		PUSH	CX	
		CALL	RESEED
		
		MOV		CX,100
		call_loop:
			PUSH	LOWER
			PUSH	UPPER
			CALL	RANDOM
			
			collect_data:
				;CALL COLLECTDAT
				
			display_result:
				PUSH	BX
				MOV		BH,0
				CALL	PUTDEC$
				POP		BX

				CMP		CX,1
				JE		skip_delim
			deliminator:
				PUSH 	CX
				LEA		DI,DELIM
				MOV		CX,2
				CALL 	PUTSTRNG
				POP		CX
			skip_delim:
				;CALL NEWLINE
		LOOP call_loop		
		POP		CX	
		
		MOV		BL,0
		CALL NEWLINE
		CALL NEWLINE
	
	LOOP batch_loop
	report:
		CALL TALLYDAT
		;CALL PRINTDAT
	; cleanup
	CALL NEWLINE
	MOV		CX,25
	LEA		DI,THEEND
	CALL	PAUSE
	
	.EXIT
	
	COMMENT *
		COLLECTDAT
		Erick Veil
		10-05-11
		
		Collects data on random numbers
	*
	COLLECTDAT		PROC	FAR	PUBLIC
		PUSH AX
		PUSH DX
		.IF BATCH == 2
			.IF AX < 5000
				ADD FIRST_LOW,1
			.ELSE
				ADD FIRST_HIGH,1
			.ENDIF
			MOV DX,2
			IDIV DX
			.IF DX == 1
				ADD FIRST_ODD,1
			.ELSE
				ADD FIRST_EVEN,1
			.ENDIF
			
		.ELSE
			.IF AX < 5000
				ADD SECOND_LOW,1
			.ELSE
				ADD SECOND_HIGH,1
			.ENDIF
			
			MOV DX,2
			IDIV DX
			.IF DX == 1
				ADD SECOND_ODD,1
			.ELSE
				ADD SECOND_EVEN,1
			.ENDIF
		.ENDIF
		POP DX
		POP AX
	COLLECTDAT		ENDP
	
	COMMENT *
		PRINTDAT
		Erick Veil
		10-05-11
		
		Prints data on random numbers
	*
	PRINTDAT		PROC	FAR	PUBLIC
		CALL	NEWLINE
		MOV		CX,25
		LEA		DI,BAT1_MSG_B
		CALL	PUTSTRNG
		
		CALL	NEWLINE
		MOV		CX,7
		LEA		DI,EV_MSG
		CALL	PUTSTRNG
		MOV		AX,FIRST_EVEN
		CALL	PUTDEC$
		MOV		CX,8
		LEA		DI,OD_MSG
		CALL	PUTSTRNG
		MOV		AX,FIRST_ODD
		CALL	PUTDEC$
		MOV		CX,9
		LEA		DI,HI_MSG
		CALL	PUTSTRNG
		MOV		AX,FIRST_HIGH
		CALL	PUTDEC$
		MOV		CX,8
		LEA		DI,LO_MSG
		CALL	PUTSTRNG
		MOV		AX,FIRST_LOW
		CALL	PUTDEC$
		
		CALL	NEWLINE
		MOV		CX,25
		LEA		DI,BAT2_MSG_B
		CALL	PUTSTRNG
		
		CALL	NEWLINE
		MOV		CX,7
		LEA		DI,EV_MSG
		CALL	PUTSTRNG
		MOV		AX,SECOND_EVEN
		CALL	PUTDEC$
		MOV		CX,8
		LEA		DI,OD_MSG
		CALL	PUTSTRNG
		MOV		AX,SECOND_ODD
		CALL	PUTDEC$
		MOV		CX,9
		LEA		DI,HI_MSG
		CALL	PUTSTRNG
		MOV		AX,SECOND_HIGH
		CALL	PUTDEC$
		MOV		CX,8
		LEA		DI,LO_MSG
		CALL	PUTSTRNG
		MOV		AX,SECOND_LOW
		CALL	PUTDEC$
		
		CALL	NEWLINE
		CALL	NEWLINE
		MOV		CX,25
		LEA		DI,TOT_MSG
		CALL	PUTSTRNG
		
		MOV		CX,7
		LEA		DI,EV_MSG
		CALL	PUTSTRNG
		MOV		AX,TOTAL_EVEN
		CALL	PUTDEC$
		MOV		CX,8
		LEA		DI,OD_MSG
		CALL	PUTSTRNG
		MOV		AX,TOTAL_ODD
		CALL	PUTDEC$
		MOV		CX,9
		LEA		DI,HI_MSG
		CALL	PUTSTRNG
		MOV		AX,TOTAL_HIGH
		CALL	PUTDEC$
		MOV		CX,8
		LEA		DI,LO_MSG
		CALL	PUTSTRNG
		MOV		AX,TOTAL_LOW
		CALL	PUTDEC$
		
	PRINTDAT		ENDP
	
	COMMENT *
		TALLYDAT
		Erick Veil
		10-05-11
		
		Calculates Totals
	*
	TALLYDAT		PROC	FAR	PUBLIC
		PUSH AX
		
		MOV AX,0
		ADD AX,FIRST_HIGH
		ADD AX,SECOND_HIGH
		MOV TOTAL_HIGH,AX
		
		MOV AX,0
		ADD AX,FIRST_LOW
		ADD AX,SECOND_LOW
		MOV TOTAL_LOW,AX

		MOV AX,0
		ADD AX,FIRST_EVEN
		ADD AX,SECOND_EVEN
		MOV TOTAL_EVEN,AX
		
		MOV AX,0
		ADD AX,FIRST_ODD
		ADD AX,SECOND_ODD
		MOV TOTAL_ODD,AX
		
		POP AX
	TALLYDAT		ENDP

	COMMENT *
		BATHEAD
		Erick Veil
		10-05-11
		
		Prints headers for batches
	*
	BATHEAD		PROC	FAR	PUBLIC
		PUSH	CX
		PUSH	DX
		.IF BATCH == 2
			LEA		DI,BAT1_MSG_A
		.ELSE
			LEA		DI,BAT2_MSG_A
		.ENDIF
		MOV CX,14
		CALL PUTSTRNG
		POP		DX
		POP		CX	
	BATHEAD		ENDP
	
END     randmain
;===================================================================
