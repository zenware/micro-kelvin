/*
* This is a C99 Formatted file. I was having a lot more trouble finding C docs
* for some of the stuff I wanted to document, so I'll have to come back later
* and add them as I find them.
* This file needs to be cross compiled with the command:
* `clang -target i686-elf -c src/kernel.c -o build/kernel.o -std=gnu99 -ffreestanding -nostdlib -Wall -Wextra`
*/

/*
* Since there is no C Library in the OS we can only use header
* files defined by the compiler.
* C Freestanding Execution Format Supports these headers
* float.h, iso646.h, limits.h, stdalign.h, stdarg.h, stdbool.h, stddef.h,
* stdint.h and stdnoreturn.h (as of C11).
* All of these consist of typedef s and #define s "only", so you can implement
* them without a single .c file in sight.
*/
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/*
* Hardware text mode color constants.
* https://en.wikipedia.org/wiki/Video_Graphics_Array#Color_palette
* -----
* CGA	EGA	VGA	RGB	Web	Example
* 0x0	0x0	0,0,0	0,0,0	#000000	black
* 0x1	0x1	0,0,42	0,0,170	#0000aa	blue
* 0x2	0x2	00,42,00	0,170,0	#00aa00	green
* 0x3	0x3	00,42,42	0,170,170	#00aaaa	cyan
* 0x4	0x4	42,00,00	170,0,0	#aa0000	red
* 0x5	0x5	42,00,42	170,0,170	#aa00aa	magenta
* 0x6	0x14	42,21,00	170,85,0	#aa5500	brown
* 0x7	0x7	42,42,42	170,170,170	#aaaaaa	gray
* 0x8	0x38	21,21,21	85,85,85	#555555	dark gray
* 0x9	0x39	21,21,63	85,85,255	#5555ff	bright blue
* 0xA	0x3A	21,63,21	85,255,85	#55ff55	bright green
* 0xB	0x3B	21,63,63	85,255,255	#55ffff	bright cyan
* 0xC	0x3C	63,21,21	255,85,85	#ff5555	bright red
* 0xD	0X3D	63,21,63	255,85,255	#ff55ff	bright  magenta
* 0xE	0x3E	63,63,21	255,255,85	#ffff55	Yellow
* 0xF	0x3F	63,63,63	255,255,255	#ffffff	white
*/
enum vga_color {
	COLOR_BLACK = 0,
	COLOR_BLUE = 1,
	COLOR_GREEN = 2,
	COLOR_CYAN = 3,
	COLOR_RED = 4,
	COLOR_MAGENTA = 5,
	COLOR_BROWN = 6,
	COLOR_LIGHT_GREY = 7,
	COLOR_DARK_GREY = 8,
	COLOR_LIGHT_BLUE = 9,
	COLOR_LIGHT_GREEN = 10,
	COLOR_LIGHT_CYAN = 11,
	COLOR_LIGHT_RED = 12,
	COLOR_LIGHT_MAGENTA = 13,
	COLOR_LIGHT_BROWN = 14,
	COLOR_WHITE = 15,
};

/*
* VGA Text buffer
* https://en.wikipedia.org/wiki/VGA-compatible_text_mode#Text_buffer
* Each screen character is actually represented by two bytes aligned as a
* 16-bit word accessible by the CPU in a single operation.
* The lower, or character, byte is the actual code point for the current
* character set, and the higher, or attribute, byte is a bit field used to
* select various video attributes such as color, blinking, character set, and
* so forth. This byte-pair scheme is among the features that the VGA inherited
* from the EGA, CGA, and ultimately from the MDA.
*/
/*
* This is what the data structure actually looks like.
* ----------------------------------------------------
* |               Attribute               |Character |
* |    7|             654|            3210|  76543210|
* |Blink|Background color|Foreground color|Code point|
* ----------------------------------------------------
* The blink bit is sometimes actually more room for background color.
* I am not in a mode that supports a blink bit, so all four are for background
*/

