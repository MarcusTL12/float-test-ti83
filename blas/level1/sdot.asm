#ifndef included_sdot
#define included_sdot

#include "z80float_brass/f32/f32add.z80"
#include "z80float_brass/f32/f32mul.z80"

; Inputs:
;   BC:         n
;   stack 0:    points to dest
;   HL:         points to vector x
;   DE:         points to vector y
;   IX:         increment x
;   stack 1:    increment y
;   carry flag: false -> zero dest; true -> add to dest
sdot:
    ; Get stuff out of stack
    di
    ex af, af' ; save carry flag
    exx
    pop hl ; get return address
    pop de ; inc y
    ex (sp), hl ; swap dest with ret
    push hl
    push de
    push ix ; inc x
    exx

    ; Make space for f32 buffer on stack
    push hl
    push hl

    ; point ix to top of stack
    ld ix, 0
    add ix, sp

    ; Stack variables:
    ;
    ; | buf   | <- (ix)
    ; | buf   |
    ; | inc x | <- (ix + 4)
    ; | inc y | <- (ix + 6)
    ; | dest  | <- (ix + 8)
    ; | ret   | <- (ix + 10)

    ; Register variables:
    ;
    ; HL: x
    ; DE: y
    ; BC: counter
    ; IX: base pointer

    ex af, af' ; restore carry flag
    jr c, {+} ; do not zero if carry

    ; Set dest to zero
    push hl
    ld l, (ix + 8) \ ld h, (ix + 9)
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0
    pop hl

    +:
    ei ; enable interrupts down here to not mess up carry flag in f'

    push hl
    ; mul inc x and inc y by 4 (sizeof f32)
    ; inc x:
    ld l, (ix + 4) \ ld h, (ix + 5)
    add hl, hl \ add hl, hl
    ld (ix + 4), l \ ld (ix + 5), h

    ; inc y:
    ld l, (ix + 6) \ ld h, (ix + 7)
    add hl, hl \ add hl, hl
    ld (ix + 6), l \ ld (ix + 7), h

    pop hl

    ; Loop
    -:
        push bc ; {0}

        ; x * y -> buf
        push ix \ pop bc ; point bc to buf on stack

        push bc ; push ix, but bc = ix, so push bc is faster
        call f32mul
        pop ix

        push hl ; {1}
        push de ; {2}

        ; buf + dest -> dest
        push ix \ pop hl
        ld e, (ix + 8) \ ld d, (ix + 9)
        ld c, e \ ld b, d

        push hl ; push ix, but hl = ix
        call f32add
        pop ix

        pop de ; {2}
        pop hl ; {1}

        ; Increment x with inc x
        ld c, (ix + 4) \ ld b, (ix + 5)
        add hl, bc

        ; Increment y with inc y
        ld c, (ix + 6) \ ld b, (ix + 7)
        ex de, hl
        add hl, bc
        ex de, hl

        ; Loop logic
        pop bc ; {0}
        xor a
        dec bc
        or b
        jr nz, {-}
        or c
        jr nz, {-}

    ; Cleanup stack
    ld bc, 10
    add ix, bc
    ld sp, ix

    ret

#endif
