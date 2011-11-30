;	SLEEP
;	Erick Veil
;	Delays for a number of clock ticks passed on the stack
;	11-30-11

EXTRN	PUTDEC$:FAR
.MODEL	SMALL,BASIC
counter		equ		017c0h	; approx 1 jiffy on the clock per delay_A loop
.CODE	
	; SLEEP
	; push the approximate number of clock ticks to wait via the stack
	; no return value
	SLEEP	PROC	FAR PUBLIC uses ax bx cx dx , TICKS:word
		PUSHF

		; read clock for starting time, store in ax
		mov		ah,00h
		int		1ah
		mov		ax,dx		
		sleeploop:		
			; delay loops prevent over-polling the clock
			mov		cx,counter
			delay_A:
				push	cx
				mov		cx,counter
				delay_B:
				loop	delay_B
				pop		cx				
			loop	delay_A			
			; read clock for comparison, store in bx
			push	ax
			mov		ah,00h
			int		1ah
			mov		bx,dx
			pop		ax			
			; check for timewarp
			cmp		bx,ax
			jle		wakeup ; if bx < ax then the odometer flipped. escape.				
			; get elapsed time
			sub		bx,ax				
			; compare elapsed ticks to requested ticks
			checkalarm:
			cmp		bx,TICKS
			jge		wakeup
	jmp	sleeploop		
	wakeup:	
		POPF
		RET
	SLEEP     ENDP
	
	; prints the lower order of the clock value for debugging fun
	PRINTCLOCK	PROC	NEAR PUBLIC uses ax bx dx
	PUSHF
	
		mov		ah,00h
		int		1ah
		mov		ax,dx
		mov		bx,0
		call	PUTDEC$
		
		POPF
		RET
	PRINTCLOCK	ENDP
	
END

