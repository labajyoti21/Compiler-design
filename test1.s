.section .data
    a:
    .long 0
    b:
    .long 0
    c:
    .long 0
    t1:
    .long 0
    output_msg:     .ascii "Value in RAX: %ld\n"   # Message format for printf
    output_msg_len: .equ 16  
.section .text
.global main

main:
    sub $16, %rsp
    
    mov a, %rax       # Load value of 'a' into %rax
    mov $5, %rax            # Move 5 into %rbx
    add %rbx, %rax          # Add 5 to the value of 'a'
    
    mov b, %rcx       # Load value of 'b' into %rcx
    mov $6, %rbx            # Move 6 into %rbx
    add %rbx, %rcx          # Add 6 to the value of 'b'
    
    add %rcx, %rax          # Add 'b' to the updated 'a'
    
    mov t1, %rdx      # Load value of 't1' into %rdx
    mov %rax, %rdx          # Move result into 't1'
    mov $1, %rax            # syscall number for sys_write
   
    mov $1, %rdi            # file descriptor 1 (stdout)
    lea output_msg(%rip), %rsi  # address of the message
    mov $output_msg_len, %rdx   # length of the message

    # Make syscall
    syscall
    mov $60, %rax           # Syscall number for exit
    xor %rdi, %rdi          # Return 0 status
    syscall                 # Execute syscall