/*
* This function outputs the higher-half, or foreground color, background color,
* and blink mode of the VGA Text Buffer Datastructure
*/
uint8_t make_color(enum vga_color fg, enum vga_color bg) {
	return fg | bg << 4;
}

/*
* This function creates the lower-half or character/code point of the VGA
* Text Buffer and combines it with an already created higher-half/color.
*/
uint16_t make_vgaentry(char c, uint8_t color) {
	uint16_t c16 = c;
	uint16_t color16 = color;
	return c16 | color16 << 8;
}

size_t strlen(const char* str) {
	size_t ret = 0;
	while (str[ret] != 0) {
		ret++;
	}
	return ret;
}

/*
* We are going to be in VGA 03h mode which supports only 80x25 Text resolution,
* 16 colors, and 8 pages
*/
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

/*
* Column and Row are VGA Cursor Positions
* These values are all global so they can be modified from inside functions.
*/
size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color; /* VGA Text Buffer - Higher Half */
uint16_t* terminal_buffer; /* VGA Text Buffer Pointer - could be assigned now */

/*
* Assign a character and the global color, to a specific location in VGA memory.
* NOTE: Actually to a specific X, Y coordinate in the VGA Text Buffer Grid
* TODO: Check out of bounds?
*/
void terminal_putentryat(char c, uint8_t color, size_t col, size_t row) {
	const size_t index = row * VGA_WIDTH + col;
	terminal_buffer[index] = make_vgaentry(c, color);
}

/*
* Fills the entire VGA Color Text Mode buffer with spaces
*/
void terminal_clear(void) {
	for (size_t row = 0; row < VGA_HEIGHT; row++) {
		for (size_t col = 0; col < VGA_WIDTH; col++) {
			terminal_putentryat(' ', terminal_color, col, row);
		}
	}
}

/*
* Fills one row of the VGA Color Text Mode buffer with spaces
*/
void terminal_row_clear(size_t row) {
	for (size_t col = 0; col < VGA_WIDTH; col++) {
		terminal_putentryat(' ', terminal_color, col, row);
	}
}

/*
* Returns the VGA Text Buffer Index position matching a set of coordinates
* This might be too verbose but could still be useful as an interface.
*/
size_t terminal_coords_to_index(size_t col, size_t row) {
	return row * VGA_WIDTH + col;
}

/*
* Returns the character data from an (x, y) coordinate in the Text Buffer
*/
uint16_t terminal_getdatafrom(size_t col, size_t row) {
	const size_t index = terminal_coords_to_index(col, row);
	return terminal_buffer[index];
}

/*
* Get color information from positional information
*/
uint8_t terminal_getcolor(size_t x, size_t y) {
	uint16_t data = terminal_getdatafrom(x, y);
	// NOTE: Move the higher-half into the lower-half.
	return data >> 8;
}

/*
* Copies data from one text buffer coordinate to another textbuffer coordinate
*/
void
terminal_tbcopy(
	size_t col_from,
	size_t row_from,
	size_t col_to,
	size_t row_to
)
{
	const size_t index = terminal_coords_to_index(col_to, row_to);
	terminal_buffer[index] = terminal_getdatafrom(col_from, row_from);
}

/*
* Shift a vga color text mode buffer row up one row
* Consider enumerated relative directions. enum direction UP, DOWN
*/
void terminal_shift_row_up(size_t row) {
	// NOTE: Shouldn't try moving row 0 out to row -1 or, row 25 in to row 24
	if (row == 0 || row == VGA_HEIGHT) {
		return;
	}
	// NOTE: - 1 is closer to the top, which is 0
	size_t row_up = row - 1;
	// Loop from 0 -> 79
	for (size_t col = 0; col < VGA_WIDTH; ++col) {
		//uint16_t data = terminal_getdatafrom(col, row);
		//uint8_t color = data >> 8;
		//uint8_t color = terminal_getcolor(col, row);
		//terminal_putentryat(data, color, col, row_up);
		terminal_tbcopy(col, row, col, row_up);
	}
}

