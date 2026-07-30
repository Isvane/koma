default:
    @just --list

# ==============================================================================
# x86 Experiments
# ==============================================================================

http-server:
    nasm -f elf64 src/x86/http/server.asm -o server.o
    ld server.o -o server
    ./server

http-get:
    curl http://localhost:9888

http-post:
    curl -i -X POST http://localhost:9888

hello:
    nasm -f elf64 src/x86/random/hello.asm -o hello.o
    ld hello.o -o hello
    -./hello

# ==============================================================================
# ARM / Game Boy Advance Experiments
# ==============================================================================

gba-build:
    arm-none-eabi-gcc -mcpu=arm7tdmi -mthumb-interwork -c src/arm/gba/main.s -o main.o
    arm-none-eabi-gcc -mcpu=arm7tdmi -nostartfiles -Wl,-Ttext=0x08000000 main.o -o main.elf
    arm-none-eabi-objcopy -O binary main.elf isvane.gba

gba: gba-build
    mgba-qt isvane.gba

# ==============================================================================
# Utilities
# ==============================================================================

clean:
    rm -f *.o server hello main.elf isvane.gba isvane.sav
