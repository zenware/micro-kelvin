; This file is written in NASM Syntax and intended to be built for the ELF
; file format with the command `nasm -f elf boot.asm -o boot.o`
; NASM Documentation: http://www.nasm.us/doc/nasmdoc3.html
; The goal is for this file to be fully documented with references to every
; feature used, both from NASM and GRUB. To that end, documentation will be
; heavily linked to, and often copied from source and pasted directly into this
; document.

; GNU GRUB is the reference implementation of a bootloader supporting the
; multiboot standard for booting an operating system kernel in a portable way.
; The documentation for multiboot is available at this URL:
; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
; The following contents of the file are a minimal implementation of the
; multiboot standard so I can get away with booting a kernel, without having
; to also write my own bootloader, which is already a well-defined task.

; The multiboot header specification can be found at this URL:
; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Header-layout
; I have taken the liberties of copying relevant portions of the documentation
; below. Both to be used as a reference while writing this file, and to help
; others (and my future self) understand the format while reading the file.

; Here are also the most recent source tracked versions of the multiboot2
; specification, and header file for reference.
; Specification as texinfo:
; http://git.savannah.gnu.org/cgit/grub.git/tree/doc/multiboot.texi?h=multiboot2
; C Header File:
; http://git.savannah.gnu.org/cgit/grub.git/tree/doc/multiboot2.h?h=multiboot2

; The layout of the Multiboot header must be as follows:
; Offset	Type	Field Name	Note
; 0	u32	magic	required
; 4	u32	flags	required
; 8	u32	checksum	required
; 12	u32	header_addr	if flags[16] is set
; 16	u32	load_addr	if flags[16] is set
; 20	u32	load_end_addr	if flags[16] is set
; 24	u32	bss_end_addr	if flags[16] is set
; 28	u32	entry_addr	if flags[16] is set
; 32	u32	mode_type	if flags[2] is set
; 36	u32	width	if flags[2] is set
; 40	u32	height	if flags[2] is set
; 44	u32	depth	if flags[2] is set

; Here are the primary three magic-fields declared in the header.
; These are required for it to be interpreted correctly by any implementation
; of the multiboot format.
; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Header-magic-fields

; The field ‘flags’ specifies features that the OS image requests or requires
; of a boot loader.

; Bits 0-15 indicate requirements; if the boot loader sees any of these bits
; set but doesn't understand the flag or can't fulfill the requirements it
; indicates for some reason, it must notify the user and fail to load the OS image.

; Bits 16-31 indicate optional features; if any bits in this range are set
; but the boot loader doesn't understand them, it may simply ignore them
; and proceed as usual. Naturally, all as-yet-undefined bits in the
; ‘flags’ word must be set to zero in OS images. This way, the ‘flags’ fields
; serves for version control as well as simple feature selection.

; If bit 0 in the ‘flags’ word is set, then all boot modules loaded along with
; the operating system must be aligned on page (4KB) boundaries. Some operating
; systems expect to be able to map the pages containing boot modules directly
; into a paged address space during startup, and thus need the boot modules to
; be page-aligned.

; 3.2.4 EQU: Defining Constants
; http://www.nasm.us/doc/nasmdoc3.html#section-3.2.4
; In NASM, 'equ' defines a symbol to be a constant value.
; in an 8-bit byte
; 1<<0 == 00000001
; which sets bit 0
MBALIGN equ 1<<0

; If bit 1 in the ‘flags’ word is set, then information on available memory via
; at least the ‘mem_*’ fields of the Multiboot information structure
; (see Boot information format) must be included. If the boot loader is capable
; of passing a memory map (the ‘mmap_*’ fields) and one exists, then it may be
; included as well.

; like the above, in an 8-bit byte
; 1<<1 == 00000010
; which sets bit 1
MEMINFO equ 1<<1

; If bit 2 in the ‘flags’ word is set, information about the video mode table
; (see Boot information format) must be available to the kernel.

; If bit 16 in the ‘flags’ word is set, then the fields at offsets 12-28 in the
; Multiboot header are valid, and the boot loader should use them instead of
; the fields in the actual executable header to calculate where to load the OS
; image. This information does not need to be provided if the kernel image is
; in elf format, but it must be provided if the images is in a.out format or in
; some other format. Compliant boot loaders must be able to load images that
; either are in elf format or contain the load address information embedded in
; the Multiboot header; they may also directly support other executable
; formats, such as particular a.out variants, but are not required to.

