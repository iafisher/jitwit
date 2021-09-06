extern printf

section .text
global _start

_start:
  ; mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0)
  mov rdi, 0
  mov rsi, 4096
  mov rdx, 3
  mov r10, 34
  mov r8, -1
  mov r9, 0
  mov rax, 9
  syscall

  mov rsi, mmap_error
  mov rdx, 14
  cmp rax, -1
  je error

  ; save buffer in rbx
  mov rbx, rax

  ; copy code to buffer
  mov r12, rbx
  mov byte [r12],    0xbf
  mov byte [r12+1],  0x2a
  mov byte [r12+2],  0x00
  mov byte [r12+3],  0x00
  mov byte [r12+4],  0x00
  mov byte [r12+5],  0xb8
  mov byte [r12+6],  0x3c
  mov byte [r12+7],  0x00
  mov byte [r12+8],  0x00
  mov byte [r12+9],  0x00
  mov byte [r12+10], 0x0f
  mov byte [r12+11], 0x05

  ; mprotect(buffer, 4096, PROT_READ|PROT_EXEC)
  mov rdi, rbx
  mov rsi, 4096
  mov rdx, 5
  mov rax, 10
  syscall

  mov rsi, mprotect_error
  mov rdx, 18
  cmp rax, 0
  jne error

  ; call buffer as a function pointer
  call rbx

  ; exit(0)
  mov rdi, 0
  mov rax, 60
  syscall

error:
  ; write(stdin, error_message, error_message_length)
  mov rdi, 2
  mov rax, 1
  syscall

  ; exit(1)
  mov rdi, 1
  mov rax, 60
  syscall


section .data
  mmap_error db "mmap() failed", 10, 0
  mprotect_error db "mprotect() failed", 10, 0
