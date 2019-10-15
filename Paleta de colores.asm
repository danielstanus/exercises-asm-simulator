
; Programa: Ejercicio2
; Proposito: Dibujar paleta de colores
; Autor: Daniel Calin Stanus
; Fecha: 25-09-2019

	JMP boot ; saltar a boot, es una etiqueta(direcciones de memoria)

boot:
	MOV SP, 255		; Set SP, MOV=mover, MOV A<--B
	MOV D, 0x300	; Point register D to output 19, (19d), 0O43, 0o74, 0x37, 10101b
    CALL print		
	HLT				; Halt execution
    
print:				; Print string
    ADD A, 0x00

.bucle:	
    MOVB   [D], AL	; Write to output
    INC     A
    INC     D
    CMP     A, 0xFF
    JBE     .bucle
    
	RET