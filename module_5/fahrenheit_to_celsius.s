@ Program 1b: Fahrenheit to Celsius Conversion
@ Author: [Emmanuel Kudom-Agyemang]
@ Date: [09/25/2025]
@ Description: Converts temperature from Fahrenheit to Celsius
@ Formula: C = (F - 32) * 5/9
@ Enhanced with input validation, loops, and debugging labels

.section .data
    prompt_msg:     .asciz "Enter temperature in Fahrenheit: "
    scanf_format:   .asciz "%d"
    printf_format:  .asciz "Temperature in Celsius: %d\n"
    error_msg:      .asciz "Invalid input! Please enter a valid temperature.\n"
    success_msg:    .asciz "Conversion completed successfully!\n"
    continue_msg:   .asciz "Would you like to convert another temperature? (y/n): "
    invalid_continue_msg: .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"
    char_format:    .asciz " %c"
    clear_buffer_format: .asciz "%*[^\n]%*c"
    goodbye_msg:    .asciz "Goodbye!\n"
    
    @ Constants for conversion
    fahrenheit_offset: .word 32
    multiplier:     .word 5
    divisor:        .word 9

.section .bss
    fahrenheit:     .space 4
    celsius:        .space 4
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
    str r0, [r11, #-4]      @ fahrenheit
    str r0, [r11, #-8]      @ celsius
    
    @ Main conversion loop
    b fahrenheit_input_loop

fahrenheit_input_loop:
    @ Display prompt
    ldr r0, =prompt_msg
    bl printf
    
    @ Read Fahrenheit input
    before_scanf_fahrenheit:
    ldr r0, =scanf_format
    ldr r1, =fahrenheit
    bl scanf
    
    after_scanf_fahrenheit:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load Fahrenheit value
    ldr r0, =fahrenheit
    ldr r0, [r0]
    
    @ Validate input range (reasonable temperature range)
    @ Check for reasonable temperature range (-300 to 2000)
    cmp r0, #-300        @ Lower bound
    blt input_error
    cmp r0, #2000        @ Upper bound
    bgt input_error
    
    @ Perform conversion: C = (F - 32) * 5/9
    @ Step 1: F - 32
    ldr r1, =fahrenheit_offset
    ldr r1, [r1]
    sub r2, r0, r1       @ r2 = F - 32
    
    @ Step 2: (F - 32) * 5
    ldr r1, =multiplier
    ldr r1, [r1]
    mul r3, r2, r1       @ r3 = (F - 32) * 5
    
    @ Step 3: ((F - 32) * 5) / 9
    ldr r1, =divisor
    ldr r1, [r1]
    mov r4, r1
    bl divide            @ r0 = ((F - 32) * 5) / 9
    
    @ Store result
    ldr r1, =celsius
    str r0, [r1]
    
    @ Display result
    before_printf_result:
    ldr r0, =printf_format
    ldr r1, =celsius
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
    b fahrenheit_input_loop

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
    beq fahrenheit_input_loop
    cmp r0, #89     @ Check for 'Y'
    beq fahrenheit_input_loop
    
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

@ Division function: r0 = r3 / r4 (signed division)
divide:
    push {r11, lr}
    mov r11, sp
    
    @ Handle division by zero
    cmp r4, #0
    beq divide_error
    
    @ Check if result should be negative
    mov r0, #0          @ result
    mov r1, #0          @ negative flag
    
    @ Check if dividend is negative
    cmp r3, #0
    bge check_divisor
    mov r1, #1          @ set negative flag
    neg r3, r3          @ make dividend positive
    
    check_divisor:
    @ Check if divisor is negative
    cmp r4, #0
    bge start_division
    eor r1, r1, #1      @ toggle negative flag
    neg r4, r4          @ make divisor positive
    
    start_division:
    @ Division loop (now both numbers are positive)
    divide_loop:
        cmp r3, r4
        blt divide_done
        sub r3, r3, r4
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

