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
    push af

    ld ix, 0
    add ix, sp

    ; Stack
    ;
    ; | N/T   | <- (ix)
    ; | ret   | <- (ix + 2)
    ; | lda   | <- (ix + 4)
    ; | incy  | <- (ix + 6)
    ; | beta  | <- (ix + 8)
    ; | incx  | <- (ix + 10)
    ; | ret   | <- (ix + 12)
    ; | alpha | <- (ix + 14)
    ; | n     | <- (ix + 16)
    ; | m     | <- (ix + 18)

    ; Registers
    ;
    ; HL: A
    ; DE: x
    ; BC: y
    ; IX: base pointer

    ; If beta == 0, set y to zero, else multiply existing data with beta
    push hl \ push de \ push bc \ push ix

    ld l, (ix + 8) \ ld h, (ix + 9)
    ld de, zero_f32
    call f32cmp

    pop ix \ pop hl \ push hl ; hl -> y

    jr nz, {+} ; if beta == 0

        ; set to 0 loop
        -:


    jr {++} \ +: ; elseif beta != 0


        call sscal

    ++:

    pop bc \ pop de \ pop hl

    ; Implementing gemv as a series of dot between rows of A and x

    ; Loop over rows of A
    -:
        ; Dot row with x

        ; Save registers
        push hl \ push de \ push bc \ push ix

        push bc ; dest
        ld c, (ix + 6) \ ld b, (ix + 7) \ push bc ; incy
        ld c, (ix + 16) \ ld b, (ix + 17) ; n
        push hl \ ld l, (ix + 10) \ ld h, (ix + 11)
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
            ld e, (ix + 4) \ ld d, (ix + 5)
        ++:
        add hl, de
        pop de

        ; Loop logic
        ld c, (ix + 18) \ ld b, (ix + 19)
        xor a
        dec bc
        ld (ix + 18), c \ ld (ix + 19), b
        or b
        jr nz, {-}
        or c
        jr nz, {-}

    ; Cleanup stack and return
    pop hl \ pop hl ; get return address
    ld bc, 14
    add ix, bc
    ld sp, ix ; make ix point top bottom of stack
    ex (sp), hl ; put return address at bottom of stack

    ret

#endif
