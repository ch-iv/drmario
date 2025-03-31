.data
    trololol: .space 1000000
    disp_addr: .word 0x10008000
    screen_size: .word 57344
    screen_height: .word 224
    screen_width: .word 256
    screen_width2: .word 0x100
    background_color: .word 0x7C606B 
    foreground_color: .word 0xEDA4BD
    dark_blue: .word 0x111d4a
    turquoise: .word 0x8789C0
    color_black: .word 0b0
    color_purple: .word 0x5500b2
    color_dark_purple: .word 0x2e0061
    keyboard_address: .word 0xffff0000
    render_buffer: .space 229376
    render_buffer_size: .word 229376
    trolo1: .space 10000000
    .include "board.c"
    trolo2: .space 10000000
    .include "pill_red_left.c"
    .include "pill_red_right.c"
    .include "pill_red_top.c"
    .include "pill_red_bottom.c"
    .include "pill_red_single.c"
    .include "pill_red_empty.c"
    .include "pill_blue_left.c"
    .include "pill_blue_right.c"
    .include "pill_blue_top.c"
    .include "pill_blue_bottom.c"
    .include "pill_blue_single.c"
    .include "pill_blue_empty.c"
    .include "pill_yellow_left.c"
    .include "pill_yellow_right.c"
    .include "pill_yellow_top.c"
    .include "pill_yellow_bottom.c"
    .include "pill_yellow_single.c"
    .include "pill_yellow_empty.c"
    .include "bottle.c"
    trolo: .space 10000000

.macro push(%reg)
    # Pushes a register value onto a stack.
    addi $sp $sp -4
    sw %reg 0($sp)
.end_macro

.macro push_zero(%reg)
    # Pushes a register value onto a stack and zeroes the register.
    addi $sp $sp -4
    sw %reg 0($sp)
    li %reg 0
.end_macro

.macro pop(%reg)
    # Pops register value from a stack.
    lw %reg 0($sp)
    addi $sp $sp 4
.end_macro

.macro set_x_offset_i(%a1)
    # Sets the x offset to the value provided.
    # The x offset is stored in $s2.
    li $s2 %a1
.end_macro

.macro set_y_offset_i(%a1)
    # Sets the y offset to the value provided.
    # The y offset is stored in $s3.
    li $s3 %a1
.end_macro

.macro set_color(%a1)
    # Sets the current drawing color to the value provided in the register.
    # The drawing color is stored in $s7.
    move $s7 %a1
.end_macro

.macro set_color_i(%a1)
    # Sets the current drawing color to the value provided.
    # The drawing color is stored in $s7.
    li $s7 %a1
.end_macro

.macro set_color_w(%a1)
    # Sets the current drawing color from the provided word label.
    # The drawing color is stored in $s7.
    lw $s7 %a1
.end_macro

.macro set_x(%a1)
    # Sets the value of x from a register.
    # x position is stored in $s0
    move $s0 %a1
.end_macro

.macro set_x_i(%a1)
    # Sets the value of x from a passed int.
    # x position is stored in $s0
    li $s0 %a1
.end_macro

.macro set_x_w(%a1)
    # Sets the value of x from a word.
    # x position is stored in $s0
    lw $s0 %a1
.end_macro

.macro set_y(%a1)
    # Sets the value of y from a register.
    # y position is stored in $s1
    move $s1 %a1
.end_macro

.macro set_y_i(%a1)
    # Sets the value of y from a passed int.
    # y position is stored in $s1
    li $s1 %a1
.end_macro

.macro set_y_w(%a1)
    # Sets the value of y from a word.
    # y position is stored in $s1
    lw $s1 %a1
.end_macro