/*
* Scrolls all the lines up one and leaves a blank line at the bottom.
* NOTE: definitely is doing some weird shit
* Doublecheck operations on 'y'
* NOTE: There is a bug here.
* TODO: There is literally a bug in this somehow and it seems silly.
*/
void terminal_scroll(void) {
	// NOTE: If you start at row 0, you'll be moving data out of memory.
	for (size_t row = 1; row < VGA_HEIGHT; --row) {
		terminal_shift_row_up(row);
	}
}

/*
* Change the global terminal color to a new color. (created with make_color)
*/
void terminal_setcolor(uint8_t color) {
	terminal_color = color;
}

/*
* Move the cursor to a specified row and column
*/
void terminal_cursor_move(size_t x, size_t y) {
	terminal_row = y;
	terminal_column = x;
}

/*
* Returns the column of the terminal cursor
*/
size_t terminal_cursor_getcol(void) {
	return terminal_column;
}

/*
* Returns the row of the terminal cursor
*/
size_t terminal_cursor_getrow(void) {
	return terminal_row;
}

/*
*/
void terminal_cursor_shift_up_if_needed(void) {
	// If the cursor as reached the far bottom boundary
	if (terminal_cursor_getrow() == VGA_HEIGHT - 1) {
		// Move the cursor up one line
		terminal_cursor_move(
			terminal_cursor_getcol(),
			terminal_cursor_getrow() - 1
		);
		// Move the buffer data up one line
		terminal_scroll();
		//terminal_scroll();
		terminal_row_clear(terminal_cursor_getrow());
	}
}

/*
* Move the cursor "forward" one position, and wrap at the end of the line.
* TODO: I think this aspect of the code interface needs some more work.
*
*/
void terminal_cursor_advance(void) {
	// Move the cursor forward one position in a line.
	terminal_cursor_shift_up_if_needed();
	terminal_cursor_move(terminal_cursor_getcol() + 1, terminal_cursor_getrow());
	// If the cursor has reached the far right boundary
	if (terminal_cursor_getcol() == VGA_WIDTH) {
		// Reset the cursor to the first position and move one line down.
		terminal_cursor_move(0, terminal_cursor_getrow() + 1);
		terminal_cursor_shift_up_if_needed();
	}
}

/*
* Move the cursor "backward" one position, and wrap at the start of the line.
*/
void terminal_cursor_recede(void) {
	if (terminal_column == 0) {
		terminal_column = VGA_WIDTH;
		--terminal_row;
	}
	--terminal_column;
}

/*
* non returning function
* sets the starting VGA cursor position to 0,0 ; the upper lefthand corner
*
* https://en.wikipedia.org/wiki/VGA-compatible_text_mode#Access_methods
* The text screen video memory for colour monitors resides at 0xB8000
* initializes the terminal buffer to a pointer 0xB8000
*
* Creates a text buffer color with a cyan foreground and a black background
* Assigns every (16 bit word sized) position in the text screen video memory
* to a ' ' or space character.
*/
void terminal_initialize() {
	terminal_cursor_move(0, 0);
	terminal_setcolor(make_color(COLOR_LIGHT_CYAN, COLOR_BLACK));

	terminal_buffer = (uint16_t*) 0xB8000; // Start of VGA Color Memory
	terminal_clear();
}

