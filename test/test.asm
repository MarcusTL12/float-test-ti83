#include "../header.asm"

title:
    .db "test float",0

main:
    bcall(_clrscrf)
    bcall(_homeup)
    ld hl, title
    bcall(_puts)
    bcall(_newline)

    ld hl, test_float1
    ld de, test_float2
    ld bc, test_float3
    call f32pow

    ld hl, test_float3
    ld bc, test_data
    call f32toa

    ld hl, test_data
    bcall(_puts)
    bcall(_newline)

    bcall(_getkey) ; Pause
    ret

test_data:
    .db "xxxxxxxxxxxxxxxxxxxx",0

test_float1:
    .dw e122h,301eh

test_float2:
    .dw 0e56h,4049h

test_float3:
    .dw 0000h,0000h

#define scrap saferam4
#define char_NEG '-'

#include "z80float_brass/conversion/f32toa.z80"
#include "z80float_brass/f32/f32pow.z80"
