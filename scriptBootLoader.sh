#!/bin/bash

# Compilar Boot Loader
nasm ourbootloader.asm -f bin -o ourbootloader.bin

# Compilar Programa
nasm tutoMeca.asm -f bin -o tutoMeca.bin

# Juntar los dos archivos
cat ourbootloader.bin tutoMeca.bin > finalBoot.bin

#Copiar el contenido en la USB
dd if=finalBoot.bin bs=2048 of=/dev/sdb1

#Ejecutar el emulador Qemu
qemu-system-x86_64 -machine accel=kvm:tcg -m 512 -hda /dev/sdb1