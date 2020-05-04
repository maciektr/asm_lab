; Compiled and linked using MASM under DOSBOX emulator (Windows host)
; Example run: 
; maginifier.exe [zoom (digit)] [text]

; Constants
TEXT_SIZE_C 	equ 511
SCREEN_WIDTH 	equ 320
SCREEN_HEIGHT	equ 200

data1 segment
    zoom 	db 1 dup('$')
    text	db	TEXT_SIZE_C+3 dup('$')
        db ?
data1 ends

txtconst1 segment
; _tc from text constant
    badarg_tc db 10,13,"Program zostal uruchomiony z niepoprawnymi argumentami. ",10,13,"$"
txtconst1 ends

code1 segment
start1:
	; Stack initialization 
	mov	sp, offset stackptr
	mov	ax, seg stackptr
	mov	ss, ax
 
	; Set graphical mode
	; dimensions 320x200 pixels, 256 colors
	mov	al,13h  
	mov	ah,0
	int	10h

; --------------------
; Reads argument line
; zoom <- first argument (as number, one digit)
; text <- second argument
parse_args: 
	mov ax,seg zoom
	mov es, ax
	mov si, offset zoom ; es:[si]

; Read first argument 
	xor bp,bp
a1_start: 
	; Read char to al
	mov	al, byte ptr ds:[082h+ bp]
    
    ; If not enough args
    cmp al, " "
    je badargs
    cmp al,0
    je badargs
	
	; Convrt to number
	sub al, "0"
	; Ensure al stores digit
	cmp al,0
	jl badargs
	cmp al,9
	jg badargs

	; Save in zoom var
    mov	byte ptr es:[si],al
	inc	bp  ; bp++
a1_end:
	; Read next char
	mov	al, byte ptr ds:[082h+ bp]

	; Ensure it is a space (zoom can only be one digit long)
	cmp al,32
    jne badargs

	inc bp 
	; Start parsing second argument
	mov ax, seg text 
	mov es, ax
	mov si, offset text ; es:[si]

; Read second argument
	; Store current char count in di
	xor di,di
a2_start:
	; Read character
	mov	al, byte ptr ds:[082h+ bp]
    
	; Exit at the end of arguments line
    cmp al, " "
    je a2_end
    cmp al,0
    je a2_end
    cmp al,10
    je a2_end
    cmp al,13
    je a2_end
    cmp al,3
    je a2_end
	; Ensure no bufferoverflow in text var
    cmp di,TEXT_SIZE_C
    jge a2_end
	
	; Copy char read to var
    mov	byte ptr es:[si],al
	inc	bp 
	inc	si 
	inc di

	loop	a2_start
a2_end:
	; Terminate read string
    mov	byte ptr es:[si],"$"
; --------------------
	


; --------------------
	; Set starting point for drawing
	mov	word ptr cs:[x],10
	mov	word ptr cs:[y],100
	; Set color
	mov	byte ptr cs:[kol],13
 
	; Set cx pixels on 
	mov	cx,200
p1:	push	cx
	call	zapal_punkt
	inc	word ptr cs:[x]
	pop	cx
	loop	p1

; --------------------
exit:
	; Wait for any key
	xor	ax,ax
	int	16h  

	; Return to text mode
	mov	al,3h 
	mov	ah,0
	int	10h

exit_now:	
	; Exit
	mov	ah,4ch  
	int	021h
; --------------------
x	dw	0
y	dw	0
kol	db	0
 
zapal_punkt:
	; Graphic memory segment address
	mov	ax,0a000h  
	mov	es,ax
	mov	ax,word ptr cs:[y]
	; Number of points in graphic line
	mov	bx,SCREEN_WIDTH  
	mul	bx	; dx:ax = ax * bx
	add	ax,word ptr cs:[x]   ;ax = 320*y +x
	mov	bx,ax
	mov	al,byte ptr cs:[kol]
	mov	byte ptr es:[bx],al
	ret
; --------------------
 badargs:
 	; Return to text mode
	mov	al,3h 
	mov	ah,0
	int	10h

	; Print error msg
    mov dx,offset badarg_tc
    mov ax, seg badarg_tc
    mov ds,ax
    mov ah,9
    int 21h

	; Close program 
    jmp exit_now
; --------------------
code1 ends
 
stack1 segment stack
	dw 200 dup(?)
stackptr	dw ?
stack1 ends
 
end start1