; Compiled and linked using MASM under DOSBOX emulator (Windows host)
; Example run: 
; maginifier.exe [zoom (digit)] [text]

; Constants
; TEXT_SIZE_C 	equ 511
SCREEN_WIDTH 	equ 320
SCREEN_HEIGHT	equ 200
CHAR_LEN		equ 8
TEXT_COLOR 		equ 15 
START_X			equ 0
START_Y			equ 0
PADDING 		equ 1

data1 segment
    zoom 	db 1 dup('$')
    ; text	db	TEXT_SIZE_C+3 dup('$')
        db ?
data1 ends

txtconst1 segment
; _tc from text constant
    badarg_tc db 10,13,"Program zostal uruchomiony z niepoprawnymi argumentami. ",10,13,"$"
txtconst1 ends

; Ascii characters 
; Char 'a' can be accessed as: 
; ascii + 8 * 'a'
rend_char segment
ascii   db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0000 (nul)
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0001
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0002
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0003
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0004
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0005
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0006
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0007
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0008
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0009
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+000A
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+000B
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+000C
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+000D
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+000E
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+000F
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0010
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0011
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0012
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0013
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0014
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0015
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0016
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0017
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0018
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0019
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+001A
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+001B
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+001C
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+001D
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+001E
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+001F
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0020 (space)
		db  018h, 03Ch, 03Ch, 018h, 018h, 000h, 018h, 000h ; U+0021 (!)
		db  036h, 036h, 000h, 000h, 000h, 000h, 000h, 000h ; U+0022 (")
		db  036h, 036h, 07Fh, 036h, 07Fh, 036h, 036h, 000h ; U+0023 (#)
		db  00Ch, 03Eh, 003h, 01Eh, 030h, 01Fh, 00Ch, 000h ; U+0024 ($)
		db  000h, 063h, 033h, 018h, 00Ch, 066h, 063h, 000h ; U+0025 (%)
		db  01Ch, 036h, 01Ch, 06Eh, 03Bh, 033h, 06Eh, 000h ; U+0026 (&)
		db  006h, 006h, 003h, 000h, 000h, 000h, 000h, 000h ; U+0027 (')
		db  018h, 00Ch, 006h, 006h, 006h, 00Ch, 018h, 000h ; U+0028 (()
		db  006h, 00Ch, 018h, 018h, 018h, 00Ch, 006h, 000h ; U+0029 ())
		db  000h, 066h, 03Ch, 0FFh, 03Ch, 066h, 000h, 000h ; U+002A (*)
		db  000h, 00Ch, 00Ch, 03Fh, 00Ch, 00Ch, 000h, 000h ; U+002B (+)
		db  000h, 000h, 000h, 000h, 000h, 00Ch, 00Ch, 006h ; U+002C (,)
		db  000h, 000h, 000h, 03Fh, 000h, 000h, 000h, 000h ; U+002D (-)
		db  000h, 000h, 000h, 000h, 000h, 00Ch, 00Ch, 000h ; U+002E (.)
		db  060h, 030h, 018h, 00Ch, 006h, 003h, 001h, 000h ; U+002F (/)
		db  03Eh, 063h, 073h, 07Bh, 06Fh, 067h, 03Eh, 000h ; U+0030 (0)
		db  00Ch, 00Eh, 00Ch, 00Ch, 00Ch, 00Ch, 03Fh, 000h ; U+0031 (1)
		db  01Eh, 033h, 030h, 01Ch, 006h, 033h, 03Fh, 000h ; U+0032 (2)
		db  01Eh, 033h, 030h, 01Ch, 030h, 033h, 01Eh, 000h ; U+0033 (3)
		db  038h, 03Ch, 036h, 033h, 07Fh, 030h, 078h, 000h ; U+0034 (4)
		db  03Fh, 003h, 01Fh, 030h, 030h, 033h, 01Eh, 000h ; U+0035 (5)
		db  01Ch, 006h, 003h, 01Fh, 033h, 033h, 01Eh, 000h ; U+0036 (6)
		db  03Fh, 033h, 030h, 018h, 00Ch, 00Ch, 00Ch, 000h ; U+0037 (7)
		db  01Eh, 033h, 033h, 01Eh, 033h, 033h, 01Eh, 000h ; U+0038 (8)
		db  01Eh, 033h, 033h, 03Eh, 030h, 018h, 00Eh, 000h ; U+0039 (9)
		db  000h, 00Ch, 00Ch, 000h, 000h, 00Ch, 00Ch, 000h ; U+003A (:)
		db  000h, 00Ch, 00Ch, 000h, 000h, 00Ch, 00Ch, 006h ; U+003B (;)
		db  018h, 00Ch, 006h, 003h, 006h, 00Ch, 018h, 000h ; U+003C (<)
		db  000h, 000h, 03Fh, 000h, 000h, 03Fh, 000h, 000h ; U+003D (=)
		db  006h, 00Ch, 018h, 030h, 018h, 00Ch, 006h, 000h ; U+003E (>)
		db  01Eh, 033h, 030h, 018h, 00Ch, 000h, 00Ch, 000h ; U+003F (?)
		db  03Eh, 063h, 07Bh, 07Bh, 07Bh, 003h, 01Eh, 000h ; U+0040 (@)
		db  00Ch, 01Eh, 033h, 033h, 03Fh, 033h, 033h, 000h ; U+0041 (A)
		db  03Fh, 066h, 066h, 03Eh, 066h, 066h, 03Fh, 000h ; U+0042 (B)
		db  03Ch, 066h, 003h, 003h, 003h, 066h, 03Ch, 000h ; U+0043 (C)
		db  01Fh, 036h, 066h, 066h, 066h, 036h, 01Fh, 000h ; U+0044 (D)
		db  07Fh, 046h, 016h, 01Eh, 016h, 046h, 07Fh, 000h ; U+0045 (E)
		db  07Fh, 046h, 016h, 01Eh, 016h, 006h, 00Fh, 000h ; U+0046 (F)
		db  03Ch, 066h, 003h, 003h, 073h, 066h, 07Ch, 000h ; U+0047 (G)
		db  033h, 033h, 033h, 03Fh, 033h, 033h, 033h, 000h ; U+0048 (H)
		db  01Eh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 01Eh, 000h ; U+0049 (I)
		db  078h, 030h, 030h, 030h, 033h, 033h, 01Eh, 000h ; U+004A (J)
		db  067h, 066h, 036h, 01Eh, 036h, 066h, 067h, 000h ; U+004B (K)
		db  00Fh, 006h, 006h, 006h, 046h, 066h, 07Fh, 000h ; U+004C (L)
		db  063h, 077h, 07Fh, 07Fh, 06Bh, 063h, 063h, 000h ; U+004D (M)
		db  063h, 067h, 06Fh, 07Bh, 073h, 063h, 063h, 000h ; U+004E (N)
		db  01Ch, 036h, 063h, 063h, 063h, 036h, 01Ch, 000h ; U+004F (O)
		db  03Fh, 066h, 066h, 03Eh, 006h, 006h, 00Fh, 000h ; U+0050 (P)
		db  01Eh, 033h, 033h, 033h, 03Bh, 01Eh, 038h, 000h ; U+0051 (Q)
		db  03Fh, 066h, 066h, 03Eh, 036h, 066h, 067h, 000h ; U+0052 (R)
		db  01Eh, 033h, 007h, 00Eh, 038h, 033h, 01Eh, 000h ; U+0053 (S)
		db  03Fh, 02Dh, 00Ch, 00Ch, 00Ch, 00Ch, 01Eh, 000h ; U+0054 (T)
		db  033h, 033h, 033h, 033h, 033h, 033h, 03Fh, 000h ; U+0055 (U)
		db  033h, 033h, 033h, 033h, 033h, 01Eh, 00Ch, 000h ; U+0056 (V)
		db  063h, 063h, 063h, 06Bh, 07Fh, 077h, 063h, 000h ; U+0057 (W)
		db  063h, 063h, 036h, 01Ch, 01Ch, 036h, 063h, 000h ; U+0058 (X)
		db  033h, 033h, 033h, 01Eh, 00Ch, 00Ch, 01Eh, 000h ; U+0059 (Y)
		db  07Fh, 063h, 031h, 018h, 04Ch, 066h, 07Fh, 000h ; U+005A (Z)
		db  01Eh, 006h, 006h, 006h, 006h, 006h, 01Eh, 000h ; U+005B ([)
		db  003h, 006h, 00Ch, 018h, 030h, 060h, 040h, 000h ; U+005C (\)
		db  01Eh, 018h, 018h, 018h, 018h, 018h, 01Eh, 000h ; U+005D (])
		db  008h, 01Ch, 036h, 063h, 000h, 000h, 000h, 000h ; U+005E (^)
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 0FFh ; U+005F (_)
		db  00Ch, 00Ch, 018h, 000h, 000h, 000h, 000h, 000h ; U+0060 (`)
		db  000h, 000h, 01Eh, 030h, 03Eh, 033h, 06Eh, 000h ; U+0061 (a)
		db  007h, 006h, 006h, 03Eh, 066h, 066h, 03Bh, 000h ; U+0062 (b)
		db  000h, 000h, 01Eh, 033h, 003h, 033h, 01Eh, 000h ; U+0063 (c)
		db  038h, 030h, 030h, 03eh, 033h, 033h, 06Eh, 000h ; U+0064 (d)
		db  000h, 000h, 01Eh, 033h, 03fh, 003h, 01Eh, 000h ; U+0065 (e)
		db  01Ch, 036h, 006h, 00fh, 006h, 006h, 00Fh, 000h ; U+0066 (f)
		db  000h, 000h, 06Eh, 033h, 033h, 03Eh, 030h, 01Fh ; U+0067 (g)
		db  007h, 006h, 036h, 06Eh, 066h, 066h, 067h, 000h ; U+0068 (h)
		db  00Ch, 000h, 00Eh, 00Ch, 00Ch, 00Ch, 01Eh, 000h ; U+0069 (i)
		db  030h, 000h, 030h, 030h, 030h, 033h, 033h, 01Eh ; U+006A (j)
		db  007h, 006h, 066h, 036h, 01Eh, 036h, 067h, 000h ; U+006B (k)
		db  00Eh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 01Eh, 000h ; U+006C (l)
		db  000h, 000h, 033h, 07Fh, 07Fh, 06Bh, 063h, 000h ; U+006D (m)
		db  000h, 000h, 01Fh, 033h, 033h, 033h, 033h, 000h ; U+006E (n)
		db  000h, 000h, 01Eh, 033h, 033h, 033h, 01Eh, 000h ; U+006F (o)
		db  000h, 000h, 03Bh, 066h, 066h, 03Eh, 006h, 00Fh ; U+0070 (p)
		db  000h, 000h, 06Eh, 033h, 033h, 03Eh, 030h, 078h ; U+0071 (q)
		db  000h, 000h, 03Bh, 06Eh, 066h, 006h, 00Fh, 000h ; U+0072 (r)
		db  000h, 000h, 03Eh, 003h, 01Eh, 030h, 01Fh, 000h ; U+0073 (s)
		db  008h, 00Ch, 03Eh, 00Ch, 00Ch, 02Ch, 018h, 000h ; U+0074 (t)
		db  000h, 000h, 033h, 033h, 033h, 033h, 06Eh, 000h ; U+0075 (u)
		db  000h, 000h, 033h, 033h, 033h, 01Eh, 00Ch, 000h ; U+0076 (v)
		db  000h, 000h, 063h, 06Bh, 07Fh, 07Fh, 036h, 000h ; U+0077 (w)
		db  000h, 000h, 063h, 036h, 01Ch, 036h, 063h, 000h ; U+0078 (x)
		db  000h, 000h, 033h, 033h, 033h, 03Eh, 030h, 01Fh ; U+0079 (y)
		db  000h, 000h, 03Fh, 019h, 00Ch, 026h, 03Fh, 000h ; U+007A (z)
		db  038h, 00Ch, 00Ch, 007h, 00Ch, 00Ch, 038h, 000h ; U+007B (db )
		db  018h, 018h, 018h, 000h, 018h, 018h, 018h, 000h ; U+007C (|)
		db  007h, 00Ch, 00Ch, 038h, 00Ch, 00Ch, 007h, 000h ; U+007D (})
		db  06Eh, 03Bh, 000h, 000h, 000h, 000h, 000h, 000h ; U+007E (~)
		db  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h ; U+007F
rend_char ends

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
; Set starting point for drawing
	mov	word ptr cs:[x],START_X
	mov	word ptr cs:[y],START_Y
; Set color
	mov	byte ptr cs:[color],TEXT_COLOR

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
	
	; Convert to number
	sub al, "0"
	; Ensure al stores digit
	cmp al,0
	jl badargs
	cmp al,9
	jg badargs

	; Save in zoom var
	inc al
    mov	byte ptr es:[si],al
	inc	bp  ; bp++
a1_end:
	; Read next char
	mov	al, byte ptr ds:[082h+ bp]

	; Ensure it is a space (zoom can only be one digit long)
	cmp al,32
    jne badargs

	inc bp 
; Read second argument
; Print it 
a2_start:
	; Read character
	mov	al, byte ptr ds:[082h+ bp]
    
	; Exit at the end of arguments line
    cmp al,0
    je a2_end
    cmp al,10
    je a2_end
    cmp al,13
    je a2_end
    cmp al,3
    je a2_end

	; Print read char 
	mov bl, al 
	call print_char

	inc	bp 
	inc	si 
	loop	a2_start
a2_end:

; --------------------
	; mov bx, "c"
	; call print_char
; ####################
	; Set cx pixels on 
; 	mov	cx,200
; p1:	push	cx
; 	call	set_pixel_on
; 	inc	word ptr cs:[x]
; 	pop	cx
; 	loop	p1

; --------------------
; 	Set pointer to char 
	; mov dx,offset ascii
	; mov ax, seg rend_char

    ; mov ds,ax
    ; mov ah,9
    ; int 21h
	; jmp exit
; ####################
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
; Sets pixel on. Contrary to set_pixel_on uses real pixel, not zoomed equivalent.
rel_x 	dw 0
rel_y 	dw 0
set_realpixel:
	push ax 
	push bx 
	push cx 
	push dx 
	push ds

	; Graphic memory segment address
	mov	ax,0a000h  
	mov	ds,ax
	mov	ax,word ptr cs:[rel_y]
	; Number of points in graphic line
	mov	bx,SCREEN_WIDTH  
	mul	bx	; dx:ax = ax * bx
	add	ax,word ptr cs:[rel_x]   ;ax = 320*y +x
	mov	bx,ax
	mov	al,byte ptr cs:[color]
	; es:[320 * y + x] = color
	mov	byte ptr ds:[bx],al 

	pop ds
	pop dx 
	pop cx 
	pop bx
	pop ax 
	ret
; --------------------
; Local variables in CS for graphics 
color	db	0

; Used in set_pixel_on procedure
x		dw	0
y		dw	0
; Sets "zoomed" pixel on, meaning a square of pixels, having zoom of pixels in both sides.
set_pixel_on:
	push ax 
	push bx 
	push cx 
	push dx 
	push ds

	mov ax, seg zoom 
	mov ds, ax 
	mov si, offset zoom 
	mov al, byte ptr ds:[si]
	xor ah, ah
	; al = zoom; ah = 0 

	mov bx, word ptr cs:[x]
	; bx = x 
	
	mul bx 
	mov word ptr cs:[rel_x], ax 
	; rel_x = bx * al = x * zoom 

	; mov ax, seg zoom 
	; mov ds, ax 
	; mov si, offset zoom 
	mov al, byte ptr ds:[si]
	xor ah, ah
	; al = zoom; ah = 0 

	mov bx, word ptr cs:[y]
	; bx = y

	mul bx 
	mov word ptr cs:[rel_y], ax
	; rel_y = bx * al  = y * zoom 

	mov cl, byte ptr ds:[si]
	xor ch,ch 
	; cx = zoom 
sq_l1_beg:
	push cx 
	
	mov cl, byte ptr ds:[si]
	xor ch,ch 
	; cx = zoom 
	sq_l2_beg:
		push cx 

		call set_realpixel
		inc word ptr cs:[rel_x]

		pop cx
		loop sq_l2_beg
	inc word ptr cs:[rel_y]
	mov al, byte ptr ds:[si]
	xor ah,ah
	; dec ax 
	sub word ptr cs:[rel_x], ax


	pop cx 
	loop sq_l1_beg
	
	pop ds
	pop dx 
	pop cx 
	pop bx
	pop ax 
	ret
; --------------------
; Prints char from bl
; (destroys bx)
print_char:
	push ax 
	push cx 
	push dx 

	xor bh,bh

	mov ax, seg ascii
	mov es, ax
	mov ax, CHAR_LEN
	mul bx
	add ax, offset ascii
	mov bx, ax
	; bx = CHAR_LEN * "d" + offset ascii

; Print one row of rendered char
mov cx, 7
print_bitmap_row:
	push cx
	mov cx, 7 
	mov dx, 1h;80h
check_bits:	
	push cx
	mov ax, dx
	and ax,es:[bx]

	cmp ax, 0
	je no_set
	call  set_pixel_on
no_set: 

	inc word ptr cs:[x]
	shl dx,1
	
	pop cx
	loop check_bits
check_bits_end:
	inc word ptr cs:[y]
	sub word ptr cs:[x],7
	inc bx
	pop cx
	loop print_bitmap_row
	add word ptr cs:[x],7 
	add word ptr cs:[x], PADDING
	mov word ptr cs:[y],START_Y

	pop dx 
	pop cx 
	pop ax 
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