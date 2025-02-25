; Example 1.1:
; Writes "Hello World!" to the text display

	JMP boot

hello:	DB "Hello World!"	; Output string
		DB 0				; String terminator

boot:
	MOV SP, 255		; Set SP
	MOV C, hello	; Point register C to string
	MOV D, 0x2E0	; Point register D to output
	CALL print
	HLT				; Halt execution

print:				; Print string
	PUSH A
	PUSH B
	MOV B, 0
.loop:
	MOVB AL, [C]	; Get character
    CMPB AL, 0x6F	; Ch
    JE .loop1
	MOVB [D], AL	; Write to output
	INC C
	INC D
	CMPB BL, [C]	; Check if string terminator
	JNZ .loop		; Jump back to loop if not

	POP B
	POP A
	RET

.loop1:
	MOVB [D], 0x4F
    INC C
    INC D
    CALL print
    