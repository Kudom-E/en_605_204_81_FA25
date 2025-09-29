@ Program 3b: Total Inches to Feet and Inches
@ Author: [Emmanuel Kudom-Agyemang]
@ Date: [09/28/2025]
@ Description: Reads total inches, converts to feet and inches
@ Formula: Feet = Total Inches / 12, Inches = Total Inches % 12
@ Enhanced with input validation, loops, and debugging labels

.section .data
    prompt_msg:     .asciz "Enter total inches: "
    scanf_format:   .asciz "%d"
    printf_result:  .asciz "Result: %d feet and %d inches\n"
    error_msg:      .asciz "Invalid input! Please enter a valid number.\n"
    success_msg:    .asciz "Conversion completed successfully!\n"
    continue_msg:   .asciz "Would you like to convert another measurement? (y/n): "
    invalid_continue_msg: .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"
    char_format:    .asciz " %c"
    clear_buffer_format: .asciz "%*[^\n]%*c"
    goodbye_msg:    .asciz "Goodbye!\n"
    
    @ Constants
    inches_per_foot: .word 12

.section .bss
    total_inches:   .space 4
    feet:           .space 4
    inches:         .space 4
    continue_char:  .space 1

.section .text
.global main

@ External function declarations
.extern printf
.extern scanf

main:
    @ Function prologue
    push {r11, lr}
    mov r11, sp
    sub sp, sp, #12
    
    @ Initialize variables
    mov r0, #0
    str r0, [r11, #-4]      @ total_inches
    str r0, [r11, #-8]      @ feet
    str r0, [r11, #-12]     @ inches
    
    @ Main conversion loop
    b inches_input_loop

inches_input_loop:
    @ Display prompt
    ldr r0, =prompt_msg
    bl printf
    
    @ Read total inches input
    before_scanf_inches:
    ldr r0, =scanf_format
    ldr r1, =total_inches
    bl scanf
    
    after_scanf_inches:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load total inches value
    ldr r0, =total_inches
    ldr r0, [r0]
    
    @ Validate input range (0-2000)
    cmp r0, #0
    blt input_error
    cmp r0, #2000
    bgt input_error
    
    @ Perform conversion: Feet = Total Inches / 12, Inches = Total Inches % 12
    @ Step 1: Calculate feet (division)
    ldr r1, =inches_per_foot
    ldr r1, [r1]
    mov r2, r0              @ r2 = total_inches
    mov r3, r1              @ r3 = 12
    bl divide               @ r0 = total_inches / 12
    
    @ Store feet result
    ldr r1, =feet
    str r0, [r1]
    
    @ Step 2: Calculate inches (remainder)
    @ r2 still contains total_inches, r3 still contains 12
    bl remainder            @ r0 = total_inches % 12
    
    @ Store inches result
    ldr r1, =inches
    str r0, [r1]
    
    @ Display result
    before_printf_result:
    ldr r0, =printf_result
    ldr r1, =feet
    ldr r1, [r1]
    ldr r2, =inches
    ldr r2, [r2]
    bl printf
    
    after_printf_result:
    @ Display success message
    ldr r0, =success_msg
    bl printf
    
    @ Ask if user wants to continue
    b validate_continue_input

input_error:
    @ Display error message
    ldr r0, =error_msg
    bl printf
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Return to input loop
    b inches_input_loop

validate_continue_input:
    @ Display continue prompt
    ldr r0, =continue_msg
    bl printf
    
    @ Read continue response
    before_scanf_continue:
    ldr r0, =char_format
    ldr r1, =continue_char
    bl scanf
    
    after_scanf_continue:
    @ Clear any remaining characters from buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load continue character and validate input
    ldr r0, =continue_char
    ldr r0, [r0]
    
    @ Check for 'y' or 'Y' (ASCII values)
    cmp r0, #121    @ Check for 'y'
    beq inches_input_loop
    cmp r0, #89     @ Check for 'Y'
    beq inches_input_loop
    
    @ Check for 'n' or 'N' (ASCII values)
    cmp r0, #110    @ Check for 'n'
    beq exit_program
    cmp r0, #78     @ Check for 'N'
    beq exit_program
    
    @ Invalid input - show error and ask again
    ldr r0, =invalid_continue_msg
    bl printf
    
    @ Ask the continue question again
    ldr r0, =continue_msg
    bl printf
    
    @ Read continue response again
    ldr r0, =char_format
    ldr r1, =continue_char
    bl scanf
    
    @ Clear any remaining characters from buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Keep validating until we get valid input
    b validate_continue_input

exit_program:
    @ Display goodbye message
    ldr r0, =goodbye_msg
    bl printf
    
    @ Clean up and exit
    b cleanup

cleanup:
    @ Restore stack
    mov sp, r11
    pop {r11, lr}
    
    @ System exit
    mov r7, #1
    mov r0, #0
    swi 0

@ Division function: r0 = r2 / r3 (signed division)
divide:
    push {r11, lr}
    mov r11, sp
    
    @ Handle division by zero
    cmp r3, #0
    beq divide_error
    
    @ Check if result should be negative
    mov r0, #0          @ result
    mov r1, #0          @ negative flag
    
    @ Check if dividend is negative
    cmp r2, #0
    bge check_divisor
    mov r1, #1          @ set negative flag
    neg r2, r2          @ make dividend positive
    
    check_divisor:
    @ Check if divisor is negative
    cmp r3, #0
    bge start_division
    eor r1, r1, #1      @ toggle negative flag
    neg r3, r3          @ make divisor positive
    
    start_division:
    @ Division loop (now both numbers are positive)
    divide_loop:
        cmp r2, r3
        blt divide_done
        sub r2, r2, r3
        add r0, r0, #1
        b divide_loop
    
    divide_done:
    @ Apply negative sign if needed
    cmp r1, #0
    beq divide_return
    neg r0, r0
    
    divide_return:
    pop {r11, lr}
    bx lr
    
    divide_error:
    mov r0, #0
    pop {r11, lr}
    bx lr

@ Remainder function: r0 = r2 % r3 (signed remainder)
remainder:
    push {r11, lr}
    mov r11, sp
    
    @ Handle division by zero
    cmp r3, #0
    beq remainder_error
    
    @ Store original dividend for sign
    mov r1, r2
    
    @ Make dividend positive
    cmp r2, #0
    bge make_divisor_positive
    neg r2, r2
    
    make_divisor_positive:
    @ Make divisor positive
    cmp r3, #0
    bge start_remainder
    neg r3, r3
    
    start_remainder:
    @ Remainder loop (now both numbers are positive)
    remainder_loop:
        cmp r2, r3
        blt remainder_done
        sub r2, r2, r3
        b remainder_loop
    
    remainder_done:
    @ Apply sign of original dividend
    cmp r1, #0
    bge remainder_return
    neg r2, r2
    
    remainder_return:
    mov r0, r2
    pop {r11, lr}
    bx lr
    
    remainder_error:
    mov r0, #0
    pop {r11, lr}
    bx lr

