# Mark Mileyev
# mmileyev@ucsc.edu
# Lab 5 due Mar 2
# Section 01C Maxwell

########## Pseudocode ###########
# prompt and print arg string
# go to argument address
# convert ascii bytes to integer in for loop
# multiply them by 10 and add each time for integer conversion
# if negative then multiply by -1
# apply bitmask after conversion and iterate each bit
# since stored in binary, already 2sc
########## End Pseudocode ###########

.data 
prompt: .asciiz "User input number:\n"
newl: .asciiz "\n"
desc: .asciiz "This number in binary is:\n"

.text

main:
    ########## Prompt ###########
    li $v0, 4
    la $a0, prompt
    syscall
    ########## END Prompt ###########

    # holy FUCK this shit took me
    # 4 hours just to print the fucking argument
    li $v0, 4
    lw $a0, ($a1) # this is so fucked
    syscall

    ########## Newl ###########
    li $v0, 4
    la $a0, newl
    syscall
    ########## END Newl ###########

    ########## Prompt ###########
    li $v0, 4
    la $a0, desc
    syscall
    ########## END Prompt ###########

    lw	$t8, ($a1) # Load argument address into $t8 for conversion

    addi $a1, $a1, 0
    addi $t3, $zero, 10 # USED TO MULT. BY 10 IN SUMMATION OF INT
    addi $t4, $zero, 0 # USED TO STORE BITMASK VALUE
    addi $s0, $zero, 0 # USED TO STORE THE RUNNING SUM, MOVE TO s0
    addi $t6, $zero, 0 # mfLO
    addi $t7, $zero, -1 # USED TO MULT. BY -1 IF NEGATIVE
    addi $s7, $zero, 1073741824 # MY BITMASK
    addi $s6, $zero, 2 # USED TO DIVIDE BITMASK BY 2 EACH ITERATION
    addi $s5, $zero, 1 # STORE ONE

    convert_positive_int:
        beq  $a0, -48, convert_positive_binary # Check for end of string
        beq  $a0, -3, convert_negative_int # Check for negative sign
        lb $s1, ($t8)
        addi $s1,$s1,-48 # Convert loaded byte from ASCII
        la $a0, ($s1)

        blt $a0, 0, continue0 # If funky byte of input, continue

        mult $s0, $t3 # Mult running total by 10 
        mflo $t6
        move $s0, $t6
        add $s0, $s0, $a0 # Then add by next byte and those get mult by 10 next iteration

        #syscall
        addi $t8, $t8, 1

        continue0:
        addi $t0, $t0, 1
        j convert_positive_int

    convert_positive_binary:
    li  $v0, 1
    move $a0, $zero
    syscall

    positive_bitmasking:
        and $t4, $s0, $s7 # AND the bitmask with running total
        beqz  $t4, place_zero

        li  $v0, 1
        move $a0, $s5
        syscall
        beq $s7, $s5, sys_exit # If reaches end of bits
        div $s7, $s6 # Divide the bitmask by 2 to check the next bit
        mflo $t6 
        move $s7, $t6

        j positive_bitmasking

        place_zero: # if the bitmask and != 1, place a ZERO instead
        li  $v0, 1
        move $a0, $zero
        syscall
        beq $s7, $s5, sys_exit
        div $s7, $s6
        mflo $t6
        move $s7, $t6
        j positive_bitmasking

    sys_exit:
    move $a0, $s0         # the value in $s0 will be printed (DEBUG)
    #li   $v0, 1           # syscall 1 is print integer (DEBUG)
    #syscall
    ########## Exit ###########
    li $v0, 10 #(exit)
    syscall
    ########## Exit ###########


# CONVERT NEGATIVE HAS SAME LOGIC THROUGHOUT, BUT THE RUNNING TOTAL HAS BEEN MULTIPLIED BY -1 BEFOREHAND
    convert_negative_int:
        addi $t0, $a0, 1
        addi $a0, $a0, 1
        addi $t8, $t8, 1
        continue_convert_negative_int:
        beq  $a0, -48, convert_negative_binary
        lb $s1, ($t8)
        addi $s1,$s1,-48
        li $v0, 1
        la $a0, ($s1)

        blt $a0, 0, continue1

        mult $s0, $t3
        mflo $t6
        move $s0, $t6
        add $s0, $s0, $a0

        #syscall
        addi $t8, $t8, 1

        continue1:
        addi $t0, $t0, 1
        j continue_convert_negative_int

    convert_negative_binary:
    mult $s0, $t7
    mflo $t6
    move $s0, $t6

    li  $v0, 1
    move $a0, $s5
    syscall

    negative_bitmasking:
        and $t4, $s0, $s7
        beqz  $t4, place_zero1

        li  $v0, 1
        move $a0, $s5
        syscall
        beq $s7, $s5, sys_exit1
        div $s7, $s6
        mflo $t6
        move $s7, $t6

        j negative_bitmasking
        place_zero1:
        li  $v0, 1
        move $a0, $zero
        syscall
        beq $s7, $s5, sys_exit1
        div $s7, $s6
        mflo $t6
        move $s7, $t6
        j negative_bitmasking

    sys_exit1:
    move $a0, $s0         # the value in $s0 will be printed (DEBUG)
    #li   $v0, 1           # syscall 1 is print integer (DEBUG)
    #syscall
    ########## Exit ###########
    li $v0, 10 #(exit)
    syscall
    ########## Exit ###########
