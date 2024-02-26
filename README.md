# µK - Microkernel

Drivers, Protocols, Filesystems, Etc. Should run in userspace
Thus the kernel itself should only support IPC, Virtual Memory,
and process scheduling.

The Microkernel design is more easy for me to grok. so I'm going to
head down that path first.

----

Actually I want to pursue a an Exokernel design, so the supported
stuff would just be allocating resources to userspace processes...
And the userspace processes would then get to choose their own
abstractions instead of relying on the kernel's.

So I need to preset disk blocks, memory pages, and processor time.
Which is Bare Disk I/O, Bare Memory I/O, and probably Completely Fair Scheduling.

----
Something I've done recently instead of using Vagrantfile to build a Gentoo system with a cross-compiler is switch to using zig as the compiler.
Weird dependency but it's been working the best for me to compile C on any system.

My preferred way of getting setup on Windows:
```
scoop install nasm
scoop install zig
scoop install qemu
scoop shim add qemu-system-i386 $env:userprofile + "\scoop\apps\qemu\current\qemu-system-i386.exe"
```

```sh
mkdir -p build
nasm -f elf32 src/boot.asm -o build/boot.o
zig build-obj -target x86-freestanding src/kernel.c && mv kernel.o build/
zig ld.lld -m elf_i386 -T src/linker.ld -o build/micro-kelvin.bin build/boot.o build/kernel.o
#curl --upload-file build/micro-kelvin.bin https://transfer.sh/micro-kelvin.bin
```

```sh
# If you additionally want to build and iso image
mkdir -p build/boot/grub
cp build/micro-kelvin.bin build/boot/micro-kelvin.bin
cp src/grub.cfg build/boot/grub/grub.cfg
grub-mkrescue -o build/micro-kelvin.iso build
```

And to clean up everything
```sh
rm build/*
```

Test with something like the following...
```sh
qemu-system-i386 -kernel build/micro-kelvin.bin 
```

---
## TODO
* Not Sure yet.
* Interrupt handling
* [16550 UART](https://en.wikipedia.org/wiki/16550_UART) To write out to serial.
* PS/2 Keyboard Input
* Basic Filesystem
* Basic Shell
* Basic Virtual / Physical Memory Map
* Basic Heap Allocator (malloc/free)
---

## Currently Implemented
* Create the Multiboot header with ASM
* Setup a stack to be used by C
* then call an external symbol "kernel_main" (written in C)
* Address the VGA Color Monitor Text Buffer
* Write some data to the buffer and scroll the screen
