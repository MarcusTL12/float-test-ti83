#include "../header.asm"

title:
    .db "test gemv",0

#define width 2
#define height 2

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


    or a                        ; T/N
    ld hl, height   \ push hl   ; m
    ld hl, width    \ push hl   ; n
    ld hl, one_f32  \ push hl   ; alpha
    ld hl, 1        \ push hl   ; incx
    ld hl, zero_f32 \ push hl   ; beta
    ld hl, 1        \ push hl   ; incy

    ld hl, rand_data            ; A
    ld ix, 2                    ; lda
    ld de, rand_data + width * height * 4 ; x
    ld bc, vec_out              ; y

    call sgemv


    ld b, width
    ld hl, vec_out
    ld de, 4
    -:
        push bc
        ld bc, str_buf
        call f32toa
        add hl, de

        push hl \ push de
        ld hl, str_buf
        bcall(_puts)
        bcall(_newline)

        pop de \ pop hl

        pop bc
        djnz {-}

    bcall(_getkey) ; Pause
    ret

str_buf:
    .db "xxxxxxxxxxxxxxxxxxxx",0

rand_data:
#incbin "test_data/randn8.dat"

vec_out:
    .fill 4 * width

#define scrap saferam4
#define char_NEG '-'

#include "misc/constants.asm"

#include "z80float_brass/conversion/atof32.z80"
#include "z80float_brass/conversion/f32toa.z80"

#include "blas/level2/sgemv.asm"
