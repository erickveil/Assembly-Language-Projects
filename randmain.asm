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
	.DATA
		;variables
		UPPER		DW	0
		LOWER		DW	0

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
	PUSH	CX
	
		CALL	RESEED
		
		MOV		CX,100
		call_loop:
			PUSH	LOWER
			PUSH	UPPER
			CALL	RANDOM
			
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
	; cleanup
	CALL NEWLINE
	MOV		CX,25
	LEA		DI,THEEND
	CALL	PAUSE
	
	.EXIT
	END     randmain
;===================================================================
