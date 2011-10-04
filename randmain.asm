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

	MOV		CX,2
	
	MOV		BL,1
	MOV 	AX,5555h

	switch_loop:
		PUSH	CX
		MOV		CX,2
		line_loop:
			PUSH	CX
			MOV 	CX,10	
			

			
			call_loop:

				;save loop counter
				PUSH	CX
				
				; lower
				MOV 	DX,LOWER
				push 	DX
				; upper
				MOV 	DX,UPPER
				push 	DX


				CALL 	RANDOM

				; Display result from AX
				MOV 	BH,0
				CALL 	PUTDEC$
				
				;restore counter
				POP CX
				

				
				;Check for line end
				CMP CX,1
				JE	skip_delim
					;Deliminator
					PUSH 	CX
					LEA 	DI,DELIM
					MOV		CX,2
					CALL 	PUTSTRNG
					POP		CX
				; No commas at end of lines
				skip_delim:

				LOOP	call_loop
			CALL	NEWLINE
			POP		CX
			LOOP	line_loop
		; next call
		CALL	NEWLINE
		MOV		AX,5555h
		MOV		BL,1
		POP 	CX
		LOOP 	switch_loop
	; cleanup
	MOV		CX,25
	LEA		DI,THEEND
	CALL	PAUSE
	
	.EXIT
	END     randmain
;===================================================================
