#ifndef included_sscal
#define included_sscal

#include "z80float_brass/f32/f32mul.z80"

; Inputs:
;   BC: n
;   HL: points to scalar
;   DE: points to vector
;   IX: increment
sscal:
    push hl ; {0} Save pointer to scalar

    ; mul increment by 4 (sizeof f32)
    push ix ; {1}
    pop hl ; {1}
    add hl, hl
    add hl, hl
    push hl ; {1}
    pop ix ; {1}
    pop hl ; {0} restore scalar

-:
    push bc ; {0}
    push ix ; {1} Save increment on stack

    ; Perform mul
    ld b, d
    ld c, e
    call f32mul

    ; Increment de with increment
    ex (sp), hl ; swap increment (on stack) with scalar
    ex de, hl
    add hl, de
    ex de, hl
    ex (sp), hl ; swap back

    ; Loop logic
    pop ix ; {1} restore increment
    pop bc ; {0}
    xor a
    dec bc
    or b
    jr nz, {-}
    or c
    jr nz, {-}

    ret

#endif
