@ Program 3a: Feet and Inches to Total Inches
@ Author: [Emmanuel Kudom-Agyemang]
@ Date: [09/25/2025]
@ Description: Reads feet and inches, converts to total inches
@ Formula: Total Inches = (Feet * 12) + Inches
@ Enhanced with input validation, loops, and debugging labels

.section .data
    prompt_feet:    .asciz "Enter feet: "
    prompt_inches:  .asciz "Enter inches: "
    scanf_format:   .asciz "%d"
    printf_result:  .asciz "Total inches: %d\n"
    error_msg:      .asciz "Invalid input! Please enter valid numbers.\n"
    success_msg:    .asciz "Conversion completed successfully!\n"
    continue_msg:   .asciz "Would you like to convert another measurement? (y/n): "
    invalid_continue_msg: .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"
    char_format:    .asciz " %c"
    clear_buffer_format: .asciz "%*[^\n]%*c"
    goodbye_msg:    .asciz "Goodbye!\n"
    
    @ Constants
    inches_per_foot: .word 12

.section .bss
    feet:           .space 4
    inches:         .space 4
    total_inches:   .space 4
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
    str r0, [r11, #-4]      @ feet
    str r0, [r11, #-8]      @ inches
    str r0, [r11, #-12]     @ total_inches
    
    @ Main conversion loop
    b measurement_input_loop

measurement_input_loop:
    @ Display feet prompt
    ldr r0, =prompt_feet
    bl printf
    
    @ Read feet input
    before_scanf_feet:
    ldr r0, =scanf_format
    ldr r1, =feet
    bl scanf
    
    after_scanf_feet:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load feet value
    ldr r0, =feet
    ldr r0, [r0]
    
    @ Validate feet range (0-1000)
    cmp r0, #0
    blt input_error
    cmp r0, #1000
    bgt input_error
    
    @ Display inches prompt
    ldr r0, =prompt_inches
    bl printf
    
    @ Read inches input
    before_scanf_inches:
    ldr r0, =scanf_format
    ldr r1, =inches
    bl scanf
    
    after_scanf_inches:
    @ Check if scanf was successful
    cmp r0, #1
    bne input_error
    
    @ Clear input buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @ Load inches value
    ldr r0, =inches
    ldr r0, [r0]
    
    @ Validate inches range (0-11)
    cmp r0, #0
    blt input_error
    cmp r0, #11
    bgt input_error
    
    @ Perform conversion: Total Inches = (Feet * 12) + Inches
    @ Step 1: Feet * 12
    ldr r0, =feet
    ldr r0, [r0]
    ldr r1, =inches_per_foot
    ldr r1, [r1]
    mul r2, r0, r1       @ r2 = Feet * 12
    
    @ Step 2: Add inches
    ldr r0, =inches
    ldr r0, [r0]
    add r2, r2, r0       @ r2 = (Feet * 12) + Inches
    
    @ Store result
    ldr r1, =total_inches
    str r2, [r1]
    
    @ Display result
    before_printf_result:
    ldr r0, =printf_result
    ldr r1, =total_inches
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
    b measurement_input_loop

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
    beq measurement_input_loop
    cmp r0, #89     @ Check for 'Y'
    beq measurement_input_loop
    
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

