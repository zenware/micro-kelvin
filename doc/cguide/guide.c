// Short Names for Primitive Types
typedef uint8_t u8;
typedef char16_t c16;
typedef int32_t b32; // communicates intent
typedef int32_t i32;
typedef uint32_t u32;
typedef uint64_t u64;
typedef float f32;
typedef double f64;
typedef uintptr_t uptr;
typedef char byte;
typedef ptrdiff_t size;
typedef size_t usize;

// "Standard" Macros
#define countof(a) (size)(sizeof(a) / sizeof(*(a)))
#define lengthof(s) (countof(s) - 1)
#define new(a, t, n) (t *)alloc(a, sizeof(t), _Alignof(t), n)
/*
assert for gcc and clang
- single definition for debug and release builds
- libubsan provide diags with file and line no.
- practical optimization hint in release builds

Release Builds:
-fsanitize-trap
-fsanitize=unreachable
or, when fixed in gcc
-funreachable-traps
*/
#define assert(c) while(!(c)) __builtin_unreachable()

/*
Parameters and functions:
- no `const`
- Literal 0 for null pointers... https://ljabl.com/nullptr.xhtml
- `restrict` when necessary, but try to avoid
- `typedef` all structures
- Declare all functions `static`
- Reject null-terminated strings
*/

// Basic String Types
#define s8(s) (s8){(u8 *)s, lengthof(s)}
typedef struct {
    u8 *data;
    size len;
} s8;
static s8 s8span(u8 *, u8 *);
static b32 s8equals(s8, s8);
static size s8compare(s8, s8);
static u64 s8hash(s8);
static s8 s8trim(s8);
// TODO: Where is the arena type from?
// - https://nullprogram.com/blog/2023/01/18/#implementation-highlights
// static s8 s8clone(s8, arena *);

#define s16(s) (s16){u##s, lengthof(u##s)}
typedef struct {
    c16 *data;
    size len;
} s16;

/*
More Structures
- enables multiple return values without destructuring
- better than standard out parameter
- better organization

Only use conventional zero-initializer except for s8 and s16 macros.
Instead, initialize with assignments.
*/
typedef struct {
    i32 value;
    b32 ok;
} i32parsed;

static i32parsed i32parse(s8);

static i32parsed i32parse(s8 s)
{
    i32parsed r = {0};
    for (size i = 0; i < s.len; i++) {
        u8 digit = s.data[i] - '0';
        // ...
        if (overflow) {
            return r;
        }
        r.value = r.value*10 + digit;
    }
    r.ok = 1;
    return r;
}

typedef struct {
    u8 *buf;
    i32 len;
    i32 cap;
    i32 fd;
    b32 err;
} u8buf;

static u8buf newu8buf(arena *perm, i32 cap, i32 fd)
{
    u8buf r = {0};
    r.buf = new(perm, u8, cap);
    r.cap = cap;
    r.fd = fd;
    return r;
}

// Prefer __attribute to __attribute__
// __attribute((malloc, alloc_size(2, 4)))

/*
For Win32 Systems Programming -- use custom decls instead of windows.h
*/
#define W32(r) __declspec(dllimport) r __stdcall
W32(void) ExitProcess(u32);
W32(i32) GetStdHandle(u32);
W32(byte *) VirtualAlloc(byte *, usize, u32, u32);
W32(b32) WriteConsoleA(uptr, u8 *, u32, u32 *, void *);
W32(b32) WriteConsoleW(uptr, c16 *, u32, u32 *, void *);

/*
For inline assembly, treat the outer parenthesis like braces,
put a space before the opening parenthesis, just like if,
and start each constraint line with its colon.
*/
static u64 rdtscp(void)
{
    u32 hi, lo;
    asm volatile (
        "rdtscp"
        : "=d"(hi), "=a"(lo)
        :
        : "cx", "memory"
    );
    return (u64)hi<<32 | lo;
}