; Here, bits 0 and 1 are set so everything is aligned to 4kb and GRUB will
; provide the kernel with a memory map.
; FLAGS is actually a 32 bit / 4 byte structure, we only need 2 of those so far
; and are only using an 8 bit / 1 byte structure.
; 00000001 | 00000010 == 00000011
FLAGS equ MBALIGN | MEMINFO

; The field ‘magic’ is the magic number identifying the header,
; which must be the hexadecimal value 0x1BADB002.
; This identifier must appear in the first 8192 bytes of the file
MAGIC equ 0x1BADB002

; The field ‘checksum’ is a 32-bit unsigned value which,
; when added to the other magic fields (i.e. ‘magic’ and ‘flags’),
; must have a 32-bit unsigned sum of zero.

; Here the math should be obvious, by setting the value to the opposite
; of magic + flags, we can be sure that when added to magic and flags it will
; result in zero.
CHECKSUM equ -(MAGIC + FLAGS)

; This actually puts the previously declared header values into memory, aligned
; against a 4-byte boundary, in the order specified by the multiboot header
; layout specification linked to previously in this file.
; Here is the link again:
; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Header-layout
; The name .multiboot is given to the section so we can ensure it is located at
; the beginning of memory in the final object.

; 6.3 SECTION or SEGMENT: Changing and Defining Sections
; http://www.nasm.us/doc/nasmdoc6.html#section-6.3
section .multiboot

; 4.11.12 ALIGN and ALIGNB: Data Alignment
; http://www.nasm.us/doc/nasmdoc4.html#section-4.11.12
; align 4 ; align on 4-byte boundary
align 4

; 3.2.1 DB and Friends: Declaring Initialized Data
; http://www.nasm.us/doc/nasmdoc3.html#section-3.2.1
; DB, DW, DD, DQ, DT, DO, DY and DZ are used, much as in MASM, to declare
; initialized data in the output file.
; They can be invoked in a wide range of ways: ~~~~
; NOTE: I only list dd here because it is the only relevant invokation
; dd 0x12345678 ; 0x78 0x56 0x34 0x12
dd MAGIC
dd FLAGS
dd CHECKSUM

; Currently the stack pointer register (esp) points at anything and using it may
; cause massive harm. Instead, we'll provide our own stack. We will allocate
; room for a small temporary stack by creating a symbol at the bottom of it,
; then allocating 16384 bytes for it, and finally creating a symbol at the top.

; 7.9.2 elf extensions to the SECTION Directive
; http://www.nasm.us/doc/nasmdoc7.html#section-7.9.2
; progbits defines the section to be one with explicit contents stored in the
; object file: an ordinary code or data section, for example, nobits defines
; the section to be one with no explicit contents given, such as a BSS section.
section .bootstrap_stack, nobits
align 4
stack_bottom:

; 3.2.2 RESB and Friends: Declaring Uninitialized Data
; http://www.nasm.us/doc/nasmdoc3.html#section-3.2.2
; buffer: resb 64 ; reserve 64 bytes
resb 16384
stack_top:

; The linker script specifies _start as the entry point to the kernel and the
; bootloader will jump to this position once the kernel has been loaded. It
; doesn't make sense to return from this function as the bootloader is gone.
section .text

; 6.6 GLOBAL: Exporting Symbols to Other Modules
; http://www.nasm.us/doc/nasmdoc6.html#section-6.5
global _start
_start:
	; Kernel Mode

  ; This sets up the previously defined stack, so C can access it.
	; To set up a stack, we simply set the esp register to point to the top of
	; our stack (as it grows downwards).
  ; TODO: Talk about esp being the stack register.
	mov esp, stack_top

  ; 6.5 EXTERN: Importing Symbols from Other Modules
  ; http://www.nasm.us/doc/nasmdoc6.html#section-6.5
  ; The EXTERN directive takes as many arguments as you like.
  ; Each argument is the name of a symbol.
  ; C functions are a type of symbol

	extern kernel_main
	call kernel_main

  ; Appendix B: Instruction List
  ; http://www.nasm.us/doc/nasmdocb.html
  ; The following sections show the instructions which NASM currently supports.
  ; For each instruction, there is a separate entry for each supported
  ; addressing mode. The third column shows the processor type in which the
  ; instruction was introduced and, when appropriate, one or more usage flags.
  ; CLI 8086
  ; HLT 8086,PRIV

  ; The kernel function should never return and in case it does, put the CPU
  ; into an infinite loop.

  ; Clear Interrupt - disables interrupts.
	cli
.hang:
  ; Halt - stops CPU until the next interrupt.
	hlt
	jmp .hang
