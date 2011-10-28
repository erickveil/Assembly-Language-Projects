COMMENT*

*

EXTRN	GETDEC$:FAR
EXTRN	PUTDEC$:FAR
EXTRN	PUTBIN:FAR
EXTRN	PUTOCT:FAR
EXTRN	PUTSTRNG:FAR
EXTRN	NEWLINE:FAR
EXTRN	PAUSE:FAR
EXTERN	CLEAR:FAR

PAGE		80,132
.MODEL		SMALL,BASIC
.STACK		64
.FARDATA	DSEG
	MON_STRT	db	0,8,17,23,29,33,37,42,49,59,67,76
	MONTH		db	'January$February$March$April$May$Jun$July$August$September$October$November$December$'
	DAY_STRT	db	0,7,14,22,32,41,48
	DAY			db	'Sunday$Monday$Tuesday$Wednesday$Thursday$Friday$Saturday$'

	
.CODE 
	ASSUME	DS:DSEG,ES:DSEG
MAIN	PROC	FAR
	MOV		AX,	SEG	DSEG
	MOV		DS,AX
	MOV		ES,AX
	
	
	mov	ax,8
	
	push	ax
	call	GET_MON_STRT	
	
	push	ax
	mov		dx,OFFSET MONTH
	call 	PRINT_MEMBER
	
	
.EXIT
MAIN	ENDP

COMMENT*
	PRINT_MEMBER
	Erick Veil
	10-28-11
	PRE: pass the start location via the stack, pass the 
	arrray name via dx as an offset
	POST: prints the element at subscript. 
	Elements separated by $
*
PRINT_MEMBER	PROC	NEAR PUBLIC SUBSCRIPT:WORD
	PUSHF

	add	dx,SUBSCRIPT
	mov	ah,09
	int	21H
	
	POPF
	RET
	
PRINT_MEMBER	ENDP

GET_DAY_STRT	PROC	NEAR PUBLIC SUBSCRIPT:WORD
	PUSHF
	
	mov	di,SUBSCRIPT
	mov	al,[DAY_STRT+di]
	cbw
	
	POPF
	RET
GET_DAY_STRT	ENDP


GET_MON_STRT	PROC	NEAR PUBLIC SUBSCRIPT:WORD
	PUSHF
	
	mov	di,SUBSCRIPT
	mov	al,[MON_STRT+di]
	cbw
	
	POPF
	RET
GET_MON_STRT	ENDP

END		MAIN