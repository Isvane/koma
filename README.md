# Koma

My first attempt in learning the X86-64 Assembly language.

## Quick Start

```bash
# Assembling
nasm -f elf64 src/hello.asm -o hello.o
# Linking
ld hello.o -o hello
# Running the code
./hello
```

## Output Example

```bash
Hello, World!
42
42 # Echoing user input
The answer to the ultimate question of life!
```
