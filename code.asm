data1 segment
 
; txt1	    db 200 dup('$')
file_in 	db 255 dup('$')
file_out	db 255 dup('$')
passphrase  db 255 dup('$')

	db ?
address1	dw 1345
 
data1 ends

const1 segment

const1 ends

code1 segment
 
start1:
	;ds -> wskazuje na segment programu
	;offset: 080h = liczbe znakow buforu
	;        081h = spacja
	;	 082h = poczatek buforu
 
 
 
	;Stack initialization 
	mov	sp, offset stackptr
	mov	ax, seg stackptr
	mov	ss, ax

	mov	bx,0
	mov	bl,byte ptr ds:[080h]
	;mov	byte ptr ds:[080h +1 + bx],'$'
 
 
; --------------------
; Reads argument line
; file_in <- first argument 
; file_out <- second argument
; passphrase <- rest
 parse_args: 
    push cx 
    
	mov	ax,seg file_in
	mov	es,ax
	mov	si,offset file_in ;   es:[si]
 
	; mov	bp,0
    xor bp,bp
	mov	cx,bx

a1_start:	
	mov	al, byte ptr ds:[082h+ bp]
	mov	byte ptr es:[si],al
	inc	bp  ; bp = bp+1
	inc	si  ; si = si+1
    
    cmp al, " "
    je a1_end

	loop	a1_start

a1_end:
	mov	ax,seg file_out
	mov	es,ax
	mov	si,offset file_out ;   es:[si]
a2_start:	
	mov	al, byte ptr ds:[082h + bp]
	mov	byte ptr es:[si],al
	inc	bp  ; bp = bp+1
	inc	si  ; si = si+1
    
    cmp al, " "
    je a2_end

	loop	a2_start
 a2_end:
	mov	ax,seg passphrase
	mov	es,ax
	mov	si,offset passphrase ;   es:[si]
a3_start:	
	mov	al, byte ptr ds:[082h + bp]
	mov	byte ptr es:[si],al
	inc	bp  ; bp++
	inc	si  ; si++
    
	loop	a3_start
 a3_end:
    pop cx
    ; ret
; --------------------

 
 
 
	mov	ax,seg passphrase
	mov	ds,ax

	; mov	dx,offset file_out
	; mov	ah,9  ; print text from DS:DX
	; int	21h
    ; mov	dx,offset file_out
	; mov	ah,9  ; print text from DS:DX
	; int	21h
    mov	dx,offset passphrase
	mov	ah,9  ; print text from DS:DX
	int	21h
 
	mov	ah,4ch  ; zakoncz program i wroc do systemu
	int	021h
 
code1 ends
 
 
 
stack1 segment stack
	dw 200 dup(?)
stackptr	dw ?
stack1 ends
 
 
end start1
