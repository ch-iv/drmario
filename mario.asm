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
    color_black: .word 0x000
    color_purple: .word 0x5500b2
    color_dark_purple: .word 0x2e0061
    .include "asset_bottle.c"
    trolo: .space 100000

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
    
    lw $t2 disp_addr
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

.macro draw_capsule()
    push($s0)
    push($s1)
    push($t0)
    
    set_color_w(dark_blue)
    li $a0 16
    draw_square($a0)
    
    set_color_w(turquoise)
    li $t0 16
    sub $s0 $s0 $t0
    li $a0 16
    draw_square($a0)
    
    pop($t0)
    pop($s1)
    pop($s0)
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

.text
    set_color_w(background_color)
    lw $a0 screen_size
    draw_background()
        
    set_x_i(0)
    set_y_i(0)
    draw_asset(asset_bottle_size, asset_bottle_data)
    
   


