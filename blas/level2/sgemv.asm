#ifndef included_sgemv
#define included_sgemv

#include "misc/constants.asm"

#include "blas/level1/sdot.asm"
#include "blas/level1/sscal.asm"

#include "z80float_brass/f32/f32add.z80"
#include "z80float_brass/f32/f32mul.z80"
#include "z80float_brass/f32/f32cmp.z80"

; Inputs:
;   Carry flag: true -> trans; false -> not trans
;   stack 0   : m
;   stack 1   : n
;   stack 2   : alpha
;   HL        : A
;   IX        : lda
;   DE        : x
;   stack 3   : incx
;   stack 4   : beta
;   BC        : y
;   stack 5   : incy
sgemv:

    di \ exx
    ld hl, 1
    jr c, {+} ; if N
        ; inc row = lda
        ; inc col = 1
        push ix \ push hl
    jr {++} \ +: ; elseif T
        ; inc row = 1
        ; inc col = lda
        push hl \ push ix
    ++:
    exx \ ei

    push hl \ push hl ; Make buf space

    ld ix, 0
    add ix, sp

    ; Stack
    ;
    ; | buf     | <- (ix)
    ; | buf     |
    ; | inc col | <- (ix + 4)
    ; | inc row | <- (ix + 6)
    ; | ret     | <- (ix + 8)
    ; | incy    | <- (ix + 10)
    ; | beta    | <- (ix + 12)
    ; | incx    | <- (ix + 14)
    ; | alpha   | <- (ix + 16)
    ; | n       | <- (ix + 18)
    ; | m       | <- (ix + 20)

    ; Registers
    ;
    ; HL: A
    ; DE: x
    ; BC: y
    ; IX: base pointer

    ; If beta == 0, set y to zero, else multiply existing data with beta
    push hl \ push de \ push bc \ push ix

    ld l, (ix + 12) \ ld h, (ix + 13)
    ld de, zero_f32
    call f32cmp

    pop ix \ pop hl \ push hl ; hl -> y

    ; Common two first lines in both branches
    ex de, hl
    ld l, (ix + 20) \ ld h, (ix + 21)

    jr nz, {+} ; if beta == 0

        ; bc = 4 * m
        add hl, hl \ add hl, hl
        ld c, l \ ld b, h
        ex de, hl

        xor a

        ; set to 0 loop
        -:
            ld (hl), a
            inc hl

            dec bc
            or b
            jr nz, {-}
            or c
            jr nz, {-}

    jr {++} \ +: ; elseif beta != 0

        ; bc = m
        ld c, l \\ ld b, h
        push ix
        push hl
        ld l, (ix + 10) \ ld h, (ix + 11) ; HL -> beta
        push hl \ pop ix
        pop hl
        call sscal
        pop ix

    ++:

    pop bc \ pop de \ pop hl

    ; Implementing gemv as a series of dot between rows of A and x

    ; Loop over rows of A
    -:
        ; Dot row with x

        ; Save registers
        push hl \ push de \ push bc \ push ix

        ; TODO check that inc makes sense (I think I did the wrong one)

        push ix \ pop bc \ inc bc \ inc bc \ push bc ; dest = buf
        ld c, (ix + 14) \ ld b, (ix + 15) \ push bc ; incy(dot) = incx(here)
        ld c, (ix + 18) \ ld b, (ix + 19) ; n
        ; incx(dot) = inc row
        push hl \ ld l, (ix + 6) \ ld h, (ix + 7) \ push hl \ pop ix \ pop hl
        ; HL, DE already set
        or a ; overwrite location
        call sdot

        ; Restore ix
        pop ix

        ; mul buf by alpha and add to y

        ld l, (ix + 16) \ ld h, (ix + 17) ; hl -> alpha
        push ix \ pop de \ inc de \ inc de ; de -> buf
        ld c, e \ ld b, d ; bc -> buf
        push ix
        call f32mul
        pop ix

        ; restore bc = y
        pop bc

        push ix \ pop hl \ inc hl \ inc hl ; hl -> buf
        ld e, c \ ld d, b ; de -> y
        ; bc -> y (already set)
        push ix
        call f32add
        pop ix

        ; Restore hl, and move de one down
        pop hl \ ex (sp), hl

        ; Increment pointer to A by one row
        ; If not trans inc is 1, else inc is lda

        ex de, hl
        ld l, (ix + 4) \ ld h, (ix + 5)
        add hl, hl \ add hl, hl ; hl = inc col * 4
        add hl, de ; hl = A + 4 * inc col

        pop de

        ; Loop logic
        ld c, (ix + 20) \ ld b, (ix + 21)
        xor a
        dec bc
        ld (ix + 20), c \ ld (ix + 21), b
        or b
        jr nz, {-}
        or c
        jr nz, {-}

    ; Cleanup stack and return
    ld l, (ix + 8) \ ld h, (ix + 9) ; get return address
    ld bc, 22
    add ix, bc
    ld sp, ix ; make ix point top bottom of stack
    ex (sp), hl ; put return address at bottom of stack

    ret

#endif