.macro draw()
    # draws a pixel offset by x offset and y offset from the register x y position.
    # Calculate x position with offset: $s0 + $t0
    push_zero($t0)
    push($t1)
    push($t2)
    push($t3)
    
    lw $t1 screen_width
    move $t0 $s1        # t0 = y
    add $t0 $t0 $s3     # t0 = y + y_offset
    mul $t0 $t0 $t1     # t0 = screen_width * (y + y_offset)
    add $t0 $t0 $s0     # t0 = screen_width * (y + y_offset) + x
    add $t0 $t0 $s2     # t0 = screen_width * (y + y_offset) + x + x_offset
    
      
    li $t3 4
    mul $t0 $t0 $t3
    
    la $t2 render_buffer
    add $t2 $t2 $t0
    
    sw $s7, 0($t2)
    
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro draw_background()
    push_zero($t0)
    push_zero($t1)
    push($t2)
    push($t3)
    push($t4)
    
    li $t0 31
    li $t1 27
    li $t3 8

    draw_background_loop_y:
        mul $s1 $t1 $t3
        li $t0 31
        draw_background_loop_x:
            xor $t4 $t1 $t0          # XOR row and column to alternate colors
            andi $t4 $t4 1           # Mask the lowest bit (alternating pattern)
            beqz $t4 draw_background_set_black
            
            draw_background_set_white:
                set_color_w(color_black)
                j draw_background_draw
            draw_background_set_black:
                set_color_w(color_dark_purple)               
            draw_background_draw:
                mul $s0 $t0 $t3
                draw_square($t3)
                subi $t0 $t0 1
                bgez $t0 draw_background_loop_x
        subi $t1 $t1 1
        bgez $t1 draw_background_loop_y
    pop($t4)
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro draw_square(%size_register)
    push_zero($s2) # $s2 will store the x offset
    push_zero($s3) # $s3 will store the y offset
    
    draw_square_loop_y:
        li $s2 0
        draw_square_loop_x:
            draw()
            addi $s2 $s2 1
            blt $s2 %size_register draw_square_loop_x
        addi $s3 $s3 1
        blt $s3 %size_register draw_square_loop_y
    
    pop($s3)
    pop($s2)
.end_macro


.macro draw_asset(%asset_size, %asset_data)
    push($t0)
    push($t1)
    
    lw $t0 %asset_size
    la $t1 %asset_data
    
    draw_asset_loop:
        lw $s2 0($t1)   # x offset
        lw $s3 4($t1)   # y offset
        lw $s7 8($t1)   # color
        draw()
        
        addi $t1 $t1 12
        subi $t0 $t0 1
        bgtz $t0, draw_asset_loop
    
    pop($t1)
    pop($t0)
.end_macro

