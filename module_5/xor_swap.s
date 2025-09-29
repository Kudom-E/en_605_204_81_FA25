@ Program 5: XOR Swap (Extra Credit)
@ Author: Student
@ Date: Fall 2025
@ Description: Swaps two registers using XOR operations without temporary variable
@ Method: a = a ^ b; b = a ^ b; a = a ^ b (using EOR instruction)
@ Enhanced with input validation, loops, and debugging labels

.section .data
    prompt_num1:    .asciz "Enter first number (no commas): "
    prompt_num2:    .asciz "Enter second number (no commas): "
    scanf_format:   .asciz "%d"
    printf_before:  .asciz "Before swap: a = %d, b = %d\n"
    printf_after:   .asciz "After swap:  a = %d, b = %d\n"
    error_msg:      .asciz "Invalid input! Please enter valid numbers.\n"
    success_msg:    .asciz "XOR swap completed successfully!\n"
    continue_msg:   .asciz "Would you like to swap another pair? (y/n): "
    invalid_continue_msg: .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"
    char_format:    .asciz " %c"
    clear_buffer_format: .asciz "%*[^\n]%*c"
    goodbye_msg:    .asciz "Goodbye!\n"

.section .bss
    num1:           .space 4
    num2:           .space 4
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
    sub sp, sp, #8
    
    @ Initialize variables
    mov r0, #0
    str r0, [r11, #-4]      @ num1
    str r0, [r11, #-8]      @ num2
    
    @ Main swap loop
    b number_input_loop

number_input_loop:
    @ Display first number prompt
    ldr r0, =prompt_num1
    bl printf
    
    @ Read first number
    before_scanf_num1:
    ldr r0, =scanf_format
    ldr r1, =num1
    bl scanf
    
    after_scanf_num1:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load first number
    ldr r0, =num1
    ldr r0, [r0]
    
    @ Validate first number range
    ldr r1, =#-2147483648    @ Minimum 32-bit integer
    cmp r0, r1
    blt input_error
    ldr r1, =#2147483647     @ Maximum 32-bit integer
    cmp r0, r1
    bgt input_error
    
    @ Display second number prompt
    ldr r0, =prompt_num2
    bl printf
    
    @ Read second number
    before_scanf_num2:
    ldr r0, =scanf_format
    ldr r1, =num2
    bl scanf
    
    after_scanf_num2:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load second number
    ldr r0, =num2
    ldr r0, [r0]
    
    @ Validate second number range
    ldr r1, =#-2147483648    @ Minimum 32-bit integer
    cmp r0, r1
    blt input_error
    ldr r1, =#2147483647     @ Maximum 32-bit integer
    cmp r0, r1
    bgt input_error
    
    @ Display numbers before swap
    before_printf_before:
    ldr r0, =printf_before
    ldr r1, =num1
    ldr r1, [r1]
    ldr r2, =num2
    ldr r2, [r2]
    bl printf
    
    after_printf_before:
    @ Perform XOR swap: a = a ^ b; b = a ^ b; a = a ^ b
    @ Load numbers into registers
    ldr r0, =num1
    ldr r0, [r0]            @ r0 = a
    ldr r1, =num2
    ldr r1, [r1]            @ r1 = b
    
    @ Step 1: a = a ^ b
    eor r0, r0, r1          @ r0 = a ^ b
    
    @ Step 2: b = a ^ b (now a is a^b, so this gives original a)
    eor r1, r0, r1          @ r1 = (a^b) ^ b = a
    
    @ Step 3: a = a ^ b (now a is a^b, b is original a, so this gives original b)
    eor r0, r0, r1          @ r0 = (a^b) ^ a = b
    
    @ Store swapped values back
    ldr r2, =num1
    str r0, [r2]            @ num1 = original b
    ldr r2, =num2
    str r1, [r2]            @ num2 = original a
    
    @ Display numbers after swap
    before_printf_after:
    ldr r0, =printf_after
    ldr r1, =num1
    ldr r1, [r1]
    ldr r2, =num2
    ldr r2, [r2]
    bl printf
    
    after_printf_after:
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
    b number_input_loop

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
    beq number_input_loop
    cmp r0, #89     @ Check for 'Y'
    beq number_input_loop
    
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
    
    @ Load the new continue character and validate it
    ldr r0, =continue_char
    ldr r0, [r0]
    
    @ Check for 'y' or 'Y' (ASCII values)
    cmp r0, #121    @ Check for 'y'
    beq number_input_loop
    cmp r0, #89     @ Check for 'Y'
    beq number_input_loop
    
    @ Check for 'n' or 'N' (ASCII values)
    cmp r0, #110    @ Check for 'n'
    beq exit_program
    cmp r0, #78     @ Check for 'N'
    beq exit_program
    
    @ Still invalid - ask again
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

