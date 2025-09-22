@Program 3: Formatted String with Quotes
@This program asks user for input and outputs it with quotes
@Example: User enters "Hello world" -> Output: This is my output "Hello world"
@Enhanced with input validation and loop functionality
@Written for 32-bit ARM Linux system using C library functions
@Author: [Emmanuel Kudom-Agyemang]
@Date: [09/20/2025]

@Make the main function visible to the linker
.global main

@Declare external functions
.extern printf
.extern scanf
.extern strlen

@This section contains initialized data
.data

@Prompt message asking for user input
prompt_msg:
    .asciz "Please enter a message (max 50 characters): "

@Format string for scanf to read a line of text
scanf_format:
    .asciz " %50[^\n]"

@Format string for printf to display the message with quotes
@\" represents an escaped quote character
output_format:
    .asciz "This is my output \"%s\"\n"

@Error message for invalid input
error_msg:
    .asciz "Invalid input! Please enter a non-empty message.\n"

@Success message
success_msg:
    .asciz "Quote formatting example with your message:\n"

@Continue prompt message
continue_msg:
    .asciz "Would you like to enter another message? (y/n): "

@Invalid continue response message
invalid_continue_msg:
    .asciz "Invalid response. Please enter 'y' for yes or 'n' for no.\n"

@Format string for reading single character
char_format:
    .asciz " %c"

@Format string for clearing input buffer
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
    
    @Allocate space on stack for variables
    @-52: message string (50 chars + null terminator)
    @-56: continue character
    sub sp, sp, #56
    
    @Initialize continue character to 'y' to start the loop
    mov r0, #121              @ASCII value for 'y'
    str r0, [fp, #-56]        @Store 'y' in continue variable
    
@Main input loop
message_input_loop:
    @Print prompt message
    ldr r0, =prompt_msg
    bl printf
    
    @Read message from user input using scanf
    @scanf(" %50[^\n]", &message)
before_scanf_message:
    ldr r0, =scanf_format     @Load format string address into r0
    sub r1, fp, #52           @Load address of message variable into r1
    bl scanf                  @Call scanf function
after_scanf_message:
    @Check if scanf was successful (return value should be 1)
    cmp r0, #1
    bne input_error           @Branch to error handling if scanf failed
    
    @Clear any remaining newline from buffer
    ldr r0, =clear_buffer_format
    bl scanf
    
    @Message is valid, show quote examples
    ldr r0, =success_msg
    bl printf
    
    @Output the message with quotes
    @printf("This is my output \"%s\"\n", message)
before_printf_quotes:
    ldr r0, =output_format    @Load format string address into r0
    sub r1, fp, #52           @Load address of message into r1
    bl printf                 @Call printf function
after_printf_quotes:
    
    @Ask if user wants to continue
    ldr r0, =continue_msg
    bl printf
    
    @Read continue response
    ldr r0, =char_format
    sub r1, fp, #56
    bl scanf
    
    @Handle continue input validation
    b validate_continue_input

@Input error handling
input_error:
    @Clear the input buffer to remove leftover characters
    ldr r0, =clear_buffer_format
    bl scanf
    
    @Print error message
    ldr r0, =error_msg
    bl printf
    
    @Ask if user wants to continue
    ldr r0, =continue_msg
    bl printf
    
    @Read continue response
    ldr r0, =char_format
    sub r1, fp, #56
    bl scanf
    
    @Handle continue input validation
    b validate_continue_input

@Validate continue input
validate_continue_input:
    @Load the continue character
    ldr r0, [fp, #-56]
    
    @Check if user entered 'y' or 'Y' (continue)
    cmp r0, #121              @ASCII value for 'y'
    beq message_input_loop    @Branch back to input loop if 'y'
    cmp r0, #89               @ASCII value for 'Y'
    beq message_input_loop    @Branch back to input loop if 'Y'
    
    @Check if user entered 'n' or 'N' (exit)
    cmp r0, #110              @ASCII value for 'n'
    beq exit_program          @Branch to exit if 'n'
    cmp r0, #78               @ASCII value for 'N'
    beq exit_program          @Branch to exit if 'N'
    
    @Invalid input - print error and ask again
    ldr r0, =invalid_continue_msg
    bl printf
    
    @Ask again
    ldr r0, =continue_msg
    bl printf
    
    @Read continue response again
    ldr r0, =char_format
    sub r1, fp, #56
    bl scanf
    
    @Loop back to validation
    b validate_continue_input

@Exit program
exit_program:
    @Print goodbye message
    ldr r0, =goodbye_msg
    bl printf
    
    @Cleanup and exit
    b cleanup

@Cleanup function
cleanup:
    @Restore stack pointer
    mov sp, fp
    pop {fp, lr}
    
    @Exit program with system call
    mov r7, #1                @System call number for exit
    mov r0, #0                @Exit status (0 = success)
    swi 0                     @Make system call
    
    @Return from main function (backup)
    bx lr

