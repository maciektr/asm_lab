cpu 8086

segment dane .data
    txt0 db "asadksadkoasasddas 1!! $"
	txt1 db "To jest tekst! :)","$"

segment stos1 stack
    resb 64


segment .text 
..start:
    mov bl,[80h]
    mov byte [bx+81h],'$'
    mov dx, 082h
    mov ah, 09h 
    int 21h
exit:
    mov ah, 4ch
    int 21h