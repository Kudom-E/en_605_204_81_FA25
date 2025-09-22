@Program 2: String Output with Tabs - Enhanced with User Input
@This program demonstrates tab formatting with user input and validation
@Demonstrates tab formatting in ARM Assembly
@Written for 32-bit ARM Linux system using C library functions
@Author: [Emmanuel Kudom-Agyemang]
@Date: [09/20/2025]

@Make the main function visible to the linker
.global main

@Declare external functions
.extern printf
.extern scanf

@This section contains initialized data
.data

@Prompt message asking for a number
prompt_msg:
    .asciz "Please enter a number (0-1000): "

@Format string for scanf to read an integer
scanf_format:
    .asciz "%d"

@Error message for invalid input
error_msg:
    .asciz "Invalid input! Please enter a valid number (0-1000).\n"

@Success message
success_msg:
    .asciz "Tab formatting examples with your number:\n"

@Continue prompt message
continue_msg:
    .asciz "Would you like to try another number? (y/n): "

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

@Format string with tabs between text and numbers
@\t represents tab character, %d is placeholder for integer
tab_format:
    .asciz "Before\t%d\tAfter\n"

@Format string with multiple tabs and mixed content
multi_tab_format:
    .asciz "Text1\t%d\tText2\t%d\tText3\n"

@Format string with tabs around a character
char_tab_format:
    .asciz "Before\t%c\tAfter\n"

@Format string with tabs and multiple data types
mixed_format:
    .asciz "Number:\t%d\tCharacter:\t%c\tString:\t%s\n"

@Sample string for mixed format
sample_string:
    .asciz "Hello"

@This section contains the program's executable code
.text

@Main function - entry point of the program
main:
    @Save the link register and frame pointer
    push {fp, lr}
    mov fp, sp
    
    @Allocate space on stack for local variables
    @number variable (4 bytes), continue variable (1 byte)
    sub sp, sp, #12
    
    @Initialize number to -1 (invalid value for validation)
    mov r0, #-1
    str r0, [fp, #-8]
    
    @Initialize continue variable to 'y'
    mov r0, #121    @ASCII value for 'y'
    str r0, [fp, #-12]

@Main loop for number input
number_input_loop:
    @Print prompt message
    ldr r0, =prompt_msg
    bl printf
    
    @Read number from user input using scanf
    @scanf("%d", &number)
before_scanf_number:
    ldr r0, =scanf_format      @Load format string address into r0
    sub r1, fp, #8             @Load address of number variable into r1
    bl scanf                   @Call scanf function
after_scanf_number:
    @Check if scanf was successful (return value should be 1)
    cmp r0, #1
    bne input_error            @Branch to error handling if scanf failed
    
    @Load the number value for validation
    ldr r0, [fp, #-8]
    
    @Validate number range (0-1000)
    cmp r0, #0
    blt input_error            @Branch if number < 0
    cmp r0, #1000
    bgt input_error            @Branch if number > 1000
    
    @Number is valid, show tab examples
    ldr r0, =success_msg
    bl printf
    
    @Example 1: Simple tab between text and number
before_printf_tab1:
    ldr r0, =tab_format        @Load format string address into r0
    ldr r1, [fp, #-8]          @Load user's number into r1
    bl printf                  @Call printf function
after_printf_tab1:
    
    @Example 2: Multiple tabs with the same number
before_printf_tab2:
    ldr r0, =multi_tab_format  @Load format string address into r0
    ldr r1, [fp, #-8]          @Load user's number into r1
    ldr r2, [fp, #-8]          @Load user's number into r2 (same number twice)
    bl printf                  @Call printf function
after_printf_tab2:
    
    @Example 3: Tab around a character
before_printf_tab3:
    ldr r0, =char_tab_format   @Load format string address into r0
    mov r1, #65                @ASCII value for 'A' into r1
    bl printf                  @Call printf function
after_printf_tab3:
    
    @Example 4: Mixed data types with tabs
before_printf_tab4:
    ldr r0, =mixed_format      @Load format string address into r0
    ldr r1, [fp, #-8]          @Load user's number into r1
    mov r2, #66                @ASCII value for 'B' into r2
    ldr r3, =sample_string     @Address of "Hello" string into r3
    bl printf                  @Call printf function
after_printf_tab4:
    
    @Ask if user wants to continue
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
@Output: branches to number_input_loop or exit_program
validate_continue_input:
    @Load continue character and validate input
    ldr r0, [fp, #-12]
    cmp r0, #121    @Check for 'y'
    beq number_input_loop   @Branch to number_input_loop if 'y'
    cmp r0, #89     @Check for 'Y'
    beq number_input_loop   @Branch to number_input_loop if 'Y'
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

