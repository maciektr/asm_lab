; Compiled and linked using MASM under DOSBOX emulator (Windows host)

data1 segment
    file_in 	db 255 dup('$')
    file_out	db 255 dup('$')
    passphrase  db 255 dup('$')

        db ?
    address1	dw 1345
data1 ends

txtconst1 segment
; _tc from text constant
    readfin_tc  db 10,13,"Wczytano plik wejsciowy: ",10,13,"$" 
    readfout_tc db 10,13,"Wczytano plik wyjsciowy: ",10,13,"$" 
    readpass_tc db 10,13,"Wczytano haslo: ",10,13,"$"
txtconst1 ends

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
 
    xor bp,bp ; bp=0
	; mov	cx,bx
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

    cmp al,0
    je a3_end
    cmp al,10
    je a3_end
    cmp al,13
    je a3_end
    cmp al,3
    je a3_end

	loop	a3_start
 a3_end:
    pop cx
    ; ret
; --------------------
; Shows read arguments 
show_read:
	mov	ax,seg readfin_tc
	mov	ds,ax
    mov dx,offset readfin_tc
    mov ah,9; print text from DS:DX
    int 21h

    mov	ax,seg file_in
	mov	ds,ax
	mov	dx,offset file_in
	mov	ah,9  
	int	21h

    mov	ax,seg readfout_tc
	mov	ds,ax
    mov dx,offset readfout_tc
    mov ah,9
    int 21h

    mov	ax,seg file_out
	mov	ds,ax
	mov	dx,offset file_out
	mov	ah,9  
	int	21h

    mov	ax,seg readpass_tc
	mov	ds,ax
    mov dx,offset readpass_tc
    mov ah,9
    int 21h

    mov	ax,seg passphrase
	mov	ds,ax
	mov	dx,offset passphrase
	mov	ah,9  
	int	21h
; --------------------


; --------------------
;   Exit  
	mov	ah,4ch  ; zakoncz program i wroc do systemu
	int	021h
 
code1 ends

stack1 segment stack
	dw 200 dup(?)
stackptr	dw ?
stack1 ends
 
end start1
