#ifndef included_sgemv
#define included_sgemv

#include "misc/constants.asm"

#include "blas/level1/sdot.asm"
#include "blas/level1/sscal.asm"

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

    ex (sp), ix
    push ix
    push hl \ push hl
    push af

    ld ix, 0
    add ix, sp

    ; Stack
    ;
    ; | N/T   | <- (ix)
    ; | buf   | <- (ix + 2)
    ; | buf   |
    ; | ret   | <- (ix + 6)
    ; | lda   | <- (ix + 8)
    ; | incy  | <- (ix + 10)
    ; | beta  | <- (ix + 12)
    ; | incx  | <- (ix + 14)
    ; | alpha | <- (ix + 16)
    ; | n     | <- (ix + 18)
    ; | m     | <- (ix + 20)

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

        push bc ; dest
        ld c, (ix + 10) \ ld b, (ix + 11) \ push bc ; incy
        ld c, (ix + 18) \ ld b, (ix + 19) ; n
        push hl \ ld l, (ix + 14) \ ld h, (ix + 15)
        push hl \ pop ix \ pop hl ; incx
        ; HL, DE already set
        scf ; Add to location
        call sdot

        ; Restore registers
        pop ix \ pop bc \ pop de \ pop hl

        ; Increment pointer to A by one row
        ; If not trans inc is sizeof(f32), else inc is lda

        pop af \ push af ; get carry flag for N/T
        push de
        jr c, {+} ; if N
            ld de, 4
        jr {++} \ +: ; elseif T
            ld e, (ix + 8) \ ld d, (ix + 9)
        ++:
        add hl, de
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
    pop hl \ pop hl ; get return address
    ld bc, 16
    add ix, bc
    ld sp, ix ; make ix point top bottom of stack
    ex (sp), hl ; put return address at bottom of stack

    ret

#endif
