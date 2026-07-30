# Koma

Koma is a personal monorepo housing my experiments with Assembly.

## Quick Start

Running the HTTP Server:
```bash
# Assembling
nasm -f elf64 src/x86/http/server.asm -o server.o
# Linking
ld server.o -o server
# Run
./server

# 2nd Terminal
curl http://localhost:9888
curl -i -X POST http://localhost:9888
```

Running the ITOA & ATOI experiments:
```bash
# Assembling
nasm -f elf64 src/x86/random/hello.asm -o hello.o
# Linking
ld hello.o -o hello
# Run
./hello
```
