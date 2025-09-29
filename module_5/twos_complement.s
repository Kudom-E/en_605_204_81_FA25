@ Program 2: 2's Complement (Negative Value)
@ Author: [Emmanuel Kudom-Agyemang]
@ Date: [09/25/2025]
@ Description: Reads an integer and outputs its negative value using 2's complement
@ Method: 2's complement = 1's complement + 1 (using MVN operation)
@ Enhanced with input validation, loops, and debugging labels

.section .data
    prompt_msg:     .asciz "Enter an integer number (no commas): "
    scanf_format:   .asciz "%d"
    printf_original: .asciz "Original number: %d\n"
    printf_negative: .asciz "Negative value (2's complement): %d\n"
    error_msg:      .asciz "Invalid input! Please enter a valid integer.\n"
    success_msg:    .asciz "2's complement operation completed successfully!\n"
    continue_msg:   .asciz "Would you like to try another number? (y/n): "
    invalid_continue_msg: .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"
    char_format:    .asciz " %c"
    clear_buffer_format: .asciz "%*[^\n]%*c"
    goodbye_msg:    .asciz "Goodbye!\n"

.section .bss
    original_num:   .space 4
    negative_num:   .space 4
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
    str r0, [r11, #-4]      @ original_num
    str r0, [r11, #-8]      @ negative_num
    
    @ Main conversion loop
    b number_input_loop

number_input_loop:
    @ Display prompt
    ldr r0, =prompt_msg
    bl printf
    
    @ Read integer input
    before_scanf_number:
    ldr r0, =scanf_format
    ldr r1, =original_num
    bl scanf
    
    after_scanf_number:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load original number
    ldr r0, =original_num
    ldr r0, [r0]
    
    @ Validate input range (reasonable integer range)
    ldr r1, =#-2147483648    @ Minimum 32-bit integer
    cmp r0, r1
    blt input_error
    ldr r1, =#2147483647     @ Maximum 32-bit integer
    cmp r0, r1
    bgt input_error
    
    @ Display original number
    before_printf_original:
    ldr r0, =printf_original
    ldr r1, =original_num
    ldr r1, [r1]
    bl printf
    
    after_printf_original:
    @ Perform 2's complement operation
    @ Step 1: 1's complement using MVN (bitwise NOT)
    ldr r0, =original_num
    ldr r0, [r0]
    mvn r1, r0               @ r1 = 1's complement (bitwise NOT)
    
    @ Step 2: Add 1 to get 2's complement
    add r1, r1, #1           @ r1 = 2's complement (negative value)
    
    @ Store result
    ldr r2, =negative_num
    str r1, [r2]
    
    @ Display negative value
    before_printf_negative:
    ldr r0, =printf_negative
    ldr r1, =negative_num
    ldr r1, [r1]
    bl printf
    
    after_printf_negative:
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

