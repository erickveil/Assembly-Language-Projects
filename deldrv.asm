
EXTRN	SLEEP:FAR
EXTRN	PUTDEC$:FAR
EXTRN	PUTSTRNG:far
extrn	NEWLINE:far
extrn	PRINTCLOCK:far


PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG

	msg_strt	db	'start time: ';12
	msg_end		db	'end time: ';10
	
.CODE 
	ASSUME	DS:DSEG,ES:DSEG
MAIN	PROC	FAR
	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	MOV		ES,AX
	
	lea		di,msg_strt
	mov		cx,12
	call	PUTSTRNG
	call	PRINTCLOCK
	call	NEWLINE
	
	; sleep 10 clock ticks
	mov		ax,10
	push 	ax
	call	SLEEP
	
	lea		di,msg_end
	mov		cx,10
	call	PUTSTRNG
	call	PRINTCLOCK
	call	NEWLINE
	
.EXIT
MAIN	ENDP

END		MAIN