/*
* Assign a character, and the global color, to the 'cursor' position.
* and manipulate just what that cursor position is.
*/
void terminal_putchar(char c) {
	// Scroll the terminal up if your cursor is at the bottom.
	// Make sure we don't write to the bottom row.
	if (terminal_cursor_getrow() == VGA_HEIGHT - 1) {
		terminal_scroll();
		terminal_scroll();
		terminal_scroll();
		terminal_scroll();
		terminal_cursor_move(terminal_cursor_getcol(), terminal_cursor_getrow());
	}
	/*
	* If a newline character is encountered within a string, write blanks down
	* the rest of the row, move the cursor down a row, and to the first column
	* of the next line.
	*/
	if (c == '\n') {
		terminal_cursor_move(0, terminal_cursor_getrow() + 1);
		/*
		* move all rows up one row and discard the upper most, and leave a blank
		* row at the bottom
		*/
		if (terminal_cursor_getrow() == VGA_HEIGHT - 1) {
			terminal_scroll(); // TODO: Figure out where this actually needs to be.
			// I think terminal_scroll() should be in writestring as an encapsulated
			// conditional.
			terminal_cursor_move(terminal_cursor_getcol(), terminal_cursor_getrow() - 1);
			terminal_row_clear(terminal_cursor_getrow());
		}
	} else {
		/*
		* If the character is not a newline we actually do more than just move the
		* cursor, and write the character as well. After writing a character we
		* figure out where the next cursor position will be and decide if we need
		* to reset the line feed
		*
		* Actually write the character data to the cursor position.
		* In case I have been moving the write cursor around I should push all
		* the data ahead of myself in a column to the right before I write a char.
		*/
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);

		/*
		* Move the cursor a column forward after writing the a character, check
		* whether we are at the end of the line.
		* If so, reset the line feed to the far left.
		*/
		terminal_cursor_advance();
	}
}

/*
* Assign a series of characters in order to VGA Memory, for outputing strings.
* Does not support newlines...
*/
void terminal_writestring(const char* data) {
	size_t datalen = strlen(data);
	for (size_t i = 0; i < datalen; i++) {
		terminal_putchar(data[i]);
	}
}

/*
* Writes a string with a newline at the end of it.
*/
void terminal_println(const char* data) {
	terminal_writestring(data);
	terminal_writestring("\n");
}

/*
* Populate the terminal with a rainbow of characters...
* potentially use 'writesring'?
*/
void terminal_write_rainbow(void) {
	// Temporary value stores the terminal color to return it correctly later.
	// uint8_t orig_terminal_color = terminal_color;
	terminal_println("");
	for (uint8_t bg = COLOR_BLACK; bg < COLOR_WHITE; ++bg) {
		for (uint8_t fg = COLOR_BLACK; fg < COLOR_WHITE; ++fg) {
			terminal_setcolor(make_color(fg, bg));
			terminal_writestring("|A");
		}
		terminal_writestring("|\n");
	}
	terminal_writestring("\n");
	terminal_setcolor(make_color(COLOR_LIGHT_CYAN, COLOR_BLACK));
}

/*
* Setup the VGA Buffer Memory and Print the String "Hello, kernel!\n"
*/
void kernel_main() {
	terminal_initialize();

	for (size_t i = 0; i < 6; ++i) {
		terminal_println("Hello, kernel!");
	}

	terminal_setcolor(make_color(COLOR_LIGHT_BLUE, COLOR_BLACK));
	for (size_t l = 0; l < 6; ++l) {
		terminal_println("Hello, kernel!");
	}

	terminal_setcolor(make_color(COLOR_WHITE, COLOR_BLACK));
	for (size_t j = 0; j < 6; ++j) {
		terminal_writestring("Oh no, not again! ");
	}

	// TODO: Figure out why it escapes the buffer when I write the rainbow.
	//terminal_write_rainbow();
	terminal_setcolor(make_color(COLOR_LIGHT_GREEN, COLOR_BLACK));
	terminal_println("Look who implemented line wrapping, and terminal window scrolling, it was me. It was all me!!! Muahahahaha!");

	terminal_setcolor(make_color(COLOR_RED, COLOR_BLACK));
	for (size_t m = 0; m < 6; ++m) {
		terminal_println("Goodbye, kernel!");
	}

	terminal_setcolor(make_color(COLOR_LIGHT_RED, COLOR_BLACK));
	for (size_t k = 0; k < 6; ++k) {
		terminal_println("Goodbye, kernel!");
	}

	// Why doesn't the first digit get written.
	terminal_setcolor(make_color(COLOR_LIGHT_MAGENTA, COLOR_BLACK));
	terminal_writestring("123456789");
}
