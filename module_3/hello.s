@This program prints "Hello, World!" to the console on a 32-bit ARM Linux system.
@Using a direct system call

@This makes the _start label visible to the linker telling the program where execution should begin
.global _start

@This is used to store initialized data
.data

@ascii creates a string of characters and "\n" is the newline character
msg:
    .ascii "Hello, World!\n"

@This calculates the length of the string. The '.' represents the current address, so we subtract starting address from 
len = . - msg

@The .text section contains the programs code
.text
@ System call to write string to stdout
_start:
    @Set register r7 to 4. System call for 'sys_write'
    mov r7, #4
    
    @Set register r0 to 1. File descriptor for 'stdout' 
    mov r0, #1

    @Load address of 'msg' string into register r1
    ldr r1, =msg

    @load address of 'len' value into register r2, telling the kernel how many bytes to write
    ldr r2, =len

    @Execute system call. The 'swi' instruction transfers control to the kernel which executes 'sys_write'
    swi 0

    @Set register r7 to 1. System call number for 'sys_exit' which tells the kernel to terminate program
    mov r7, #1

    @Execute system call to exit
    swi 0

