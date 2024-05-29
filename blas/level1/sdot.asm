#ifndef included_sdot
#define included_sdot

#include "z80float_brass/f32/f32add.z80"
#include "z80float_brass/f32/f32mul.z80"

; Inputs:
;   BC: n
;   HL: points to x
;   DE: points to y
;   IX: increment x
;   IY: increment y
;   stack 0: points to dest
sdot:
    di
    exx
    pop hl
    ex (sp), hl
    ld (sdot_out_ptr), hl
    exx
    ei

    push hl

    ld hl, (sdot_out_ptr)
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0

    pop hl

    ret

sdot_out_ptr:
    .fill 2

#endif
