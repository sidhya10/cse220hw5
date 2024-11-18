.data
board_height: .word 10
board_width:  .word 15
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
.asciiz "This is Professor Benz's extra space that is being used for preserving memory contents to avoid losing data"
ship:  .word
2, 1, 1, 6
ship2:  .word
3, 2, 3, 2
ship3:  .word
4, 3, 5, 4
ship4:  .word
5, 3, 7, 8
ship5:  .word
6, 2, 5, 12
ship6:  .word
1, 1, 3, 8

.text
.globl main
# Function: main
main:
    la $a0 ship
    li $a1 1

    jal placePieceOnBoard

    move $a0, $v0         # Load int to print
    li $v0, 1            # syscall: print int
    syscall
    li $v0, 4             # syscall: print string
    la $a0, newline       # Load newline string
    syscall

    jal printBoard
    
    la $a0 ship2
    li $a1 2

    jal placePieceOnBoard

    move $a0, $v0         # Load int to print
    li $v0, 1            # syscall: print int
    syscall
    li $v0, 4             # syscall: print string
    la $a0, newline       # Load newline string
    syscall

    jal printBoard
    
    la $a0 ship3
    li $a1 3

    jal placePieceOnBoard

    move $a0, $v0         # Load int to print
    li $v0, 1            # syscall: print int
    syscall
    li $v0, 4             # syscall: print string
    la $a0, newline       # Load newline string
    syscall

    jal printBoard

    la $a0 ship4
    li $a1 4

    jal placePieceOnBoard

    move $a0, $v0         # Load int to print
    li $v0, 1            # syscall: print int
    syscall
    li $v0, 4             # syscall: print string
    la $a0, newline       # Load newline string
    syscall

    jal printBoard

    la $a0 ship5
    li $a1 5

    jal placePieceOnBoard

    move $a0, $v0         # Load int to print
    li $v0, 1            # syscall: print int
    syscall
    li $v0, 4             # syscall: print string
    la $a0, newline       # Load newline string
    syscall

    jal printBoard

    la $a0 ship6
    li $a1 6

    jal placePieceOnBoard

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

