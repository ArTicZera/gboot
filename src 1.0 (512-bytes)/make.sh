clear

nasm -fbin boot.asm -o gboot.img

qemu-system-i386 -drive format=raw,file="gboot.img"
