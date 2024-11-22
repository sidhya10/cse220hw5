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
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Load board dimensions
    lw $t0, board_width
    lw $t1, board_height
    
    # Check bounds first
    bltz $a0, out_of_bounds    # row < 0
    bge $a0, $t1, out_of_bounds  # row >= height
    bltz $a1, out_of_bounds    # col < 0
    bge $a1, $t0, out_of_bounds  # col >= width
    
    # Calculate offset: row * width + col
    mul $t1, $a0, $t0     # row * width
    add $t1, $t1, $a1     # + col
    la $t2, board         # board base address
    add $t2, $t2, $t1     # board + offset
    
    # Check if occupied
    lb $t4, 0($t2)       # Load current value
    bnez $t4, occupied    # If not zero, occupied error
    
    # Place tile
    sb $a2, 0($t2)       # Set new value
    li $v0, 0            # success
    j place_tile_done

occupied:
    li $v0, 1            # occupied error
    j place_tile_done

out_of_bounds:
    li $v0, 2            # out of bounds error

place_tile_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

T_orientation4:
    # Preserve $ra
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t0, 0($sp)     
    
    # Place anchor point
    move $a0, $s5      # row from s5 
    move $a1, $s6      # col from s6 
    move $a2, $s1      # ship number
    jal place_tile
    or $s2, $s2, $v0   # Accumulate error
    
    # Place left tile (one below, one left)
    addi $a0, $s5, 1   # row + 1
    addi $a1, $s6, -1  # col - 1 
    move $a2, $s1      
    jal place_tile
    or $s2, $s2, $v0   
    
    # Place right tile (one below, one right)
    addi $a0, $s5, 1   # row + 1
    addi $a1, $s6, 1   # col + 1
    move $a2, $s1      
    jal place_tile
    or $s2, $s2, $v0
    
    # Place bottom tile (two below, center)
    addi $a0, $s5, 2   # row + 2
    move $a1, $s6      # same col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    
    # Restore and return to piece_return
    lw $ra, 4($sp)
    lw $t0, 0($sp)
    addi $sp, $sp, 8
    j piece_return     # Return through placePieceOnBoard's error handling

placePieceOnBoard:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp) 
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
    move $s0, $a0      # piece struct pointer
    move $s1, $a1      # ship num
    
    # Load piece data into registers expected by piece handlers
    lw $t0, 0($s0)     # type
    lw $s4, 4($s0)     # orientation -> $s4
    lw $s5, 8($s0)     # row -> $s5
    lw $s6, 12($s0)    # col -> $s6
    
    # Validate type and orientation
    li $t1, 1
    li $t2, 7
    blt $t0, $t1, invalid_piece
    bgt $t0, $t2, invalid_piece
    li $t1, 1
    li $t2, 4  
    blt $s4, $t1, invalid_piece
    bgt $s4, $t2, invalid_piece
    
    # Initialize error tracker for piece handlers
    li $s2, 0          
    
    # Place anchor tile
    move $a0, $s5      # row
    move $a1, $s6      # col
    move $a2, $s1      # ship num
    jal place_tile
    beqz $v0, continue_piece  # Only continue if anchor succeeds
    move $s2, $v0      # Save error and cleanup
    j cleanup

continue_piece:
    # Branch to appropriate piece handler
    li $t1, 1
    beq $t0, $t1, piece_square
    li $t1, 2
    beq $t0, $t1, piece_line
    li $t1, 3
    beq $t0, $t1, piece_reverse_z 
    li $t1, 4
    beq $t0, $t1, piece_L
    li $t1, 5
    beq $t0, $t1, piece_z
    li $t1, 6
    beq $t0, $t1, piece_reverse_L
    j piece_T
    
piece_return:
    bnez $s2, cleanup  # If any errors occurred, clean up board
    j piece_done      # Otherwise we're done
    
cleanup:
    jal zeroOut       # Clear the board
    move $v0, $s2     # Return accumulated error code
    j piece_done

invalid_piece:
    li $v0, 4
    j piece_done
    
piece_done:
    lw $ra, 28($sp)
    lw $s0, 24($sp) 
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addi $sp, $sp, 32
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
    li $s2, 0          # error code
    
    # Clear board initially
    jal zeroOut

test_loop:
    # Calculate piece address
    li $t0, 16
    mul $t0, $t0, $s1
    add $s3, $s0, $t0
    
    # Load piece data
    lw $t1, 0($s3)     # type
    lw $t2, 4($s3)     # orientation
    
    # Validate piece type (1-7)
    li $t3, 1
    blt $t1, $t3, invalid_fit_type
    li $t3, 7
    bgt $t1, $t3, invalid_fit_type
    
    # Validate orientation (1-4)
    li $t3, 1
    blt $t2, $t3, invalid_fit_type
    li $t3, 4
    bgt $t2, $t3, invalid_fit_type

    # Try placing piece
    move $a0, $s3
    addi $a1, $s1, 1
    jal placePieceOnBoard
    
    # Keep highest error code
    blt $v0, $s2, continue_fit_test
    move $s2, $v0
    
continue_fit_test:
    addi $s1, $s1, 1
    li $t0, 5          # Only test first 5 pieces
    bge $s1, $t0, test_done
    j test_loop

invalid_fit_type:
    li $v0, 4
    j test_fit_done

test_done:
    move $v0, $s2

test_fit_done:
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

.include "skeleton.asm"