.data
board_height: .word 10
board_width:  .word 10
board:  .byte
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text
.globl main
# Function: main
main:
    li $a0 3
    li $a1 3
    li $a2 7

    jal place_tile

    move $a0, $v0         # Load int to print
    li $v0, 1            # syscall: print int
    syscall
    
    li $v0, 4             # syscall: print string
    la $a0, newline       # Load newline string
    syscall

    jal printBoard

debug_done:
    # Exit program
    li $v0, 10
    syscall


.data
.asciiz "This is Professor Benz's extra space that is being used for preserving memory contents to avoid losing data"
.include "hw5.asm"

