@Program 1: Age Input/Output with Robust Validation
@This program asks a user for their age, validates the input, and outputs it
@Includes robust input validation for continue prompts
@Author: [Emmanuel Kudom-Agyemang]
@Date: [09/20/2025]

@Make the main function visible to the linker
.global main

@Declare external functions
.extern printf
.extern scanf

@This section contains initialized data
.data

@Prompt message asking for user's age
prompt_msg:
    .asciz "Please enter your age: "

@Format string for scanf to read an integer
scanf_format:
    .asciz "%d"

@Format string for printf to display the age
printf_format:
    .asciz "You entered: %d\n"

@Error message for invalid input
error_msg:
    .asciz "Invalid input! Please enter a valid age (0-150).\n"

@Success message
success_msg:
    .asciz "Thank you for entering your age!\n"

@Continue prompt message
continue_msg:
    .asciz "Would you like to enter another age? (y/n): "

@Invalid continue input message
invalid_continue_msg:
    .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"

@Format string for scanf to read a character
char_format:
    .asciz " %c"

@Format string to clear input buffer
clear_buffer_format:
    .asciz "%*[^\n]%*c"

@Goodbye message
goodbye_msg:
    .asciz "Goodbye!\n"

@This section contains the program's executable code
.text

@Main function - entry point of the program
main:
    @Save the link register and frame pointer
    push {fp, lr}
    mov fp, sp
    
    @Allocate space on stack for local variables
    @age variable (4 bytes), continue variable (1 byte)
    sub sp, sp, #12
    
    @Initialize age to -1 (invalid value for validation)
    mov r0, #-1
    str r0, [fp, #-8]
    
    @Initialize continue variable to 'y'
    mov r0, #121    @ASCII value for 'y'
    str r0, [fp, #-12]

@Main loop for age input
age_input_loop:
    @Print prompt message
    ldr r0, =prompt_msg
    bl printf
    
    @Read age from user input using scanf
    @scanf("%d", &age)
before_scanf_age:
    ldr r0, =scanf_format      @Load format string address into r0
    sub r1, fp, #8             @Load address of age variable into r1
    bl scanf                   @Call scanf function
after_scanf_age:
    @Check if scanf was successful (return value should be 1)
    cmp r0, #1
    bne input_error            @Branch to error handling if scanf failed
    
    @Load the age value for validation
    ldr r0, [fp, #-8]
    
    @Validate age range (0-150)
    cmp r0, #0
    blt input_error            @Branch if age < 0
    cmp r0, #150
    bgt input_error            @Branch if age > 150
    
    @Age is valid, print it
    ldr r0, =printf_format     @Load printf format string
    ldr r1, [fp, #-8]          @Load age value as second parameter
    bl printf                  @Call printf function
    
    @Print success message
before_printf_success:
    ldr r0, =success_msg
    bl printf
after_printf_success:
    
    @Ask if user wants to continue
before_printf_continue:
    ldr r0, =continue_msg
    bl printf
after_printf_continue:
    
    @Read continue response
before_scanf_continue:
    ldr r0, =char_format
    sub r1, fp, #12
    bl scanf
after_scanf_continue:
    
    @Clear any remaining characters from buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @Handle continue input validation
    b validate_continue_input

@Error handling for invalid input
input_error:
    @Clear the input buffer to remove leftover characters
    ldr r0, =clear_buffer_format
    bl scanf
    
    @Print error message
    ldr r0, =error_msg
    bl printf
    
    @Ask if user wants to continue after error
    ldr r0, =continue_msg
    bl printf
    
    @Read continue response
    ldr r0, =char_format
    sub r1, fp, #12
    bl scanf
    
    @Clear any remaining characters from buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @Handle continue input validation
    b validate_continue_input

@Function to validate continue input - keeps asking until valid input
@Input: continue character in [fp, #-12]
@Output: branches to age_input_loop or exit_program
validate_continue_input:
    @Load continue character and validate input
    ldr r0, [fp, #-12]
    cmp r0, #121    @Check for 'y'
    beq age_input_loop   @Branch to age_input_loop if 'y'
    cmp r0, #89     @Check for 'Y'
    beq age_input_loop   @Branch to age_input_loop if 'Y'
    cmp r0, #110    @Check for 'n'
    beq exit_program @Branch to exit if 'n'
    cmp r0, #78     @Check for 'N'
    beq exit_program @Branch to exit if 'N'
    
    @Invalid input - show error and ask again
    ldr r0, =invalid_continue_msg
    bl printf
    
    @Ask the continue question again
    ldr r0, =continue_msg
    bl printf
    
    @Read continue response again
    ldr r0, =char_format
    sub r1, fp, #12
    bl scanf
    
    @Clear any remaining characters from buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @Keep validating until we get valid input
    b validate_continue_input

@Exit program label
exit_program:
    @Print goodbye and exit
    ldr r0, =goodbye_msg
    bl printf
    b cleanup

@Cleanup and exit
cleanup:
    @Restore stack pointer
    mov sp, fp
    pop {fp, lr}
    
    @Exit program with system call
    mov r7, #1      @System call number for exit
    mov r0, #0      @Exit status (0 = success)
    swi 0           @Make system call
    
    @Return from main function (backup)
    bx lr