.macro draw_board(%board)
    push($t0)
    push($t1)
    push($t2)
    push($t3)
    push($t4)
    push($t5)
    push($t6)
    push($t7)
    push($t8)
    
    set_x_i(0)
    set_y_i(0)
    draw_asset(asset_bottle_size, asset_bottle_data)
    
    lw $t0 board_width    # x iteration variable
    lw $t1 board_height   # y iteration variable
    la $t2 board
    
    draw_board_loop_y:
        lw $t0 board_width
        draw_board_loop_x:
                lw $s0 0($t2)   # x offset
                lw $s1 4($t2)   # y offset
                lw $t5 8($t2)   # sprite color (not a hex code)
                lw $t6 12($t2)  # sprite type
                
                andi $t7 $t6 0b01000000     # is it a pill?
                blez $t7 not_a_pill
                
                it_is_a_pill:
                    andi $t7 $t5 0b00000001     # is it red?
                    bgtz $t7 draw_red_pill
                    andi $t7 $t5 0b00000010     # is it blue?
                    bgtz $t7 draw_blue_pill
                    andi $t7 $t5 0b00000100     # is it yellow?
                    bgtz $t7 draw_yellow_pill
                    j not_a_pill    # neither red, blue, nor yellow
                    
                    draw_red_pill:
                        andi $t8 $t6 0b00100000     # is it a left sided pill?
                        bgtz $t8 draw_red_left_pill
                        andi $t8 $t6 0b00010000     # is it a right sided pill?
                        bgtz $t8 draw_red_right_pill
                        andi $t8 $t6 0b00001000     # is it a top sided pill?
                        bgtz $t8 draw_red_top_pill
                        andi $t8 $t6 0b00000100     # is it a bottom sided pill?
                        bgtz $t8 draw_red_bottom_pill
                        andi $t8 $t6 0b00000010     # is it a single sided pill?
                        bgtz $t8 draw_red_single_pill
                        andi $t8 $t6 0b00000001     # is it an empty pill?
                        bgtz $t8 draw_red_empty_pill
                        j not_a_pill    # neither left, right, top, bottom nor single
                        
                        draw_red_left_pill:
                            draw_asset(asset_pill_red_left_size, asset_pill_red_left_data)
                            j not_a_pill    # done rendering the pill
                        draw_red_right_pill:
                            draw_asset(asset_pill_red_right_size, asset_pill_red_right_data)
                            j not_a_pill    # done rendering the pill
                        draw_red_top_pill:
                            draw_asset(asset_pill_red_top_size, asset_pill_red_top_data)
                            j not_a_pill    # done rendering the pill
                        draw_red_bottom_pill:
                            draw_asset(asset_pill_red_bottom_size, asset_pill_red_bottom_data)
                            j not_a_pill    # done rendering the pill
                        draw_red_single_pill:
                            draw_asset(asset_pill_red_single_size, asset_pill_red_single_data)
                            j not_a_pill    # done rendering the pill      
                        draw_red_empty_pill:
                            draw_asset(asset_pill_red_empty_size, asset_pill_red_empty_data)
                            j not_a_pill    # done rendering the pill    
                        j not_a_pill    # done rendering the pill
                    
                    draw_blue_pill:
                        andi $t8 $t6 0b00100000     # is it a left sided pill?
                        bgtz $t8 draw_blue_left_pill
                        andi $t8 $t6 0b00010000     # is it a right sided pill?
                        bgtz $t8 draw_blue_right_pill
                        andi $t8 $t6 0b00001000     # is it a top sided pill?
                        bgtz $t8 draw_blue_top_pill
                        andi $t8 $t6 0b00000100     # is it a bottom sided pill?
                        bgtz $t8 draw_blue_bottom_pill
                        andi $t8 $t6 0b00000010     # is it a single sided pill?
                        bgtz $t8 draw_blue_single_pill
                        andi $t8 $t6 0b00000001     # is it an empty pill?
                        bgtz $t8 draw_blue_empty_pill
                        j not_a_pill    # neither left, right, top, bottom nor single
                        
                        draw_blue_left_pill:
                            draw_asset(asset_pill_blue_left_size, asset_pill_blue_left_data)
                            j not_a_pill    # done rendering the pill
                        draw_blue_right_pill:
                            draw_asset(asset_pill_blue_right_size, asset_pill_blue_right_data)
                            j not_a_pill    # done rendering the pill
                        draw_blue_top_pill:
                            draw_asset(asset_pill_blue_top_size, asset_pill_blue_top_data)
                            j not_a_pill    # done rendering the pill
                        draw_blue_bottom_pill:
                            draw_asset(asset_pill_blue_bottom_size, asset_pill_blue_bottom_data)
                            j not_a_pill    # done rendering the pill
                        draw_blue_single_pill:
                            draw_asset(asset_pill_blue_single_size, asset_pill_blue_single_data)
                            j not_a_pill    # done rendering the pill     
                        draw_blue_empty_pill:
                            draw_asset(asset_pill_blue_empty_size, asset_pill_blue_empty_data)
                            j not_a_pill    # done rendering the pill
                    j not_a_pill    # done rendering the pill
                    
                    draw_yellow_pill:
                        andi $t8 $t6 0b00100000     # is it a left sided pill?
                        bgtz $t8 draw_yellow_left_pill
                        andi $t8 $t6 0b00010000     # is it a right sided pill?
                        bgtz $t8 draw_yellow_right_pill
                        andi $t8 $t6 0b00001000     # is it a top sided pill?
                        bgtz $t8 draw_yellow_top_pill
                        andi $t8 $t6 0b00000100     # is it a bottom sided pill?
                        bgtz $t8 draw_yellow_bottom_pill
                        andi $t8 $t6 0b00000010     # is it a single sided pill?
                        bgtz $t8 draw_yellow_single_pill
                        andi $t8 $t6 0b00000001     # is it an empty pill?
                        bgtz $t8 draw_yellow_empty_pill
                        j not_a_pill    # neither left, right, top, bottom nor single
                        
                        draw_yellow_left_pill:
                            draw_asset(asset_pill_yellow_left_size, asset_pill_yellow_left_data)
                            j not_a_pill    # done rendering the pill
                        draw_yellow_right_pill:
                            draw_asset(asset_pill_yellow_right_size, asset_pill_yellow_right_data)
                            j not_a_pill    # done rendering the pill
                        draw_yellow_top_pill:
                            draw_asset(asset_pill_yellow_top_size, asset_pill_yellow_top_data)
                            j not_a_pill    # done rendering the pill
                        draw_yellow_bottom_pill:
                            draw_asset(asset_pill_yellow_bottom_size, asset_pill_yellow_bottom_data)
                            j not_a_pill    # done rendering the pill
                        draw_yellow_single_pill:
                            draw_asset(asset_pill_yellow_single_size, asset_pill_yellow_single_data)
                            j not_a_pill    # done rendering the pill      
                        draw_yellow_empty_pill:
                            draw_asset(asset_pill_yellow_empty_size, asset_pill_yellow_empty_data)
                            j not_a_pill    # done rendering the pill   
                    j not_a_pill    # done rendering the pill
                    
                not_a_pill:
                    addi $t2 $t2 32
                    subi $t0 $t0 1
                    bgtz $t0 draw_board_loop_x
        subi $t1 $t1 1
        bgtz $t1 draw_board_loop_y
    
    pop($t8)
    pop($t7)
    pop($t6)
    pop($t5)
    pop($t4)
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro remove_cell(%cell_addr)
    push($t0)
    push($t1)
    push($t2)
    
    lw $t0 12(%cell_addr)  # sprite type
    andi $t0 $t0 0b00111100 # greater than 0 if this a left, right, top, or bottom pill
                            # we do not care for other cases, because we can just zero out the memory
    beq $t0 $zero zero_memory 
    
    # Handle each direction of pill
    andi $t1 $t0 0b00100000     # is it a left sided pill?
    bgtz $t1 remove_left_pill
    andi $t1 $t0 0b00010000     # is it a right sided pill?
    bgtz $t1 remove_right_pill
    andi $t1 $t0 0b00001000     # is it a top sided pill?
    bgtz $t1 remove_top_pill
    andi $t1 $t0 0b00000100     # is it a bottom sided pill?
    bgtz $t1 remove_bottom_pill
    j zero_memory
    
    remove_left_pill:
        addi %cell_addr %cell_addr 32   # cell_addr is pointing to the cell to the right of our original cell
        lw $t2 12(%cell_addr)   # holding the sprite type
        andi $t2 $t2 0b11000011 # remove previous pill type
        ori $t2 $t2 0b00000010  # set to a single pill
        sw $t2 12(%cell_addr)
        subi %cell_addr %cell_addr 32
        j zero_memory
    remove_right_pill:
        subi %cell_addr %cell_addr 32   # cell_addr is pointing to the cell to the right of our original cell
        lw $t2 12(%cell_addr)   # holding the sprite type
        andi $t2 $t2 0b11000011 # remove previous pill type
        ori $t2 $t2 0b00000010  # set to a single pill
        sw $t2 12(%cell_addr)
        addi %cell_addr %cell_addr 32
        j zero_memory
    remove_top_pill:
        addi %cell_addr %cell_addr 256   # cell_addr is pointing to the cell to the right of our original cell
        lw $t2 12(%cell_addr)   # holding the sprite type
        andi $t2 $t2 0b11000011 # remove previous pill type
        ori $t2 $t2 0b00000010  # set to a single pill
        sw $t2 12(%cell_addr)
        subi %cell_addr %cell_addr 256
        j zero_memory
    remove_bottom_pill:
        subi %cell_addr %cell_addr 256   # cell_addr is pointing to the cell to the right of our original cell
        lw $t2 12(%cell_addr)   # holding the sprite type
        andi $t2 $t2 0b11000011 # remove previous pill type
        ori $t2 $t2 0b00000010  # set to a single pill
        sw $t2 12(%cell_addr)
        addi %cell_addr %cell_addr 256
        j zero_memory
    
    zero_memory:
        # sw $zero 0(%cell_addr)
        # sw $zero 4(%cell_addr)
        sw $zero 8(%cell_addr)
        sw $zero 12(%cell_addr)
        sw $zero 16(%cell_addr)
        sw $zero 20(%cell_addr)
        sw $zero 24(%cell_addr)
        sw $zero 28(%cell_addr)
    
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro remove_connected(%board)
    push($t0)
    push($t1)
    push($t2)
    push($t3)
    push($t4)
    push($t5)
    push($t6)
    push($t7)
    push($t8)
    
    lw $t0 board_width_minus_one    # x iteration variable
    lw $t1 board_height_minus_one   # y iteration variable
    
    
    draw_board_loop_y:
        lw $t0 board_width_minus_one
        draw_board_loop_x:
                la $t2 board
                li $t3 256
                mul $t3 $t3 $t1
                add $t2 $t2 $t3
                li $t3 32
                mul $t3 $t3 $t0
                add $t2 $t2 $t3     # now $t2 stores the beginning of the memory location that stores the cell at (x=$t0, y=$t1)
                
                lw $t5 8($t2)   # sprite color (not a hex code)    
                
                li $t6 3
                anding_color:
                    subi $t2 $t2 256
                    lw $t7 8($t2)
                    and $t5 $t5 $t7
                    subi $t6 $t6 1
                    bgtz $t6 anding_color
                
                beq $t5 $zero remove_conntected_continue
                
                li $t6 4
                removing_cells:
                    move $a0 $t2    # a0 stores the adress of the cell to remove
                    remove_cell($a0)
                    addi $t2 $t2 256    # jump to the row below
                    
                    subi $t6 $t6 1
                    bgtz $t6 removing_cells
                
                remove_conntected_continue:
                subi $t0 $t0 1
                bgez $t0 draw_board_loop_x
        subi $t1 $t1 1
        li $t0 3
        bge $t1 $t0 draw_board_loop_y
    
    pop($t8)
    pop($t7)
    pop($t6)
    pop($t5)
    pop($t4)
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro remove_connected_horizontal(%board_addr)
    push($t0)
    push($t1)
    push($t2)
    push($t3)
    push($t4)
    push($t5)
    push($t6)
    push($t7)
    push($t8)
    
    lw $t0 board_width_minus_one    # x iteration variable
    lw $t1 board_height_minus_one   # y iteration variable
    
    
    draw_board_loop_y:
        lw $t0 board_width_minus_one
        draw_board_loop_x:
                la $t2 board
                li $t3 256
                mul $t3 $t3 $t1
                add $t2 $t2 $t3
                li $t3 32
                mul $t3 $t3 $t0
                add $t2 $t2 $t3     # now $t2 stores the beginning of the memory location that stores the cell at (x=$t0, y=$t1)
                
                lw $t5 8($t2)   # sprite color (not a hex code)    
                
                li $t6 3
                anding_color:
                    subi $t2 $t2 32
                    lw $t7 8($t2)
                    and $t5 $t5 $t7
                    subi $t6 $t6 1
                    bgtz $t6 anding_color
                
                beq $t5 $zero remove_conntected_continue
                
                li $t6 4
                removing_cells:
                    move $a0 $t2    # a0 stores the adress of the cell to remove
                    remove_cell($a0)
                    addi $t2 $t2 32    # jump to the cell to the right
                    
                    subi $t6 $t6 1
                    bgtz $t6 removing_cells
                
                remove_conntected_continue:
                subi $t0 $t0 1
                li $t6 3
                bge $t0 $t6 draw_board_loop_x
        subi $t1 $t1 1
        bgez $t1 draw_board_loop_y
    
    pop($t8)
    pop($t7)
    pop($t6)
    pop($t5)
    pop($t4)
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro try_drop_cell(%cell_addr)
    push($t0)
    push($t1)
    push($t2)
    
    # We do not drop right pills
    lw $t0 12(%cell_addr)
    
    andi $t1 $t0 0b00100000     # is it a left sided pill?
    bgtz $t1 drop_left_pill
    andi $t1 $t0 0b00001000     # is it a top sided pill?
    bgtz $t1 drop_bottom_or_top
    andi $t1 $t0 0b00000100     # is it a bottom sided pill?
    bgtz $t1 drop_bottom_or_top
    andi $t1 $t0 0b00000010     # is it a single sided pill?
    bgtz $t1 drop_bottom_or_top
    j exit_try_drop_cell
    
    drop_left_pill:
        move $t2 %cell_addr
        addi $t2 $t2 256  # t2 now points to the cell below
        lw $t1 12($t2)           # t1 is now a sprite type. It is greater than 0 if there is something under the pill we are trying to drop
        addi $t2 $t2 32     # t2 points at the cell below and to the right
        lw $t0 12($t2)  # sprite type
        add $t1 $t1 $t0
        bgtz $t1 exit_try_drop_cell     # there is support - do not drop the pill.
        
        subi $t2 $t2 32
        lw $t1 8(%cell_addr)
        sw $t1 8($t2)
        sw $zero 8(%cell_addr)
        lw $t1 12(%cell_addr)
        sw $t1 12($t2)
        sw $zero 12(%cell_addr)
        lw $t1 16(%cell_addr)
        sw $t1 16($t2)
        sw $zero 16(%cell_addr)
        lw $t1 20(%cell_addr)
        sw $t1 20($t2)
        sw $zero 20(%cell_addr)
        lw $t1 24(%cell_addr)
        sw $t1 24($t2)
        sw $zero 24(%cell_addr)
        lw $t1 28(%cell_addr)
        sw $t1 28($t2)
        sw $zero 28(%cell_addr)
        
        bne $s4 %cell_addr do_not_set_current_left_pill
        move $s4 $t2    # set current pill pointer for left to the value after gravity
        do_not_set_current_left_pill:
        
        addi $t2 $t2 32
        addi %cell_addr %cell_addr 32 
        lw $t1 8(%cell_addr)
        sw $t1 8($t2)
        sw $zero 8(%cell_addr)
        lw $t1 12(%cell_addr)
        sw $t1 12($t2)
        sw $zero 12(%cell_addr)
        lw $t1 16(%cell_addr)
        sw $t1 16($t2)
        sw $zero 16(%cell_addr)
        lw $t1 20(%cell_addr)
        sw $t1 20($t2)
        sw $zero 20(%cell_addr)
        lw $t1 24(%cell_addr)
        sw $t1 24($t2)
        sw $zero 24(%cell_addr)
        lw $t1 28(%cell_addr)
        sw $t1 28($t2)
        sw $zero 28(%cell_addr)
        
        bne $s5 %cell_addr do_not_set_current_left_right
        move $s5 $t2    # set current pill pointer for right to the value after gravity
        do_not_set_current_left_right:
        
        j exit_try_drop_cell
    drop_bottom_or_top:
        move $t2 %cell_addr
        addi $t2 $t2 256  # t2 now points to the cell below
        lw $t1 12($t2)           # t1 is now a sprite type. It is greater than 0 if there is something under the pill we are trying to drop
        bgtz $t1 exit_try_drop_cell     # there is support - do not drop the pill.
        
        beq %cell_addr $s4 drop_set_top
        beq %cell_addr $s5 drop_set_right
        j drop_set_cont
        
        drop_set_top:
            addi $s4 $s4 256
            j drop_set_cont
        drop_set_right:
            addi $s5 $s5 256
            j drop_set_cont
        
        drop_set_cont:
        # copy over info
        lw $t1 8(%cell_addr)
        sw $t1 8($t2)
        sw $zero 8(%cell_addr)
        lw $t1 12(%cell_addr)
        sw $t1 12($t2)
        sw $zero 12(%cell_addr)
        lw $t1 16(%cell_addr)
        sw $t1 16($t2)
        sw $zero 16(%cell_addr)
        lw $t1 20(%cell_addr)
        sw $t1 20($t2)
        sw $zero 20(%cell_addr)
        lw $t1 24(%cell_addr)
        sw $t1 24($t2)
        sw $zero 24(%cell_addr)
        lw $t1 28(%cell_addr)
        sw $t1 28($t2)
        sw $zero 28(%cell_addr)
    exit_try_drop_cell:
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro do_gravity(%board)
    push($t0)
    push($t1)
    push($t2)
    push($t3)
    push($t4)
    push($t5)
    push($t6)
    push($t7)
    push($t8)
    
    lw $t0 board_width_minus_one    # x iteration variable
    lw $t1 board_height_minus_one   # y iteration variable
    subi $t1 $t1 1  # we don't do gravity on last row
    
    draw_board_loop_y:
        lw $t0 board_width_minus_one
        draw_board_loop_x:
                la $t2 board
                li $t3 256
                mul $t3 $t3 $t1
                add $t2 $t2 $t3
                li $t3 32
                mul $t3 $t3 $t0
                add $t2 $t2 $t3     # now $t2 stores the beginning of the memory location that stores the cell at (x=$t0, y=$t1)
                
                move $a0 $t2
                try_drop_cell($a0)

                subi $t0 $t0 1
                bgez $t0 draw_board_loop_x
        subi $t1 $t1 1
        bgez $t1 draw_board_loop_y
    
    pop($t8)
    pop($t7)
    pop($t6)
    pop($t5)
    pop($t4)
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro iter(%board)
    push($t0)
    push($t1)
    push($t2)
    push($t3)
    push($t4)
    push($t5)
    push($t6)
    push($t7)
    push($t8)
    
    lw $t0 board_width_minus_one    # x iteration variable
    lw $t1 board_height_minus_one   # y iteration variable
    
    
    draw_board_loop_y:
        lw $t0 board_width_minus_one
        draw_board_loop_x:
                la $t2 board
                li $t3 256
                mul $t3 $t3 $t1
                add $t2 $t2 $t3
                li $t3 32
                mul $t3 $t3 $t0
                add $t2 $t2 $t3     # now $t2 stores the beginning of the memory location that stores the cell at (x=$t0, y=$t1)
                
                lw $s0 0($t2)   # x offset
                lw $s1 4($t2)   # y offset
                lw $t5 8($t2)   # sprite color (not a hex code)
                lw $t6 12($t2)  # sprite type
                
                subi $t0 $t0 1
                bgez $t0 draw_board_loop_x
        subi $t1 $t1 1
        bgez $t1 draw_board_loop_y
    
    pop($t8)
    pop($t7)
    pop($t6)
    pop($t5)
    pop($t4)
    pop($t3)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro blit()
    push($t0)
    push($t1)
    push($t2)
    
    lw $t0 render_buffer_size      # Load the size of the render buffer (in bytes)
    la $t1 render_buffer           # Load the address of the render buffer
    lw $t2 disp_addr               # Load the address of the display buffer
    srl $t0 $t0 2                # Divide size by 4 to get number of words to copy
  
    blit_loop:
        beqz $t0 blit_done          # If size is zero, we're done
        lw $t3 0($t1)               # Load word from render buffer
        sw $t3 0($t2)               # Store word to display buffer
        addiu $t1 $t1 4            # Advance render buffer pointer
        addiu $t2 $t2 4            # Advance display buffer pointer
        subu $t0 $t0 1             # Decrement word count
        j blit_loop                  # Repeat loop
    blit_done:
    
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro rand(%max)
    push($a0)
    push($a1)
    
    li $v0 42
    li $a0 0
    li $a1 %max
    syscall
    move $v0 $a0
    
    pop($a1)
    pop($a0)
