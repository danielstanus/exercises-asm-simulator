; Example 2:
; Programs a periodic interrupt that increments
; a counter [0 to 99] and prints its value into
; the text display
 
	JMP boot 
	JMP isr

counter:		; the counter
	DW 0

boot:
	MOV SP, 255		; Set SP - una zona que no se programa
    				; que no sea memoria del display
	MOV A, 2		; Set bit 1 of IRQMASK - 2 TIMER
	OUT 0			; Unmask timer IRQ - IRQMASK
	MOV A, 0x20		; Set timer preload
	OUT 3			; activa el temporizador - TMRPRELOAD
	STI				; Habilita las interruciones
	HLT				; pone que se pare el procesador, hasta que
    				; se genera una interrupcion.

isr:
	PUSH A				; guarda estas variables
	PUSH B
	PUSH C
	MOV A, [counter]	; Increment the
	INC A				; counter
	CMP A, 100			; [0 to 99]
	JNZ .print
	MOV A, 0

.print:
	MOV [counter], A	; Print the
	MOV B, A			; decimal value
	DIV 10				; of the counter
	MOV C, A
	MUL 10				; multiplica el registo A por 10 y lo guarda ahi
	SUB B, A
	ADDB CL, 0x30
	ADDB BL, 0x30
	MOVB [0x2E0], CL
	MOVB [0x2E1], BL
	MOV A, 2
	OUT 2				; Write to signal IRQEOI
	POP C
	POP B
	POP A
	IRET
