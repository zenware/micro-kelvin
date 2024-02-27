/*
* The GNU linker - ld
* https://www.eecs.umich.edu/courses/eecs373/readings/Linker.pdf
*/

/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. */
/*
* 3.4.1 Setting the Entry Point
* The first instruction to execute in a program is called the entry point. You can use the
* ENTRY linker script command to set the entry point. The argument is a symbol name:
* ENTRY(symbol)
* There are several ways to set the entry point. The linker will set the entry point by trying
* each of the following methods in order, and stopping when one of them succeeds:
*   • the ‘-e’ entry command-line option;
*   • the ENTRY(symbol) command in a linker script;
*   • the value of the symbol start, if defined;
*   • the address of the first byte of the ‘.text’ section, if present;
*   • The address 0.
*
* Here we set the entry point to the symbol '_start' exported from 'boot.asm'
*/
ENTRY(_start)


/*
* 3.6.4.5 Input Section Example
* Combine the generated object file symbols in the correct order.
* kernel image.
*/
SECTIONS
{
	/* Begin putting sections at 1 MiB, a conventional place for kernels to be
	   loaded at by the bootloader. */
	. = 1M;

  /*
  * Start with the .multiboot symbol from the boot.o file because it defines
  * the multiboot header and must come first so our final object is correctly
  * interpreted as a multiboot binary.
  *
  * Since the first bit (bit 0) is flipped in the multiboot header, the data
  * must be (as expected by the multiboot implementation) aligned on 4kb blocks
  *
  * Then we include the .text symbol also from the boot.o file because the asm
  * text section is where the code definition begins.
  */
	.text ALIGN(4K) : ALIGN(4K)
	{
		*(.multiboot)
		*(.text)
	}

	/*
  * Read-only data.
  * I'm not sure if I need this.
  * These are the results of disassembling both the boot.o and the kernel.o
  * 0:	48                   	dec    %eax
  * 1:	65 6c                	gs insb (%dx),%es:(%edi)
  * 3:	6c                   	insb   (%dx),%es:(%edi)
  * 4:	6f                   	outsl  %ds:(%esi),(%dx)
  * 5:	2c 20                	sub    $0x20,%al
  * 7:	6b 65 72 6e          	imul   $0x6e,0x72(%ebp),%esp
  * b:	65 6c                	gs insb (%dx),%es:(%edi)
  * d:	21 0a                	and    %ecx,(%edx)
  */
	.rodata ALIGN(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/*
  * Read-write data (initialized)
  * Nothing showed up for this in the disassembly.
  */
	.data ALIGN(4K) : ALIGN(4K)
	{
		*(.data)
	}

	/*
  * Read-write data (uninitialized) and stack
  *
  * 3.6.4.3 Input Section for Common Symbols
  * A special notation is needed for common symbols, because in many object file formats
  * common symbols do not have a particular input section. The linker treats common symbols
  * as though they are in an input section named ‘COMMON’.
  * You may use file names with the ‘COMMON’ section just as with any other input sections.
  * You can use this to place common symbols from a particular input file in one section while
  * common symbols from other input files are placed in another section.
  * In most cases, common symbols in input files will be placed in the ‘.bss’ section in the
  * output file. For example:
  * .bss { *(.bss) *(COMMON) }
  * Some object file formats have more than one type of common symbol. For example, the
  * MIPS ELF object file format distinguishes standard common symbols and small common
  * symbols. In this case, the linker will use a different special section name for other types of
  * Chapter 3: Linker Scripts 53
  * common symbols. In the case of MIPS ELF, the linker uses ‘COMMON’ for standard common
  * symbols and ‘.scommon’ for small common symbols. This permits you to map the different
  * types of common symbols into memory at different locations.
  * You will sometimes see ‘[COMMON]’ in old linker scripts. This notation is now considered
  * obsolete. It is equivalent to ‘*(COMMON)’.
  *
  * Nothing showed up for .bss in the disassembly.
  *
  * thus .bootstrap_stack locates the stack right after the common symbols
  */
	.bss ALIGN(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
		*(.bootstrap_stack)
	}
}
