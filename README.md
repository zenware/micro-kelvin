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

## Yet another build method on the way.
Converting to rust following the first edition of this series https://os.phil-opp.com/multiboot-kernel/

Build an OS Image
```sh
cargo add bootloader
cargo install bootimage
rustup component add llvm-tools-preview
cargo bootimage

# qemu-system-x86_64 -kernel target\x86_64-os\debug\bootimage-micro-kelvin.bin
qemu-system-x86_64 -drive format=raw,file=target\x86_64-os\debug\bootimage-micro-kelvin.bin
```

Compile for CPU Target
```sh
cargo build --target wasm32-unknown-unknown
cargo build --target thumbv7em-none-eabihf
```

Compile for Host OS
```sh
# Linux
cargo rustc -- -C link-arg=-nostartfiles
# Windows
cargo rustc -- -C link-args="/ENTRY:_start /SUBSYSTEM:console"
# macOS
cargo rustc -- -C link-args="-e __start -static -nostartfiles"
```

Compile with Custom Target Definition
```sh
cargo build --target x86_64-os.json

# Need to build parts of the stdlib.
# TODO: Manually specify toolchain https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file
rustup component add rust-src --toolchain nightly
cargo +nightly build -Z build-std --target x86_64-os.json
```

---
## TODO
* Not Sure yet.
* Interrupt handling
* PS/2 Keyboard Input
* Basic Filesystem
* Basic Shell
* Basic Virtual / Physical Memory Map
* Basic Heap Allocator (malloc/free)
---

## Currently Implemented
* [16550 UART](https://en.wikipedia.org/wiki/16550_UART) To write out to serial.
//* Create the Multiboot header with ASM
//* Setup a stack to be used by C
//* then call an external symbol "kernel_main" (written in C)
* Address the VGA Color Monitor Text Buffer
* Write some data to the buffer and scroll the screen
