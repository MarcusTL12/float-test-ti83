#ifndef included_saxpy
#define included_saxpy

#include "z80float_brass/f32/f32mul.z80"
#include "z80float_brass/f32/f32add.z80"

; Inputs:
;   BC:         n
;   stack 0:    points to scalar a
;   HL:         points to vector x
;   DE:         points to vector y
;   IX:         increment x
;   IY:         increment y
saxpy:
    ; Retrieve vector y in stack:
    di
    exx
    pop hl ; get return address
    ex (sp), hl ; swap pointer with ret
    ld (saxpy_scal_buf), hl ; Put pointer in buf
    exx
    ei

    push hl ; {0} Save pointer to x

    ; mul inc x by 4 (sizeof f32)
    push ix
    pop hl
    add hl, hl
    add hl, hl
    push hl
    pop ix

    ; mul inc y by 4 (sizeof f32)
    push iy
    pop hl
    add hl, hl
    add hl, hl
    push hl
    pop iy

    pop hl ; {0} restore x

-:
    push bc ; {0}
    push ix ; {1}
    push iy ; {2} Save increments on stack

    push de ; {3} y

    ; Perform mul x * a -> buf
    ld de, (saxpy_scal_buf)
    ld bc, saxpy_buf
    call f32mul

    pop de ; {3} y
    push hl ; {3} a

    ; Perform add buf + y -> y
    ld hl, saxpy_buf
    ld b, d
    ld c, e
    call f32add

    pop hl ; {3} a

    ; Increment y with inc y
    ex (sp), hl ; swap inc y (on stack) with x
    ex de, hl
    add hl, de
    ex de, hl
    ex (sp), hl ; swap back

    pop iy ; {2}

    ; Increment x with inc x
    ex de, hl
    ex (sp), hl
    ex de, hl
    add hl, de
    ex de, hl
    ex (sp), hl

    pop ix ; {1}

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
