.data
space: .asciiz " "    
newline: .asciiz "\n" 
extra_newline: .asciiz "\n\n"

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 

zeroOut:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    la $s0, board
    lw $s1, board_width
    lw $s2, board_height
    li $s3, 0  

zero_row_loop:
    li $t0, 0  
zero_col_loop:
    mul $t1, $s3, $s1
    add $t1, $t1, $t0
    add $t1, $t1, $s0
    sb $zero, 0($t1)
    
    addi $t0, $t0, 1
    blt $t0, $s1, zero_col_loop
    
    addi $s3, $s3, 1
    blt $s3, $s2, zero_row_loop

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

printBoard:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    la $s0, board
    lw $s1, board_width
    lw $s2, board_height
    li $s3, 0  

print_row_loop:
    li $t0, 0  
print_col_loop:
    mul $t1, $s3, $s1
    add $t1, $t1, $t0
    add $t1, $t1, $s0
    
    lb $a0, 0($t1)
    li $v0, 1
    syscall
    
    addi $t2, $t0, 1
    beq $t2, $s1, skip_space
    la $a0, space
    li $v0, 4
    syscall
skip_space:    
    addi $t0, $t0, 1
    blt $t0, $s1, print_col_loop
    
    la $a0, newline
    li $v0, 4
    syscall
    
    addi $s3, $s3, 1
    blt $s3, $s2, print_row_loop

    la $a0, newline
    li $v0, 4
    syscall

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

place_tile:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    # Check bounds first
    lw $t0, board_width
    lw $t1, board_height
    
    bltz $a0, out_of_bounds    # row < 0
    bge $a0, $t1, out_of_bounds # row >= height
    bltz $a1, out_of_bounds    # col < 0
    bge $a1, $t0, out_of_bounds # col >= width
    
    # Calculate offset correctly
    mul $t1, $a0, $t0    # row * width
    add $t1, $t1, $a1    # + col
    la $t2, board        # load board base
    add $t2, $t2, $t1    # add offset
    
    # Check if occupied
    lb $t4, 0($t2)
    bnez $t4, occupied
    
    # Place tile
    sb $a2, 0($t2)
    li $v0, 0
    j place_tile_done

out_of_bounds:
    li $v0, 2
    j place_tile_done

occupied:
    li $v0, 1

place_tile_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

placePieceOnBoard:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)
    
    move $s0, $a0  # piece struct
    move $s1, $a1  # ship num
    
    lw $s2, 0($s0)  # type
    lw $s3, 4($s0)  # orientation 
    lw $s4, 8($s0)  # row
    lw $s5, 12($s0) # col
    
    # Validate type and orientation
    li $t0, 1
    li $t1, 7
    blt $s2, $t0, invalid_piece
    bgt $s2, $t1, invalid_piece
    li $t0, 1
    li $t1, 4
    blt $s3, $t0, invalid_piece
    bgt $s3, $t1, invalid_piece
    
    # Place anchor point
    move $a0, $s4
    move $a1, $s5
    move $a2, $s1
    jal place_tile
    bnez $v0, cleanup_and_return

    # Save original coordinates
    move $t8, $s4  # Save original row
    move $t9, $s5  # Save original col
    
    # Branch to piece type handlers
    li $t0, 1
    beq $s2, $t0, piece_square
    li $t0, 2
    beq $s2, $t0, piece_line
    li $t0, 3
    beq $s2, $t0, piece_reverse_z
    li $t0, 4
    beq $s2, $t0, piece_L
    li $t0, 5
    beq $s2, $t0, piece_z
    li $t0, 6
    beq $s2, $t0, piece_reverse_L
    li $t0, 7
    beq $s2, $t0, piece_T
    
    j piece_done

invalid_piece:
    li $v0, 4
    j piece_done

cleanup_and_return:
    move $s2, $v0  # Save error code
    jal zeroOut    # Clear board
    move $v0, $s2  # Restore error code
    j piece_done

piece_done:
    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    lw $s5, 0($sp)
    addi $sp, $sp, 28
    jr $ra

test_fit:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0  # piece array
    li $s1, 0      # piece counter
    li $s2, 0      # max error seen
    
test_loop:
    # Calculate piece address
    li $t0, 16
    mul $t0, $t0, $s1
    add $s3, $s0, $t0
    
    # Load and validate piece data
    lw $t1, 0($s3)  # type
    lw $t2, 4($s3)  # orientation
    
    # Validate type and orientation
    li $t3, 1
    li $t4, 7
    blt $t1, $t3, invalid_fit_type
    bgt $t1, $t4, invalid_fit_type
    li $t3, 1
    li $t4, 4
    blt $t2, $t3, invalid_fit_type
    bgt $t2, $t4, invalid_fit_type
    
    # Clear board before placing piece
    jal zeroOut
    
    # Try placing piece
    move $a0, $s3
    addi $a1, $s1, 1
    jal placePieceOnBoard
    
    # Update max error if needed
    bgt $v0, $s2, update_max
    j continue_fit_test

invalid_fit_type:
    li $v0, 4
    j test_fit_done
    
update_max:
    move $s2, $v0
    
continue_fit_test:
    addi $s1, $s1, 1
    li $t0, 5
    blt $s1, $t0, test_loop
    
    move $v0, $s2
    
test_fit_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

T_orientation4:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Restore original coordinates
    move $a0, $s4
    move $a1, $s5
    
    # Place tile left
    addi $a1, $a1, -1
    addi $a0, $a0, 1
    jal place_tile
    bnez $v0, t4_fail
    
    # Place tile right
    addi $a1, $a1, 2
    jal place_tile
    bnez $v0, t4_fail
    
    # Place tile bottom
    addi $a1, $a1, -1
    addi $a0, $a0, 1
    jal place_tile
    bnez $v0, t4_fail
    
    li $v0, 0
    j t4_done
    
t4_fail:
    # Error code already in $v0
    
t4_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j piece_done

.include "skeleton.asm"