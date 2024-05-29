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
;   stack 1:    increment y
saxpy:
    ; Get stuff out of stack
    di
    exx
    pop hl ; get return address
    pop de ; inc y
    ex (sp), hl ; swap a with ret
    push hl
    push de
    push ix ; inc x
    exx
    ei

    ; Make space for f32 buffer on stack
    push hl
    push hl

    ; point ix to top of stack
    ld ix, 0
    add ix, sp

    ; Stack variables:
    ;
    ; | buf      | <- (ix)
    ; | buf      |
    ; | inc x    | <- (ix + 4)
    ; | inc y    | <- (ix + 6)
    ; | scalar a | <- (ix + 8)
    ; | ret      | <- (ix + 10)

    ; Register variables:
    ;
    ; HL: x
    ; DE: y
    ; BC: counter
    ; IX: base pointer

    push hl ; {0} Save pointer to x

    ; mul inc x and inc y by 4 (sizeof f32)
    ; inc x:
    ld l, (ix + 4) \ ld h, (ix + 5)
    add hl, hl \ add hl, hl
    ld (ix + 4), l \ ld (ix + 5), h

    ; inc y:
    ld l, (ix + 6) \ ld h, (ix + 7)
    add hl, hl \ add hl, hl
    ld (ix + 6), l \ ld (ix + 7), h

    pop hl ; {0} restore x

    ; Loop
    -:
        push bc ; {0}
        push de ; {1} y


        ; Perform mul x * a -> buf

        ; Load pointer to scalar a into de
        ld e, (ix + 8) \ ld d, (ix + 9)

        push ix \ pop bc ; point bc to buf on stack

        push ix
        call f32mul
        pop ix


        pop de ; {1} y
        push hl ; {1} x


        ; Perform add buf + y -> y
        push ix \ pop hl
        ld b, d \ ld c, e ; bc = de
        push ix
        call f32add
        pop ix


        pop hl ; {1} x


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

    ; Cleanup with pop (10 * N = 50 cc)
    ; pop af \ pop af \ pop af \ pop af \ pop af

    ; Cleanup with math (10 + 15 + 10 = 35 cc)
    ; Use this for 4 or more things on stack
    ld bc, 10
    add ix, bc
    ld sp, ix

    ret

#endif
