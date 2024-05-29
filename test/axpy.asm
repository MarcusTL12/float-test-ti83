#include "../header.asm"

title:
    .db "test float",0

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

    ld hl, test_str1
    ld bc, test_float1
    call atof32

    ld hl, test_str2
    ld bc, test_float2
    call atof32

    ld hl, test_str3
    ld bc, test_float3
    call atof32

    ld hl, test_str4
    ld bc, test_float4
    call atof32

    ld hl, test_str5
    ld bc, test_float5
    call atof32

    ld bc, 2            ; n = 2
    ld hl, test_float5
    push hl             ; a
    ld hl, test_float1  ; x
    ld de, test_float2  ; y
    ld ix, 2            ; inc x
    push ix             ; inc y = inc x
    call saxpy

    ld hl, test_float1
    ld bc, test_data
    call f32toa

    ld hl, test_data
    bcall(_puts)
    bcall(_newline)

    ld hl, test_float2
    ld bc, test_data
    call f32toa

    ld hl, test_data
    bcall(_puts)
    bcall(_newline)

    ld hl, test_float3
    ld bc, test_data
    call f32toa

    ld hl, test_data
    bcall(_puts)
    bcall(_newline)

    ld hl, test_float4
    ld bc, test_data
    call f32toa

    ld hl, test_data
    bcall(_puts)
    bcall(_newline)

    bcall(_getkey) ; Pause
    ret

test_data:
    .db "xxxxxxxxxxxxxxxxxxxx",0

test_str1:
    .db "3.141592",0

test_str2:
    .db "5.789e-3",0

test_str3:
    .db "2.879e2",0

test_str4:
    .db "1998",0

test_str5:
    .db "2.0",0

test_float1:
    .dw 0000h,0000h

test_float2:
    .dw 0000h,0000h

test_float3:
    .dw 0000h,0000h

test_float4:
    .dw 0000h,0000h

test_float5:
    .dw 0000h,0000h

#define scrap saferam4
#define char_NEG '-'

#include "z80float_brass/conversion/atof32.z80"
#include "z80float_brass/conversion/f32toa.z80"

#include "blas/level1/saxpy.asm"