.end_macro

.macro rand_pill_color()
    push($t0)
    rand(3)
    
    beq $v0 $zero rand_color_red
    li $t0 1
    beq $v0 $t0 rand_color_blue
    li $t0 2
    beq $v0 $t0 rand_color_yellow
    
    rand_color_red:
        li $v0 0b00000001 
        j rand_color_exit
    rand_color_blue:
        li $v0 0b00000010
        j rand_color_exit
    rand_color_yellow:
        li $v0 0b00000100 
        j rand_color_exit
    rand_color_exit:
    pop($t0)
.end_macro

.macro generate_random_pill()
    push($t0)
    push($t1)
    push($t2)
    la $t0 board
    addi $t0 $t0 96 # points to center left pill
    addi $t1 $t0 32 # points to center right pill
    move $s4 $t0
    move $s5 $t1
    
    rand_pill_color()
    sw $v0 8($t0)
    li $t2 0b01100000   # left pill
    sw $t2 12($t0)
    
    rand_pill_color()
    sw $v0 8($t1)
    li $t2 0b01010000   # right pill
    sw $t2 12($t1)
    pop($t2)
    pop($t1)
    pop($t0)
.end_macro

.macro sleep(%millis)
    push($a0)
    li $v0 32
    li $a0 %millis
    syscall
    pop($a0)
