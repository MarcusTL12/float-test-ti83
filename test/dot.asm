#include "../header.asm"

title:
    .db "test sdot",0

#define vec_y vec_x + 4 * 4

main:
    bcall(_clrscrf)
    bcall(_homeup)
    ld hl, title
    bcall(_puts)
    bcall(_newline)

    ld hl, main
    bcall(_disphl)
    bcall(_newline)
    bcall(_getkey) ; Pause

    ld hl, float_out
    push hl
    ld bc, 4
    ld hl, vec_x
    ld de, vec_x + 4
    ld ix, 2
    push ix
    or a
    call sdot

    ld hl, float_out
    ld bc, str_buf
    call f32toa

    ld hl, str_buf
    bcall(_puts)
    bcall(_newline)

    bcall(_getkey) ; Pause
    ret

str_buf:
    .db "xxxxxxxxxxxxxxxxxxxx",0

vec_x:
#incbin "test_data/randn8.dat"

float_out:
    .dw f5c3h,4048h

#define scrap saferam4
#define char_NEG '-'

#include "z80float_brass/conversion/atof32.z80"
#include "z80float_brass/conversion/f32toa.z80"

#include "blas/level1/sdot.asm"
