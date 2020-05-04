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



; --------------------
	; Set starting point
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
 
exit:
	; Wait for any key
	xor	ax,ax
	int	16h  
	
	; Return to text mode
	mov	al,3h 
	mov	ah,0
	int	10h
	
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
 
code1 ends
 
stack1 segment stack
	dw 200 dup(?)
stackptr	dw ?
stack1 ends
 
end start1