.end_macro

.macro tick_set_zero()
    li $s6 0
.end_macro

.macro tick_sleep()
    push($t0)
    sleep(1)
    addi $s6 $s6 1
    li $t0 1024    
    
    bge $s6 $t0 set_zero
    j tick_sleep_exit
    
    set_zero:
        li $s6 0
    
    tick_sleep_exit:
    pop($t0)
.end_macro

.macro on_tick(%tick, %label)
    push($t0)
    li $t0 %tick
    div $s6 $t0
    mfhi $t0
    bne $t0 $zero %label
    pop($t0)
.end_macro

.macro is_vertical()
    sub $v0 $s5 $s4
    srl $v0 $v0 8
.end_macro

.macro set_pill_left(%pill_addr)
    push($t0)
    li $t0 0b01100000
    sw $t0 12(%pill_addr)
    pop($t0)
.end_macro

.macro set_pill_right(%pill_addr)
    push($t0)
    li $t0 0b01010000
    sw $t0 12(%pill_addr)
    pop($t0)
.end_macro

.macro set_pill_top(%pill_addr)
    push($t0)
    li $t0 0b01001000
    sw $t0 12(%pill_addr)
    pop($t0)
.end_macro

.macro set_pill_bottom(%pill_addr)
    push($t0)
    li $t0 0b01000100
    sw $t0 12(%pill_addr)
    pop($t0)
