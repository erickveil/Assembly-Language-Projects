

.MODEL		SMALL
.STACK		64
.DATA

.CODE

	MAIN	PROC	FAR
		MOV		AX,@DATA
		MOV		DS,AX
	
	MAIN	ENDP
	END		MAIN