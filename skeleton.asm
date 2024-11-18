# Register Usage:
#   Input Registers to this code block (never updated):
#   $s1 - ship_num (piece identifier 1-5)
#   $s4 - piece orientation (1-4)
#   $s5 - piece row location
#   $s6 - piece column location
#
#   Used/Clobbered Registers in this code block:
#   $s2 - accumulated error value
#   $a0 - argument: row position for place_tile
#   $a1 - argument: column position for place_tile
#   $a2 - argument: ship_num for place_tile
#   $v0 - return value from place_tile
#   $t0 - temporary comparisons
#
# Piece placement cases
piece_square:
    # All orientations are the same for square
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1          # ship_num
    jal place_tile
    or $s2, $s2, $v0       # accumulate error

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

piece_line:
    li $t0, 1
    beq $s4, $t0, line_vertical
    li $t0, 3
    beq $s4, $t0, line_vertical
    j line_horizontal

line_vertical:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1
    move $a1, $s6
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2
    move $a1, $s6
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 3
    move $a1, $s6
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

line_horizontal:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    move $a1, $s6
    addi $a1, $a1, 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    move $a1, $s6
    addi $a1, $a1, 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    move $a1, $s6
    addi $a1, $a1, 3
    move $a2, $s1
    jal place_tile
    j piece_done

piece_L:
    li $t0, 1
    beq $s4, $t0, L_orientation1
    li $t0, 2
    beq $s4, $t0, L_orientation2
    li $t0, 3
    beq $s4, $t0, L_orientation3
    j L_orientation4

L_orientation1:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2       # row + 2
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2       # row + 2
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

L_orientation2:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

L_orientation3:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2       # row + 2
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

L_orientation4:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

piece_z:
    li $t0, 1
    beq $s4, $t0, z_flat
    li $t0, 3
    beq $s4, $t0, z_flat
    j z_vertical

z_flat:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

z_vertical:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

piece_reverse_L:
    li $t0, 1
    beq $s4, $t0, reverse_L_orientation1
    li $t0, 2
    beq $s4, $t0, reverse_L_orientation2
    li $t0, 3
    beq $s4, $t0, reverse_L_orientation3
    j reverse_L_orientation4

reverse_L_orientation1:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -2      # row - 2
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

reverse_L_orientation2:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

reverse_L_orientation3:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2       # row + 2
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

reverse_L_orientation4:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

piece_T:
    li $t0, 1
    beq $s4, $t0, T_orientation1
    li $t0, 2
    beq $s4, $t0, T_orientation2
    li $t0, 3
    beq $s4, $t0, T_orientation3
    j T_orientation4

T_orientation1:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

T_orientation2:
    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

T_orientation3:
    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

piece_reverse_z:
    li $t0, 1
    beq $s4, $t0, reverse_z_flat
    li $t0, 3
    beq $s4, $t0, reverse_z_flat
    j reverse_z_vertical

reverse_z_flat:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5          # row
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, -1      # row - 1
    move $a1, $s6
    addi $a1, $a1, 2       # col + 2
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done

reverse_z_vertical:
    move $a0, $s5          # row
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6          # col
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1       # row + 1
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2       # row + 2
    move $a1, $s6
    addi $a1, $a1, 1       # col + 1
    move $a2, $s1
    jal place_tile
    or $s2, $s2, $v0
    j piece_done