.end_macro


.macro move_pill(%destination, %source)
    push($t1)
    lw $t1 8(%source)
    sw $t1 8(%destination)
    sw $zero 8(%source)
    lw $t1 12(%source)
    sw $t1 12(%destination)
    sw $zero 12(%source)
    lw $t1 16(%source)
    sw $t1 16(%destination)
    sw $zero 16(%source)
    lw $t1 20(%source)
    sw $t1 20(%destination)
    sw $zero 20(%source)
    lw $t1 24(%source)
    sw $t1 24(%destination)
    sw $zero 24(%source)
    lw $t1 28(%source)
    sw $t1 28(%destination)
    sw $zero 28(%source)
    pop($t1)
.end_macro

.macro rotate()
    push($v0)
    # left < right
    # top < bottom
    # left -> top
    # right -> bottom
    is_vertical()
    beq $v0 $zero rotate_horizontal
    bne $v0 $zero rotate_vertical
    
    rotate_horizontal:
        # we are now in horizontal mode
        # left pointer becomes top
        # right pointer takes place of the left pointer
        move $t0 $s4  # original left
        move $t1 $s5  # original right
        
        subi $s5 $s5 32  # right takes place of old left    THIS IS BOTTOM
        subi $s4 $s4 256 # left becomes top THIS IS TOP
        
        move $a0 $s4
        move $a1 $t0
        move_pill($a0, $a1)
        set_pill_top($s4)
        
        move $a0 $s5
        move $a1 $t1
        move_pill($a0, $a1)
        set_pill_bottom($s5)
        j rotate_exit
    
    rotate_vertical:
        move $t0 $s4  # original top
        move $t1 $s5  # original bottom
        
        addi $s5 $s5 32
        addi $s4 $s4 256
            
        move $a0 $s5
        move $a1 $t0
        move_pill($a0, $a1)
        set_pill_right($s5)
        
        set_pill_left($s4)
        j rotate_exit
    
    rotate_exit:
    draw_board(board)
    blit()
    pop($v0)
