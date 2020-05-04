; Compiled and linked using MASM under DOSBOX emulator (Windows host)

; Constants
BUF_SIZE_C equ 10

data1 segment
    file_in 	db 255 dup('$')
    file_out	db 255 dup('$')
    passphrase  db BUF_SIZE_C+1 dup('$')

    fin_ptr	    dw	?
    fin_buffer	db	BUF_SIZE_C+4 dup('$')

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
    fwrite_err_tc db 10,13,"Wystapil blad podczas zapisu do pliku.",10,13,"$"
    fread_err_tc db 10,13,"Wystapil blad podczas odczytu pliku.",10,13,"$"
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
    call show_read_fin

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
    call show_read_fout

    mov	byte ptr es:[si],0
	mov	ax,seg passphrase
	mov	es,ax
	mov	si,offset passphrase ;   es:[si]
    inc bp
    ; Copy current value of bp
    mov bx, bp
    ; Store number of currently read chars in cx
    xor cx,cx
    ; Check if already printed pass 
    xor ah,ah 
    ; The code below reads pass multiple times, to match buffer size
    mov	al, byte ptr ds:[082h + bp]
	; inc	bp  
    inc cx
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
    ; Although pass is being read multiple times to match buffer size 
    ; It should be printed only once in order not to confuse user
    cmp ah,1
    jge a3_no_print

    mov	byte ptr es:[si],"$"
    call show_read_pass
    inc ah
a3_no_print:
    ; If read less than BUF_SIZE_C chars, repeat reading
    mov bp,bx
    cmp cx,BUF_SIZE_C
    jl a3_start
    ; Terminate string
    mov	byte ptr es:[si],"$"
    pop cx
    ; ret
; --------------------
; Print that program starts encoding 
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
; --------------------
read_code_buffer:
	; File read 
	mov	dx,offset fin_buffer
	mov	ax,seg fin_buffer
	mov	ds,ax   ;ds:dx -> read buffer 
    mov	bx,word ptr ds:[fin_ptr]
	mov	cx,offset BUF_SIZE_C ; number of characters to read
	mov	ah,03Fh
	int	21h
	; Handle file read errors
    jc fread_err

    ; AX - number of bytes read
    ; If 0 end encoding phase
    cmp ax, 0
    je read_code_end

    ; Show read buffer content
    mov bp, ax
    mov di,offset fin_buffer 
    mov	byte ptr ds:[di + bp],10
    mov	byte ptr ds:[di + bp+1],13
    mov	byte ptr ds:[di + bp+2],"$"
    call show_buffer

    ; Store number of characters to write in CX
    mov cx, ax 

    ; Code text in buffer by xor with passphrase
    mov di,offset fin_buffer
    mov si,offset passphrase
code_lbeg:
    ; Store current char of passphrase in al
    mov al, byte ptr ds:[si]
    
    ; If end of passphrase, jump to end
    cmp al, "$"
    je code_lend

    ; The said encoding by xor with pass char
    xor byte ptr ds:[di], al

    inc si
    inc di
    jmp code_lbeg
code_lend:
    ; File write
	; mov	cx,ax ; already did in line 210, now ax is destroyed
    mov	dx,offset fin_buffer
	mov	ax,seg fin_buffer
	mov	ds,ax   ;ds:dx -> write buffer 
    mov	bx,word ptr ds:[fout_ptr]
	mov	ah,40h
	int	21h
	; Handle file open errors
    ; Jump if Carry flag set
    jc fwrite_err

    jmp read_code_buffer
read_code_end:
; --------------------
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
; --------------------
;   Exit  
exit:
	mov	ah,4ch  
	int	021h

;   Print content of fin_buffer
show_buffer:
    push ax
    push dx
    push ds 

	mov	dx,offset fin_buffer
	mov	ax, seg fin_buffer
	mov	ds,ax
	mov	ah,9  ; wypisz tekst z DS:DX
	int	21h

    pop ds
    pop dx 
    pop ax 
    ret
     
;   Print content of file_in with additional msg from readfin_tc
show_read_fin:
    push ax
    push dx
    push ds 

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

    pop ds
    pop dx 
    pop ax 
    ret

;   Print content of file_out with additional msg from readfout_tc
show_read_fout:
    push ax
    push dx
    push ds 

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

    pop ds
    pop dx 
    pop ax 
    ret

;   Print content of passphrase with additional msg from readpass_tc
show_read_pass:
    push ax
    push dx
    push ds 

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

    pop ds
    pop dx 
    pop ax 
    ret 

badargs:
    mov dx,offset badarg_tc
    mov ax, seg badarg_tc
    mov ds,ax
    mov ah,9
    int 21h
    jmp exit

fwrite_err:
    mov dx,offset fwrite_err_tc
    mov ax, seg fwrite_err_tc
    mov ds,ax
    mov ah,9
    int 21h
    jmp exit

fread_err:
    mov dx,offset fread_err_tc
    mov ax, seg fread_err_tc
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
