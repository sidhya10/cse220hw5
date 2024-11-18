.data
board:  .byte
    # 5 rows x 5 columns, showing a checkmark with 1s
    0, 0, 0, 0, 5,    # row 0 (top of checkmark)
    0, 0, 0, 4, 0,    # row 1
    1, 0, 3, 0, 0,    # row 2
    0, 2, 0, 0, 0,    # row 3
    0, 0, 0, 0, 0     # row 4

board_height: .word 5
board_width:  .word 5

.text
.globl main
# Function: main
main:
    # Print board
    jal zeroOut
    jal printBoard

debug_done:
    # Exit program
    li $v0, 10
    syscall


.data
.asciiz "This is Professor Benz's extra space that is being used for preserving memory contents to avoid losing data"
.include "hw5.asm"