.end_macro

.macro move_right()
    lw $t0 0($s5)
    beq $t0 152 move_right_exit
    
    move $t0 $s4
    move $t1 $s5
    
    addi $s4 $s4 32
    addi $s5 $s5 32
    
    move $a0 $s5
    move $a1 $t1
    move_pill($a0, $a1)
    
    move $a0 $s4
    move $a1 $t0
    move_pill($a0, $a1)
    move_right_exit:
.end_macro

.macro move_left()
    lw $t0 0($s4)
    beq $t0 96 move_left_exit
    is_occupied_sub($s4, 32)
    bgtz $v0 move_left_exit
    is_vertical()
    bgtz $v0 check_vertical
    
    
    move $t0 $s4
    move $t1 $s5
    
    subi $s4 $s4 32
    subi $s5 $s5 32
    
    move $a0 $s4
    move $a1 $t0
    move_pill($a0, $a1)
    
    move $a0 $s5
    move $a1 $t1
    move_pill($a0, $a1)
    move_left_exit:
.end_macro

.macro move_down()
    lw $t0 4($s5)
    beq $t0 192 move_down_exit
    
    move $t0 $s4
    move $t1 $s5
    
    addi $s4 $s4 256
    addi $s5 $s5 256
    
    move $a0 $s5
    move $a1 $t1
    move_pill($a0, $a1)
    
    move $a0 $s4
    move $a1 $t0
    move_pill($a0, $a1)
    move_down_exit:
