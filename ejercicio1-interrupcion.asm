
; Programa: Ejercicio1 - Tema2
; Proposito: El código principal debe escribir un valor fijo de 8 bits
		   ; en todas las posiciones del display visual de forma cíclica
; Autor: Daniel Calin Stanus
; Fecha: 15-10-2019

	JMP boot ; saltar a boot, es una etiqueta(direcciones de memoria)
	JMP isr
    
counter:		; the counter
	DW 0
    
boot:
	MOV SP, 255		; Set SP, MOV=mover, MOV A<--B
    MOV A, 2		; Set bit 1 of IRQMASK
	OUT 0			; Unmask timer IRQ
	MOV A, 0x20		; Set timer preload
    ADD C, 0x30
	OUT 3
	STI	
	HLT				; Halt execution
    
isr:
	PUSH A
	PUSH B
    MOV D, 0x2E0
    ADD B, 0d
	MOV A, 0x30	
	INC A		
	CMP A, 0x32			
	JE .bucle
	MOV A, 0x30
    


.bucle:	
    MOVB   [D], CL	; Write to output  
    INC     D
 	INC     B
    CMP     B, 32d
    JNE     .bucle
    OUT 2
    INC C
	POP B
	POP A
    IRET

.bucle1:	
    MOV D, 0x2E0
    MOV B, 0d
    CALL .bucle

	RET