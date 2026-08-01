.section .text
.global _start
.arm

header:
    b _start

    @ Nintendo Logo (156 bytes, required for GBA header)
    .byte 0x24, 0xFF, 0xAE, 0x51, 0x69, 0x9A, 0xA2, 0x21, 0x3D, 0x84, 0x82, 0x0A, 0x84, 0xE4, 0x09, 0xAD
    .byte 0x11, 0x24, 0x8B, 0x98, 0xC0, 0x81, 0x7F, 0x21, 0xA3, 0x52, 0xBE, 0x19, 0x93, 0x09, 0xCE, 0x20
    .byte 0x10, 0x46, 0x4A, 0x4A, 0xF8, 0x27, 0x31, 0xEC, 0x58, 0xC7, 0xE8, 0x33, 0x82, 0xE3, 0xCE, 0xBF
    .byte 0x85, 0xF4, 0xDF, 0x94, 0xCE, 0x4B, 0x09, 0xC1, 0x94, 0x56, 0x8A, 0xC0, 0x13, 0x72, 0xA7, 0xFC
    .byte 0x9F, 0x84, 0x4D, 0x73, 0xA3, 0xCA, 0x9A, 0x61, 0x58, 0x97, 0xA3, 0x27, 0xFC, 0x03, 0x98, 0x76
    .byte 0x23, 0x1D, 0xC7, 0x61, 0x03, 0x04, 0xAE, 0x56, 0xBF, 0x38, 0x84, 0x00, 0x40, 0xA7, 0x0E, 0xFD
    .byte 0xFF, 0x52, 0xFE, 0x03, 0x6F, 0x95, 0x30, 0xF1, 0x97, 0xFB, 0xC0, 0x85, 0x60, 0xD6, 0x80, 0x25
    .byte 0xA9, 0x63, 0xBE, 0x03, 0x01, 0x4E, 0x38, 0xE2, 0xF9, 0xA2, 0x34, 0xFF, 0xBB, 0x3E, 0x03, 0x44
    .byte 0x78, 0x00, 0x90, 0xCB, 0x88, 0x11, 0x3A, 0x94, 0x65, 0xC0, 0x7C, 0x63, 0x87, 0xF0, 0x3C, 0xAF
    .byte 0xD6, 0x25, 0xE4, 0x8B, 0x38, 0x0A, 0xAC, 0x72, 0x21, 0xD4, 0xF8, 0x07

    .ascii "ISVANE EMU  "
    .ascii "GAME"
    .ascii "01"

    .byte 0x96             @ Fixed Flag Byte
    .byte 0x00
    .byte 0x00
    .space 7, 0x00
    .byte 0x00
    .byte 0x00             @ Checksum
    .space 2, 0x00

_start:
    @ Enable BG0 (Mode 0)
    ldr r0, =0x04000000
    ldr r1, =0x0100
    strh r1, [r0]

    @ Set BG0 Control (CBB 0, SBB 31)
    ldr r0, =0x04000008
    ldr r1, =0x1F00
    strh r1, [r0]

    @ Set Palette Entry #1 (Red)
    ldr r0, =0x05000000
    ldr r1, =0x001F
    strh r1, [r0, #2]

    @ Load solid color data into Tile #1
    ldr r0, =0x06000020
    ldr r1, =0x11111111
    mov r2, #8

load_tile_loop:
    str r1, [r0], #4
    subs r2, r2, #1
    bne load_tile_loop

    @ Plot Tilemap to VRAM (Centered: Row 3, Col 3)
    ldr r0, =isvane_map
    ldr r1, =0x0600F8C6
    mov r2, #6             @ 6 rows tall

draw_row_loop:
    mov r3, #24            @ 24 columns wide

draw_col_loop:
    ldrh r4, [r0], #2
    strh r4, [r1], #2
    subs r3, r3, #1
    bne draw_col_loop

    @ The screen is 32 tiles wide, but our text map is only 24 tiles wide.
    @ Jump ahead 16 bytes (8 blank tiles) to align with the start of the next line on screen.
    add r1, r1, #16
    subs r2, r2, #1
    bne draw_row_loop

    mov r5, #0
    ldr r6, =0x04000010
    ldr r7, =0x04000006

infinite_loop:
wait_vblank_start:
    ldrh r0, [r7]
    cmp r0, #160
    blo wait_vblank_start

    ldr r6, =0x04000130
    ldrh r0, [r6]
    tst r0, #(1 << 5)
    bne check_right

    add r5, r5, #1

check_right:
    tst r0, #(1 << 4)
    bne update_scroll

    sub r5, r5, #1

update_scroll:
    ldr r6, =0x04000010
    strh r5, [r6]

wait_vblank_end:
    ldrh r0, [r7]
    cmp r0, #160
    bhs wait_vblank_end

    b infinite_loop


.section .rodata
.align 2

@ This 24x6 grid creates pixel art spelling "ISVANE".
@ 0 = Invisible/Transparent tile, 1 = Solid Red tile
isvane_map:
    @ Row 0
    .hword 1,1,1, 0, 1,1,1, 0, 1,0,1, 0, 0,1,0, 0, 1,0,0,1, 0, 1,1,1
    @ Row 1
    .hword 0,1,0, 0, 1,0,0, 0, 1,0,1, 0, 1,0,1, 0, 1,1,0,1, 0, 1,0,0
    @ Row 2
    .hword 0,1,0, 0, 1,1,1, 0, 1,0,1, 0, 1,1,1, 0, 1,0,1,1, 0, 1,1,1
    @ Row 3
    .hword 0,1,0, 0, 0,0,1, 0, 1,0,1, 0, 1,0,1, 0, 1,0,0,1, 0, 1,0,0
    @ Row 4
    .hword 0,1,0, 0, 0,0,1, 0, 1,0,1, 0, 1,0,1, 0, 1,0,0,1, 0, 1,0,0
    @ Row 5
    .hword 1,1,1, 0, 1,1,1, 0, 0,1,0, 0, 1,0,1, 0, 1,0,0,1, 0, 1,1,1
