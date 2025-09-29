@ Program 4: Multiply by 10 using Left Shifts
@ Author: [Emmanuel Kudom-Agyemang]
@ Date: [09/28/2025]
@ Description: Reads a number and multiplies by 10 using left shifts and add
@ Formula: x * 10 = x * 8 + x * 2 = (x << 3) + (x << 1)
@ Enhanced with input validation, loops, and debugging labels

.section .data
    prompt_msg:     .asciz "Enter a number to multiply by 10 (no commas): "
    scanf_format:   .asciz "%d"
    printf_original: .asciz "Original number: %d\n"
    printf_result:  .asciz "Number multiplied by 10: %d\n"
    error_msg:      .asciz "Invalid input! Please enter a valid number.\n"
    success_msg:    .asciz "Multiplication completed successfully!\n"
    continue_msg:   .asciz "Would you like to multiply another number? (y/n): "
    invalid_continue_msg: .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"
    char_format:    .asciz " %c"
    clear_buffer_format: .asciz "%*[^\n]%*c"
    goodbye_msg:    .asciz "Goodbye!\n"

.section .bss
    original_num:   .space 4
    result:         .space 4
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
    str r0, [r11, #-8]      @ result
    
    @ Main multiplication loop
    b number_input_loop

number_input_loop:
    @ Display prompt
    ldr r0, =prompt_msg
    bl printf
    
    @ Read number input
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
    ldr r1, =#-214748364    @ Minimum to avoid overflow when * 10
    cmp r0, r1
    blt input_error
    ldr r1, =#214748364     @ Maximum to avoid overflow when * 10
    cmp r0, r1
    bgt input_error
    
    @ Display original number
    before_printf_original:
    ldr r0, =printf_original
    ldr r1, =original_num
    ldr r1, [r1]
    bl printf
    
    after_printf_original:
    @ Perform multiplication by 10 using shifts: x * 10 = (x << 3) + (x << 1)
    @ Step 1: x << 3 (multiply by 8)
    ldr r0, =original_num
    ldr r0, [r0]
    mov r1, r0, lsl #3      @ r1 = x * 8 (left shift by 3)
    
    @ Step 2: x << 1 (multiply by 2)
    mov r2, r0, lsl #1      @ r2 = x * 2 (left shift by 1)
    
    @ Step 3: Add the results
    add r3, r1, r2          @ r3 = (x * 8) + (x * 2) = x * 10
    
    @ Store result
    ldr r1, =result
    str r3, [r1]
    
    @ Display result
    before_printf_result:
    ldr r0, =printf_result
    ldr r1, =result
    ldr r1, [r1]
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

