.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 

# Function: zeroOut
zeroOut:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    # Load globals
    la $s0, board
    lw $s1, board_width
    lw $s2, board_height
    li $s3, 0  # row counter

zero_row_loop:
    li $t0, 0  # col counter
zero_col_loop:
    # Calculate offset: row * width + col
    mul $t1, $s3, $s1
    add $t1, $t1, $t0
    add $t1, $t1, $s0
    sb $zero, ($t1)  # store zero
    
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
    
zero_done:
    jr $ra

# Function: printBoard
printBoard:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    la $s0, board
    lw $s1, board_width
    lw $s2, board_height
    li $s3, 0  # row counter

print_row_loop:
    li $t0, 0  # col counter
print_col_loop:
    # Calculate offset
    mul $t1, $s3, $s1
    add $t1, $t1, $t0
    add $t1, $t1, $s0
    
    # Print number
    lb $a0, ($t1)
    li $v0, 1
    syscall
    
    # Print space
    la $a0, space
    li $v0, 4
    syscall
    
    addi $t0, $t0, 1
    blt $t0, $s1, print_col_loop
    
    # Print newline
    la $a0, newline
    li $v0, 4
    syscall
    
    addi $s3, $s3, 1
    blt $s3, $s2, print_row_loop

    # Print extra newline at end
    la $a0, extra_newline
    li $v0, 4
    syscall

    # Restore registers
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

# Function: place_tile
place_tile:
    # Save registers
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    # Load board dimensions
    lw $t0, board_width
    lw $t1, board_height
    
    # Check bounds
    bltz $a0, out_of_bounds    # row < 0
    bge $a0, $t1, out_of_bounds # row >= height
    bltz $a1, out_of_bounds    # col < 0
    bge $a1, $t0, out_of_bounds # col >= width
    
    # Calculate offset
    la $t2, board
    mul $t3, $a0, $t0
    add $t3, $t3, $a1
    add $t2, $t2, $t3
    
    # Check if occupied
    lb $t4, ($t2)
    bnez $t4, occupied
    
    # Place tile
    sb $a2, ($t2)
    li $v0, 0
    j place_tile_done
    
out_of_bounds:
    li $v0, 2
    j place_tile_done
    
occupied:
    li $v0, 1
    
place_tile_done:
    # Restore registers
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

# Function: placePieceOnBoard
placePieceOnBoard:
    # Save registers
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

    # First switch on type
    li $t0, 1
    beq $s3, $t0, piece_square
    li $t0, 2
    beq $s3, $t0, piece_line
    li $t0, 3
    beq $s3, $t0, piece_reverse_z
    li $t0, 4
    beq $s3, $t0, piece_L
    li $t0, 5
    beq $s3, $t0, piece_z
    li $t0, 6
    beq $s3, $t0, piece_reverse_L
    li $t0, 7
    beq $s3, $t0, piece_T

piece_done:
    # Restore registers
    lw $ra, 24($sp)
    lw $s0, 20($sp)
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    lw $s5, 0($sp)
    addi $sp, $sp, 28
    jr $ra

# Function: test_fit
test_fit:
    # Save registers
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
    li $t0, 16     # size of piece struct
    mul $t0, $t0, $s1
    add $s3, $s0, $t0
    
    # Load piece type and orientation
    lw $t1, 0($s3)  # type
    lw $t2, 4($s3)  # orientation
    
    # Validate type and orientation
    li $t3, 1
    li $t4, 7
    blt $t1, $t3, invalid_type
    bgt $t1, $t4, invalid_type
    li $t3, 1
    li $t4, 4
    blt $t2, $t3, invalid_type
    bgt $t2, $t4, invalid_type
    j piece_valid
    
invalid_type:
    li $v0, 4
    j test_fit_done
    
piece_valid:
    # Try placing piece
    move $a0, $s3
    addi $a1, $s1, 1
    jal placePieceOnBoard
    
    # Track highest error
    bgt $v0, $s2, update_max
    j continue_test
    
update_max:
    move $s2, $v0
    
continue_test:
    addi $s1, $s1, 1
    li $t0, 5
    blt $s1, $t0, test_loop
    
    # Return highest error
    move $v0, $s2
    
test_fit_done:
    # Restore registers
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

T_orientation4:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Place center tile already done by caller
    
    # Place left tile
    addi $a1, $a1, -1  # col - 1
    addi $a0, $a0, 1   # row + 1
    jal place_tile
    bnez $v0, t4_fail
    
    # Place right tile
    addi $a1, $a1, 2   # col + 2
    jal place_tile
    bnez $v0, t4_fail
    
    # Place bottom tile
    addi $a1, $a1, -1  # col - 1
    addi $a0, $a0, 1   # row + 2
    jal place_tile
    bnez $v0, t4_fail
    
    li $v0, 0
    j t4_done
    
t4_fail:
    # Keep error code from place_tile
    
t4_done:
    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j piece_done

.include "skeleton.asm"