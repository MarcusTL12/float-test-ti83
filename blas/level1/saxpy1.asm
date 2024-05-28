#ifndef included_saxpy
#define included_saxpy

#include "z80float_brass/f32/f32mul.z80"
#include "z80float_brass/f32/f32add.z80"

; Inputs:
;   BC:         n
;   stack 0:    points to scalar a
;   HL:         points to vector x
;   DE:         points to vector y
saxpy1:
    ; Retrieve vector y in stack:
    di
    exx
    pop hl ; get return address
    ex (sp), hl ; swap pointer with ret
    ld (saxpy_scal_buf), hl ; Put pointer in buf
    exx
    ei
-:
    push bc ; {0}
    push de ; {1} y

    ; Perform mul x * a -> buf
    ld de, (saxpy_scal_buf)
    ld bc, saxpy_buf
    call f32mul

    pop de ; {1} y
    push hl ; {1} a

    ; Perform add buf + y -> y
    ld hl, saxpy_buf
    ld b, d
    ld c, e
    call f32add

    pop hl ; {1} a

    ; Increment x/y
    inc hl \ inc hl \ inc hl \ inc hl
    inc de \ inc de \ inc de \ inc de

    ; Loop logic
    pop bc ; {0}
    xor a
    dec bc
    or b
    jr nz, {-}
    or c
    jr nz, {-}

    ret

saxpy_buf:
    .block 4

saxpy_scal_buf:
    .block 2

#endif
