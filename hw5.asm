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
    
    # Place anchor
    move $a0, $s5      
    move $a1, $s6      
    move $a2, $s1      
    jal place_tile    
    or $s2, $s2, $v0   
    
    # Try placing all tiles regardless of anchor error
    # Left tile
    addi $a0, $s5, 1   
    addi $a1, $s6, -1  
    jal place_tile
    or $s2, $s2, $v0   
    
    # Right tile
    addi $a0, $s5, 1   
    addi $a1, $s6, 1   
    jal place_tile
    or $s2, $s2, $v0
    
    # Bottom tile
    addi $a0, $s5, 2   
    move $a1, $s6      
    jal place_tile
    or $s2, $s2, $v0

    lw $ra, 4($sp)
    lw $t0, 0($sp)
    addi $sp, $sp, 8
    j piece_return     # Return through placePieceOnBoard error handling

placePieceOnBoard:
    # Save registers
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s2, 0($sp)
    
    # Load piece data into appropriate registers
    lw $t0, 0($a0)     # piece type
    lw $s4, 4($a0)     # orientation
    lw $s5, 8($a0)     # row
    lw $s6, 12($a0)    # col
    move $s1, $a1      # ship_num
    
    # Validate type/orientation
    li $t1, 1
    blt $t0, $t1, invalid_piece
    li $t1, 7
    bgt $t0, $t1, invalid_piece
    li $t1, 1
    blt $s4, $t1, invalid_piece
    li $t1, 4  
    bgt $s4, $t1, invalid_piece
    
    # Initialize error accumulator
    li $s2, 0          
    
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

invalid_piece:
    jal zeroOut        # Clear board on invalid piece
    li $v0, 2          
    j piece_done

piece_return:
    # If no errors, just return success
    beqz $s2, success
    
    # If there were errors, clear board and return error
    jal zeroOut
    move $v0, $s2
    j piece_done

success:
    li $v0, 0          # Return success without clearing board

piece_done:
    # Restore saved registers
    lw $ra, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 8
    jr $ra

test_fit:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0      
    li $s1, 0          
    li $s2, 0          
    
    # Initial clear
    jal zeroOut

test_loop:
    # Get piece
    li $t0, 16
    mul $t0, $t0, $s1
    add $s3, $s0, $t0
    
    # Validate piece
    lw $t1, 0($s3)     
    lw $t2, 4($s3)     
    
    li $t3, 1
    blt $t1, $t3, invalid_fit_type
    li $t3, 7
    bgt $t1, $t3, invalid_fit_type
    li $t3, 1
    blt $t2, $t3, invalid_fit_type
    li $t3, 4
    bgt $t2, $t3, invalid_fit_type

    # Try piece
    move $a0, $s3
    addi $a1, $s1, 1
    jal placePieceOnBoard
    
    # Update max error
    blt $v0, $s2, continue_fit_test
    move $s2, $v0
    
continue_fit_test:
    addi $s1, $s1, 1
    li $t0, 5          
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