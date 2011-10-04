    
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
           .MODEL  SMALL,BASIC
;===================================================================
FALSE      EQU     0                   ;CONSTANT FALSE
TRUE       EQU     1                   ;CONSTANT TRUE
;===================================================================
; D A T A   S E G M E N T   D E F I N I T I O N
           .FARDATA RAND_DATA
SEED       DW      ?                   ;SEED FOR RANDOM NUMBER GEN.
MULTIPLIER DW      25173               ;MULTIPLIER AND
ADDEND     DW      13849               ;ADDEND FOR MIXED
                                       ;LINEAR CONGRUENTIAL METHOD
FIRST_CALL DB      TRUE                ;FIRST CALL FLAG
;===================================================================
; C O D E   S E G M E N T   D E F I N I T I O N
;
           .CODE   RAND
           ASSUME  DS:RAND_DATA
;
RANDOM     PROC    FAR PUBLIC USES CX DX DS,
                   LOWER:WORD, UPPER:WORD
                                    ;FUNCTION RANDOM(LOWER,UPPER)
                                       ;SAVE REGISTERS (USES LIST)
           PUSHF                       ;SAVE FLAGS
           MOV     AX,SEG RAND_DATA    ;SET DS-REGISTER TO POINT
           MOV     DS,AX               ;TO LOCAL DATA SEGMENT
;
           .IF     FIRST_CALL == TRUE  ;IF   FIRST_CALL
                                       ;THEN
           MOV     FIRST_CALL,FALSE    ;     FIRST_CALL = FALSE
           MOV     AH,0                ;     SEED = LOWER HALF OF
           INT     1AH                 ;            TIME OF DAY CLOCK
           MOV     SEED,DX
           .ENDIF                      ;ENDIF
           MOV     AX,SEED             ;X = SEED * MULTIPLIER mod
           MUL     MULTIPLIER          ;                       65536
           ADD     AX,ADDEND           ;SEED = (X + ADDEND) mod 65536
           MOV     SEED,AX
           MOV     CX,UPPER            ;RANGE = UPPER - LOWER + 1
           SUB     CX,LOWER
           INC     CX
           MUL     CX                  ;RANDOM = (SEED*RANGE)/65536
           ADD     DX,LOWER            ;                    + LOWER
           MOV     AX,DX
           POPF                        ;RESTORE FLAGS
                                       ;RESTORE REGISTERS (ASSEMBLER
                                       ;   GENERATES INSTRUCTIONS TO
                                       ;   RESTORE REGISTERS - USES)
           RET                         ;RETURN (RANDOM)
RANDOM     ENDP                     ;END RANDOM
           END
