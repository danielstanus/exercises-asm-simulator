; Solution  Exercise 3:
; A user mode task accesses the keypad and the
; text display using two non-blocking system 
; calls. The task polls the keypad until a key
; has been pressed and prints the value on the
; text display.
; The task obtain the keypad data: (CoordX, CoordX) and takes Color from variable

	JMP boot 
	JMP isr		; Interrupt vector
	JMP svc		; System call vector

keypressed:		; 1 = key pressed
	DB 0		; 0 = No key pressed

value:			; The number of the
	DB 0		; key pressed in ASCII

boot:
	MOV SP, 0xFF	; Set Supervisor SP
	MOV A, 1		; Set bit 0 of IRQMASK
	OUT 0			; Unmask keypad IRQ
	MOV A, 0x01FF	; Set the end of the
	OUT 8			; protection to 0x01FF
	MOV A, 0x0109	; Protection in seg. mode
	OUT 7			; from 0x0100, S=1, U=0
	PUSH 0x0010		; User Task SR: IRQMASK = 1
	PUSH 0x1FF		; User Task SP = 0x1FF
	PUSH task		; User Task IP = task
	SRET			; Jump to user mode
	HLT				; Parachute

isr:			
	PUSH A		; Read the key pressed
	IN 6		; and store the ASCII
	MOVB [value], AL
	MOVB AL, 1
	MOVB [keypressed], AL
	MOV A, 1
	OUT 2		; Write to signal IRQEOI
	POP A
	IRET

svc:				; Supervisor call
	CMP A, 0		; A = syscall number
	JNZ .svc1		; 0 -> readchar
	CLI
	MOV A, [keypressed]	; Write vars
	PUSH B				; with IRQs
	MOV B, 0			; disabled
	MOV [keypressed], B
	POP B
	STI
	JMP .return
.svc1:
	CMP A, 1		; 1 -> putchar
	JNZ .svc2
	MOVB [0x2E0], BL
    JMP .return
    
.svc2:
	;Print pixel [Color] in (CoordX , CoordY)   
    CMP A, 2		; 2 -> print_pixel
    JNZ .return
    PUSH B
    PUSH D
    ; Calculate the position in the graphic display 
    ; 0 x 0 3 CoordY CoordX <- [Color]
    SUBB BH, 0x30	 
    SUBB BL, 0x30
    MOVB AL, BL
    MULB 0x10
    MOVB BL, AL		
    MOVB DL, BL
    ADDB DL, BH		
    ADD D, 0x300    ; D is the adrress "0 x 0 3 CoordY CoordX"
    MOVB [D], CL
    POP D
    POP B
    
.return:
	SRET			; Return to user space
    
; ----------------------------
; PROCESO DE USUARIO 
; -----------------------------

	ORG 0x100	; Following data and instructions
				; will be assembled at 0x100            
CoordX:
	DB 0
CoordY:
	DB 0
Color:
	DB 0xC4 	; Red color

task:			; The user task
	MOV A, 0
	MOV B, 0
; Read CoordX and print CoordX in text display
loop1:    
    CALL readchar	; Polls the keypad
	CMPB AH, 1		; using readchar
	JNZ loop1
    MOVB [CoordX], AL		
	MOVB BL, AL		; If key was pressed use
	CALL putchar	; putchar to print it
; Read CoordY and print CoordY in text display
loop2:    
    CALL readchar	; Polls the keypad
	CMPB AH, 1		; using readchar
	JNZ loop2
    MOVB [CoordY], AL		
	MOVB BL, AL		; If key was pressed use
	CALL putchar	; putchar to print it
; Print pixel defined in variable "Color" in (CoordX, CoordY)	
    CALL print_pixel
	HLT

readchar:		; User space wrapper
	MOV A, 0	; for readchar syscall
	SVC			; Syscall #0
	RET			; A -> syscall number

putchar:		; User space wrapper
	PUSH A		; for putchar syscall
	MOV A, 1	; Syscall #1
	SVC			; A -> syscall number
	POP A		; BL -> char to print
	RET
    
print_pixel:
	PUSH A
    PUSH B
    PUSH C
	MOV A, 2	; Syscall #2
    MOVB BH, [CoordX]
    MOVB BL, [CoordY]
    MOVB CL, [Color]
    SVC
    POP C
    POP B
    POP A
    RET