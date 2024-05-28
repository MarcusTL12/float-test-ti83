#include "../header.asm"

title:
    .db "test float",0

main:
    bcall(_clrscrf)
    bcall(_homeup)
    ld hl, title
    bcall(_puts)
    bcall(_newline)

    ld hl, test_data
    bcall(_puts)
    bcall(_newline)

    bcall(_getkey) ; Pause
    ret

test_data:
    .db "yrokpstylc",0

#include "z80float_relative/conversion/atof32.z80"
