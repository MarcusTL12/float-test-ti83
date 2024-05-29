#ifndef included_sgemv
#define included_sgemv

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

    ; Stack on entry
    ;
    ; | m     | <- (ix + 16)
    ; | n     | <- (ix + 14)
    ; | alpha | <- (ix + 12)
    ; | ret   | <- (ix + 10)
    ; | incx  | <- (ix + 8)
    ; | beta  | <- (ix + 6)
    ; | incy  | <- (ix + 4)
    ; | lda   | <- (ix + 2)
    ; | ret   | <- (ix)

    ld ix, 0

    ; Cleanup stack and return
    pop hl ; get return address
    ld bc, 16
    add ix, bc
    ld sp, ix ; make ix point top bottom of stack
    ex (sp), hl ; put return address at bottom of stack

    ret

#endif
