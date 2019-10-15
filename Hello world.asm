; Example 1.1:
; Writes "Hello World!" to the text display

	JMP boot ; saltar a boot, es una etiqueta(direcciones de memoria)

hello:	DB "Hello World!"	; Output string, DB=define byte
		DB 0				; String terminator

boot:
	MOV SP, 255		; Set SP, MOV=mover, MOV A<--B
	MOV C, hello	; Point register C to string
	MOV D, 0x2E0	; Point register D to output 19, (19d), 0O43, 0o74, 0x37, 10101b
	CALL print		
	HLT				; Halt execution

print:				; Print string
	PUSH A			; PUSH - mete el A en la pila
	PUSH B
	MOV B, 0
.loop:
	MOVB AL, [C]	; Get character, MOVB-mover 1 byte
	MOVB [D], AL	; Write to output
	INC C			; incrementa c
	INC D
	CMPB BL, [C]	; Check if string terminator
	JNZ .loop		; Jump back to loop if not, jump not 0

	POP B			; proteger los valores, los guarda
	POP A
	RET
