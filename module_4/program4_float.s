@Program 4: Floating Point Input/Output (Extra Credit) - Enhanced
@This program demonstrates floating point input and output in ARM Assembly
@Note: scanf %f reads a float (32 bits), printf %f outputs a double (64 bits)
@
@Input Handling: This program accepts both integers and floats as valid input
@- User can enter "100" (integer) and it will be converted to 100.000000 (float)
@- User can enter "3.14159" (float) and it will be stored as 3.141590
@- This is standard behavior: scanf("%f") automatically converts integers to floats
@- We do NOT reject integer input - this would be user-unfriendly
@
@Floating Point Conversion: This version uses printf's automatic conversion
@- Some ARM systems don't support VFP instructions in ARM mode
@- printf automatically handles float-to-double conversion when needed
@- This approach is more portable across different ARM implementations
@
@Written for 32-bit ARM Linux system using C library functions
@Author: [Emmanuel Kudom-Agyemang]
@Date: [09/20/2025]

.global main

.extern printf
.extern scanf

.data

prompt_msg:
    .asciz "Please enter a floating point number: "

@scanf format reads a double (64-bit)
scanf_format:
    .asciz "%lf"

@printf uses %f for double
printf_format:
    .asciz "You entered: %f\n"

error_msg:
    .asciz "Invalid input! Please enter a valid floating point number.\n"

success_msg:
    .asciz "Floating point number processed successfully!\n"

continue_msg:
    .asciz "Would you like to enter another floating point number? (y/n): "

invalid_continue_msg:
    .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"

char_format:
    .asciz " %c"

clear_buffer_format:
    .asciz "%*[^\n]%*c"

goodbye_msg:
    .asciz "Goodbye!\n"

.text

main:
    push {fp, lr}
    mov fp, sp

    @Allocate 12 bytes for locals: [fp-12] = continue char (word), [fp-8] and [fp-4] = double (8 bytes)
    sub sp, sp, #12

    @Initialize continue variable to 'y' (ASCII 121)
    mov r0, #121
    str r0, [fp, #-12]

float_input_loop:
    @Print prompt
    ldr r0, =prompt_msg
    bl printf

    @Read a double into the stack slot at [fp-8] (8 bytes: [fp-8] = low 4 bytes, [fp-4] = high 4 bytes)
before_scanf_double:
    ldr r0, =scanf_format
    sub r1, fp, #8          @ <-- FIXED: pass address of double (fp - 8), not fp - 12
    bl scanf
after_scanf_double:

    @Check scanf return (should be 1)
    cmp r0, #1
    bne input_error

    @Clear any remaining newline from buffer (no destination required)
    ldr r0, =clear_buffer_format
    bl scanf

    @Print the floating point number as double
before_printf_double:
    ldr r0, =printf_format
    ldr r1, [fp, #-8]       @ load first 4 bytes of double
    ldr r2, [fp, #-4]       @ load second 4 bytes of double
    str r2, [sp, #-4]!      @ push second word
    str r1, [sp, #-4]!      @ push first word
    bl printf
    add sp, sp, #8
after_printf_double:

    @Success message
    ldr r0, =success_msg
    bl printf

    @Ask to continue
    ldr r0, =continue_msg
    bl printf

    @Read continue char into [fp-12]
    ldr r0, =char_format
    sub r1, fp, #12
    bl scanf

    b validate_continue_input

input_error:
    @Clear buffer
    ldr r0, =clear_buffer_format
    bl scanf

    ldr r0, =error_msg
    bl printf

    ldr r0, =continue_msg
    bl printf

    ldr r0, =char_format
    sub r1, fp, #12
    bl scanf

    b validate_continue_input

validate_continue_input:
    ldr r0, [fp, #-12]    @ load the continue char word
    cmp r0, #121
    beq float_input_loop
    cmp r0, #89
    beq float_input_loop
    cmp r0, #110
    beq exit_program
    cmp r0, #78
    beq exit_program

    ldr r0, =invalid_continue_msg
    bl printf

    ldr r0, =continue_msg
    bl printf

    ldr r0, =char_format
    sub r1, fp, #12
    bl scanf

    b validate_continue_input

exit_program:
    ldr r0, =goodbye_msg
    bl printf
    b cleanup

cleanup:
    mov sp, fp
    pop {fp, lr}

    mov r7, #1
    mov r0, #0
    swi 0

    bx lr
