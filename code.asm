; Compiled and linked using MASM under DOSBOX emulator (Windows host)

; Constants
BUF_SIZE_C equ 255

data1 segment
    file_in 	db 255 dup('$')
    file_out	db 255 dup('$')
    passphrase  db BUF_SIZE_C+1 dup('$')

    fin_ptr	    dw	?
    fin_buffer	db	BUF_SIZE_C+1 dup('$')

    fout_ptr    dw  ?

        db ?
    ; address1	dw 1345
data1 ends

txtconst1 segment
; _tc from text constant
    readfin_tc  db 10,13,"Wczytano plik wejsciowy: ",10,13,"$" 
    readfout_tc db 10,13,"Wczytano plik wyjsciowy: ",10,13,"$" 
    readpass_tc db 10,13,"Wczytano haslo: ",10,13,"$"
    beggining_tc db 10,13,"Rozpoczynam kodowanie pliku: ",10,13,"$"
    badarg_tc db 10,13,"Program zostal uruchomiony z niepoprawnymi argumentami. ",10,13,"$"
txtconst1 ends


code1 segment
start1:
	;ds -> program segment
	;offset: 080h = char count in args buffor 
	;        081h = space
	;	     082h = args begining 
 
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
    
    cmp al, " "
    je a1_end
    ; If not enough args
    cmp al,0
    je badargs
	
    mov	byte ptr es:[si],al
	inc	bp  ; bp++
	inc	si  ; si++

	loop	a1_start
a1_end:
    mov	byte ptr es:[si],0
	mov	ax,seg file_out
	mov	es,ax
	mov	si,offset file_out ;   es:[si]
    inc bp
a2_start:	
	mov	al, byte ptr ds:[082h + bp]

    cmp al, " "
    je a2_end
    ; If not enough args
    cmp al,0
    je badargs

	mov	byte ptr es:[si],al
	inc	bp  ; bp++
	inc	si  ; si++

	loop	a2_start
 a2_end:
    mov	byte ptr es:[si],0
	mov	ax,seg passphrase
	mov	es,ax
	mov	si,offset passphrase ;   es:[si]
    inc bp
    ; Copy current value of bp
    mov bx, bp
    ; Store number of currently read chars in cx
    xor cx,cx
a3_start:	
	mov	al, byte ptr ds:[082h + bp]
	inc	bp  
    inc cx

    cmp al,0
    je a3_end
    cmp al,10
    je a3_end
    cmp al,13
    je a3_end
    cmp al,3
    je a3_end
    cmp cx,BUF_SIZE_C
    jge a3_end

    ; Copy read char to var
    mov	byte ptr es:[si],al
	inc	si  

	jmp	a3_start
 a3_end:
    ; If read less than BUF_SIZE_C chars, repeat reading
    mov bp,bx
    cmp cx,BUF_SIZE_C
    jl a3_start
    ; Terminate string
    mov	byte ptr es:[si],"$"
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

    mov ax,seg beggining_tc
    mov ds,ax
    mov dx,offset beggining_tc
    mov ah,9
    int 21h
; --------------------
	;Open file - fin
    mov dx,offset file_in
    mov	ax,seg file_in
	mov	ds,ax   ; ds:dx -> file name
	mov	al,0000h ; open in readonly mode
	mov	ah,3Dh
	int	21h  ; pointer to file in AX 
	mov	word ptr ds:[fin_ptr],ax
	; Handle file open errors
    jc badargs

    ;Open file - fout
    mov dx,offset file_out
    mov	ax,seg file_out
	mov	ds,ax   ; ds:dx -> file name
	mov	al,0001h ; open in writeonly mode
	mov	ah,3Dh
	int	21h  ; pointer to file in AX 
	mov	word ptr ds:[fout_ptr],ax
	; Handle file open errors
    jc badargs
    
	; File read 
	mov	dx,offset fin_buffer
	mov	ax,seg fin_buffer
	mov	ds,ax   ;ds:dx -> read buffer 
    mov	bx,word ptr ds:[fin_ptr]
	mov	cx,offset BUF_SIZE_C ; number of characters to read
	mov	ah,03Fh
	int	21h
	; Handle file read errors
    jc badargs
    ; AX - number of bytes read
    ; --------------------
    ; ####################
    ; Code text in buffer by xor with passphrase
    mov di,offset fin_buffer
    mov si,offset passphrase
code_lbeg:
    mov al, byte ptr ds:[si]
    
    cmp al, "$"
    je code_lend

    xor byte ptr ds:[di], al

    inc si
    inc di
    jmp code_lbeg
code_lend:

    ; --------------------
    ; File write
	mov	cx,ax ; number of characters to write
    mov	dx,offset fin_buffer
	mov	ax,seg fin_buffer
	mov	ds,ax   ;ds:dx -> write buffer 
    mov	bx,word ptr ds:[fout_ptr]
	mov	ah,40h
	int	21h
	; Handle file open errors
    ; Jump if Carry flag set
    jc badargs
 
	; Close file - fin  
	mov	bx,word ptr ds:[fin_ptr]
	mov	ah,03eh
	int	21h
	; Handle file close errors
    ; Jump if Carry flag set
    jc badargs

    ; Close file - fout
	mov	bx,word ptr ds:[fout_ptr]
	mov	ah,03eh
	int	21h
	; Handle file close errors
    ; Jump if Carry flag set
    jc badargs

	mov	dx,offset fin_buffer
	mov	ax, seg fin_buffer
	mov	ds,ax
	mov	ah,9  ; wypisz tekst z DS:DX
	int	21h
; --------------------
;   Exit  
exit:
	mov	ah,4ch  
	int	021h
 
badargs:
    mov dx,offset badarg_tc
    mov ax, seg badarg_tc
    mov ds,ax
    mov ah,9
    int 21h
    jmp exit

code1 ends

stack1 segment stack
	dw 200 dup(?)
stackptr	dw ?
stack1 ends
 
end start1
