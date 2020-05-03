; compiled with nasm 2.14.02 and then linked with val
cpu 8086

segment dane .data
	txt1 db "Hello World! :) $"

segment stos1 stack
    resb 64

segment .text 
..start:
    mov ax, SEG txt1
    mov ds,ax

    mov ax, stos1
    mov ss, ax

    mov dx, txt1

    mov ah, 09h
    int 21h

    mov ah,4ch
    int 21h