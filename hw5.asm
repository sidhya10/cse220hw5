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
    li $s3, 0           # row counter

print_row_loop:
    li $t0, 0           # column counter
print_col_loop:
    mul $t1, $s3, $s1
    add $t1, $t1, $t0
    add $t1, $t1, $s0
    
    # Print current number
    lb $a0, 0($t1)
    li $v0, 1
    syscall
    
    # Only print space if not last column
    addi $t2, $t0, 1
    beq $t2, $s1, skip_space
    li $a0, 32          # ASCII space
    li $v0, 11          # print char
    syscall
skip_space:    
    addi $t0, $t0, 1
    blt $t0, $s1, print_col_loop
    
    # Print newline after each row
    li $a0, 10          # ASCII newline
    li $v0, 11          # print char
    syscall
    
    addi $s3, $s3, 1
    blt $s3, $s2, print_row_loop

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra
    
print_row_done:    
    addi $s3, $s3, 1
    blt $s3, $s2, print_row_loop

    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

zeroOut:
    # Preserve registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    la $s0, board        # board base address
    lw $s1, board_width  # width
    lw $s2, board_height # height
    li $s3, 0           # row counter

zero_row_loop:
    li $t0, 0           # column counter
zero_col_loop:
    # Calculate offset: row * width + col
    mul $t1, $s3, $s1
    add $t1, $t1, $t0
    add $t1, $t1, $s0
    sb $zero, 0($t1)    # Set cell to 0
    
    addi $t0, $t0, 1
    blt $t0, $s1, zero_col_loop
    
    addi $s3, $s3, 1
    blt $s3, $s2, zero_row_loop

    # Restore registers
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

    # Load board dimensions
    lw $t0, board_width
    lw $t1, board_height
    
    # Check row bounds (a0)
    bltz $a0, out_of_bounds    # row < 0
    bge $a0, $t1, out_of_bounds  # row >= height
    
    # Check column bounds (a1)
    bltz $a1, out_of_bounds    # col < 0
    bge $a1, $t0, out_of_bounds  # col >= width
    
    # Calculate offset: row * width + col
    mul $t1, $a0, $t0     # row * width
    add $t1, $t1, $a1     # + col
    la $t2, board         # board base address
    add $t2, $t2, $t1     # board + offset
    
    # Check if occupied
    lb $t4, 0($t2)
    bnez $t4, occupied    # if cell != 0, occupied
    
    # Place tile
    sb $a2, 0($t2)       # board[offset] = value
    li $v0, 0            # return success
    j place_tile_done

out_of_bounds:
    li $v0, 2            # return out of bounds error
    j place_tile_done

occupied:
    li $v0, 1            # return occupied error

place_tile_done:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

T_orientation4:
    # Preserve $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Restore anchor coordinates
    move $a0, $s4  # row
    move $a1, $s5  # col
    
    # Place left tile (one below, one left)
    addi $a0, $a0, 1   # row + 1
    addi $a1, $a1, -1  # col - 1
    move $a2, $s1      # ship number
    jal place_tile
    bnez $v0, t4_fail
    
    # Place right tile (one below, one right of anchor)
    addi $a1, $a1, 2   # col + 2
    jal place_tile
    bnez $v0, t4_fail
    
    # Place bottom tile (two below, center)
    addi $a0, $a0, 1   # row + 1
    addi $a1, $a1, -1  # col - 1
    jal place_tile
    bnez $v0, t4_fail
    
    # Success
    li $v0, 0
    j t4_done
    
t4_fail:
    # Error code already in $v0
    
t4_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j piece_done

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
    
    # Load piece data
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
    
    # Check if anchor placement failed
    bnez $v0, cleanup_and_return

    # Branch to piece type handlers based on type and orientation
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
    
    move $s0, $a0      # piece array
    li $s1, 0          # current piece index
    li $s2, 0          # max error code

test_loop:
    # Calculate current piece address
    li $t0, 16         # Each piece struct is 16 bytes
    mul $t0, $t0, $s1  # offset = index * 16
    add $s3, $s0, $t0  # current piece address
    
    # Load piece type and orientation
    lw $t1, 0($s3)     # type
    lw $t2, 4($s3)     # orientation
    
    # Validate type (1-7)
    li $t3, 1
    blt $t1, $t3, invalid_fit_type
    li $t3, 7
    bgt $t1, $t3, invalid_fit_type
    
    # Validate orientation (1-4)
    li $t3, 1
    blt $t2, $t3, invalid_fit_type
    li $t3, 4
    bgt $t2, $t3, invalid_fit_type

    # Clear board before testing piece
    jal zeroOut
    
    # Try placing piece
    move $a0, $s3
    addi $a1, $s1, 1   # Ship number is index + 1
    jal placePieceOnBoard
    
    # Update max error if needed
    ble $v0, $s2, continue_fit_test
    move $s2, $v0

continue_fit_test:
    addi $s1, $s1, 1
    li $t0, 5          # Test all 5 pieces
    blt $s1, $t0, test_loop
    
    # Return max error code
    move $v0, $s2
    j test_fit_done

invalid_fit_type:
    li $v0, 4          # Invalid type/orientation error

test_fit_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

.include "skeleton.asm"