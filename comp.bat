set program=%1
echo Compiling %program%.asm program 

NASM\NASM.EXE -f OBJ %program%.asm -o %program%.obj
VAL\VAL.EXE %program%.obj