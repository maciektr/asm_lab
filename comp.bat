set program=%1
echo Compiling %program%.asm program with nasm
NASM\NASM.EXE -f OBJ %program%.asm -o %program%.obj

echo Linking %program%.obj program with val
VAL\VAL.EXE %program%.obj