.end_macro

.macro is_occupied_add(%base, %offset)
    push($t0)
    addi $t0 %base %offset
    lw $t0 12($t0)
    bgtz $t0 is_occupied_true
    li $v0 0
    j is_occupied_exit
    
    is_occupied_true:
        li $v0 1
    
    is_occupied_exit:
    pop($t0)
.end_macro

.macro is_occupied_sub(%base, %offset)
    push($t0)
    subi $t0 %base %offset
    lw $t0 12($t0)
    bgtz $t0 is_occupied_true
    li $v0 0
    j is_occupied_exit
    
    is_occupied_true:
        li $v0 1
    
    is_occupied_exit:
    pop($t0)
.end_macro

.macro check_kb()
    push($t0)
    push($t1)
    
    lw $t0 keyboard_address
    lw $t1 0($t0)
    bne $t1 1 check_kb_exit
    lw $t1 4($t0)   # hold value of the key that has been pressed
    
    beq $t1 0x72 handle_q
    beq $t1 0x77 handle_w
    beq $t1 0x64 handle_d
    beq $t1 0x61 handle_a
    beq $t1 0x73 handle_s
    j check_kb_exit
    
    handle_q:
        generate_random_pill()
        do_gravity(board)
        draw_board(board)
        blit()
        j check_kb_exit
    
    handle_d:
        move_right()
        draw_board(board)
        blit()
        j check_kb_exit
        
    handle_w:
        rotate()
        j check_kb_exit
        
    handle_a:
        move_left()
        draw_board(board)
        blit()
        j check_kb_exit
    
    handle_s:
        move_down()
        draw_board(board)
        blit()
        j check_kb_exit
    
    check_kb_exit:
    pop($t1)
    pop($t0)
.end_macro

.text
    set_color_w(background_color)
    lw $a0 screen_size
    draw_background()
    
    set_x_i(0)
    set_y_i(0)
    draw_asset(asset_bottle_size, asset_bottle_data)
    draw_board(board)
    blit()
    generate_random_pill()
    tick_set_zero()
    game_loop:
        on_tick(1, check_kb_cont)
            check_kb()
        check_kb_cont:
        
        on_tick(256, remove_cont)
            remove_connected(board)
            remove_connected_horizontal(board)
            do_gravity(board)
            draw_board(board)
            blit()
        remove_cont:
        
        on_tick(1024, gen_pill_cont)
            # generate_random_pill()
            # draw_board(board)
            # blit()
        gen_pill_cont:
        
        tick_sleep()
    j game_loop