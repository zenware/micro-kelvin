#!/usr/bin/env bash

# Build the ASM File which Bootstraps the C Callstack
# -M is "generate Makefile dependencies on stdout", why did I ever have that...
nasm -f elf -M src/boot.asm -o build/boot.o

# Build the C File which Bootstraps the VGA Color Text mode
# And outputs the text 'Hello Kernel'
# ~/opt/cross/bin/i686-elf-gcc -c src/kernel.c -o build/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
# NOTE: Why would I have used -std=gnu99 and also -nostdlib
i686-elf-gcc -c src/kernel.c -o build/kernel.o -std=gnu99 -ffreestanding -O2 -nostdlib -Wall -Wextra
# Link the ELF objects together correctly into a bootable binary.
# TODO: Figure out the -lgcc thing.
i686-elf-gcc -T src/linker.ld -o build/micro-kelvin.bin -ffreestanding -O2 -nostdlib build/boot.o build/kernel.o -lgcc
# clang -T src/linker.ld -o build/micro-kelvin.bin -ffreestanding -O2 -nostdlib build/boot.o build/kernel.o -lgcc

# Setup a directory structure for grub to build an iso
#mkdir -p build/boot/grub
#cp build/micro-kelvin.bin build/boot/micro-kelvin.bin
#cp src/grub.cfg build/boot/grub/grub.cfg
#grub-mkrescue -o build/micro-kelvin.iso build
#curl --upload-file build/micro-kelvin.iso https://transfer.sh/micro-kelvin.iso

# Remove Build Artifacts
# rm build/boot.o
# rm build/kernel.o
# rm build/micro-kelvin.bin
# rm -rf build/boot

#curl --upload-file build/micro-kelvin.bin https://transfer.sh/micro-kelvin.bin

# Change from Vagrant
