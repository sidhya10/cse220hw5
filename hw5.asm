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
    
    lb $a0, 0($t1)
    li $v0, 1
    syscall
    
    addi $t2, $t0, 1
    beq $t2, $s1, skip_space
    li $a0, 32          
    li $v0, 11          
    syscall
skip_space:    
    addi $t0, $t0, 1
    blt $t0, $s1, print_col_loop
    
    li $a0, 10          
    li $v0, 11          
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

place_tile:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, board_width
    lw $t1, board_height
    
    # Check bounds first
    bltz $a0, out_of_bounds    
    bge $a0, $t1, out_of_bounds  
    bltz $a1, out_of_bounds    
    bge $a1, $t0, out_of_bounds  

    # Calculate position
    mul $t1, $a0, $t0     
    add $t1, $t1, $a1     
    la $t2, board         
    add $t2, $t2, $t1     

    # Check if occupied after bounds check
    lb $t4, 0($t2)       
    bnez $t4, occupied  

    # Place if empty
    sb $a2, 0($t2)       
    li $v0, 0            
    j place_tile_done

occupied:
    li $v0, 1            
    j place_tile_done

out_of_bounds:
    li $v0, 2            

place_tile_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

T_orientation4:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t0, 0($sp)     
    
    # Place anchor but add 1 to row to match the row alignment of other pieces
    addi $a0, $s5, 1    # Add 1 to row to align with other pieces
    move $a1, $s6      
    move $a2, $s1      
    jal place_tile    
    or $s2, $s2, $v0
    bnez $v0, check_error
    
    # Up tile 
    move $a0, $s5        # Now this will be at the original intended row
    move $a1, $s6        # Same column as anchor
    jal place_tile
    or $s2, $s2, $v0   
    bnez $v0, check_error

    # Right tile
    addi $a0, $s5, 1     # Same row as anchor
    addi $a1, $s6, 1     # One column right
    jal place_tile
    or $s2, $s2, $v0
    bnez $v0, check_error

    # Down tile
    addi $a0, $s5, 2     # One row down from anchor
    move $a1, $s6        # Same column as anchor
    jal place_tile
    or $s2, $s2, $v0
    bnez $v0, check_error

check_error:
    bnez $s2, clear_and_return   
    j finish_t4

clear_and_return:
    jal zeroOut                  
    
finish_t4:
    lw $ra, 4($sp)
    lw $t0, 0($sp)
    addi $sp, $sp, 8
    j piece_return

placePieceOnBoard:
    # Save registers
    addi $sp, $sp, -12        
    sw $ra, 8($sp)
    sw $s2, 4($sp)
    sw $s1, 0($sp)           

    # Load piece data into appropriate registers
    lw $t0, 0($a0)           # piece type
    lw $s4, 4($a0)           # orientation
    lw $s5, 8($a0)           # row
    lw $s6, 12($a0)          # col
    move $s1, $a1            # ship_num
    
    # Initialize error accumulator
    li $s2, 0
    
    # Validate type/orientation and branch to invalid_piece if invalid
    li $t1, 1
    blt $t0, $t1, invalid_piece
    li $t1, 7
    bgt $t0, $t1, invalid_piece
    li $t1, 1
    blt $s4, $t1, invalid_piece
    li $t1, 4  
    bgt $s4, $t1, invalid_piece
    
    # Branch to appropriate piece handler based on type
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
    j piece_T               # If none of the above, must be piece_T

invalid_piece:
    jal zeroOut            # Clear board on invalid piece
    li $v0, 2              # Return 2 for out of bounds
    j piece_done

piece_done:
piece_return:
    beqz $s2, success      # If no errors, go to success
    
    # Clear board immediately on any error
    jal zeroOut           
    
    # Handle different error cases
    li $t0, 1
    beq $s2, $t0, occupied_error
    li $t0, 2
    beq $s2, $t0, bounds_error
    li $t0, 3 
    beq $s2, $t0, both_error
    j success

occupied_error:
    li $v0, 1              # Return 1 for occupied
    # Restore registers and return
    lw $ra, 8($sp)
    lw $s2, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

bounds_error:
    li $v0, 2              # Return 2 for out of bounds
    # Restore registers and return
    lw $ra, 8($sp)
    lw $s2, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

both_error:
    li $v0, 3              # Return 3 for both types of errors
    # Restore registers and return
    lw $ra, 8($sp)
    lw $s2, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

success:
    li $v0, 0              # Return 0 for success
    # Restore registers and return
    lw $ra, 8($sp)
    lw $s2, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra

test_fit:
    # Save registers that we'll use
    addi $sp, $sp, -28    
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)        # Added s5 for attempt counter
    
    move $s0, $a0         # Save piece array pointer
    li $s1, 0             # Initialize piece counter
    li $s5, 0             # Initialize attempt counter
    
    # First validate ALL pieces before attempting placement
validate_loop:
    # Get current piece
    li $t0, 16            # Each piece struct is 16 bytes
    mul $t0, $t0, $s1     # Calculate offset for current piece
    add $s3, $s0, $t0     # Get address of current piece
    
    # Validate piece type and orientation
    lw $t1, 0($s3)        # Load piece type
    lw $t2, 4($s3)        # Load piece orientation
    
    # Check type bounds (1-7)
    li $t3, 1
    blt $t1, $t3, invalid_piece_type
    li $t3, 7
    bgt $t1, $t3, invalid_piece_type
    
    # Check orientation bounds (1-4)
    li $t3, 1
    blt $t2, $t3, invalid_piece_type
    li $t3, 4
    bgt $t2, $t3, invalid_piece_type
    
    # Continue validation for all pieces
    addi $s1, $s1, 1
    li $t0, 5
    blt $s1, $t0, validate_loop
    
    # If we get here, all pieces are valid - proceed with placement
    li $s1, 0             # Reset piece counter
    li $s2, 0             # Initialize max error
    jal zeroOut           # Clear board

test_loop:
    # Check if we've tried too many times
    li $t0, 5
    bge $s5, $t0, test_done
    
    # Get current piece
    li $t0, 16
    mul $t0, $t0, $s1
    add $s3, $s0, $t0
    
    # Try to place the piece
    move $a0, $s3
    addi $a1, $s1, 1
    jal placePieceOnBoard
    
    # If placement failed
    bnez $v0, handle_error
    
    # If successful, continue to next piece
    addi $s1, $s1, 1
    li $t0, 5
    blt $s1, $t0, test_loop
    j test_done

handle_error:
    # Update max error if new error is worse
    bgt $v0, $s2, update_max_error
    j retry_placement

update_max_error:
    move $s2, $v0         # Update max error

retry_placement:
    jal zeroOut           # Clear board
    li $s1, 0             # Reset to first piece
    addi $s5, $s5, 1      # Increment attempt counter
    j test_loop

invalid_piece_type:
    jal zeroOut           # Ensure board is clear
    li $v0, 4             # Invalid type/orientation error
    j test_fit_done

test_done:
    move $v0, $s2         # Return worst error encountered
    jal zeroOut           # Ensure board is cleared before returning

test_fit_done:
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

.include "skeleton.asm"