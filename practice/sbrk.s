extern printf
extern puts
extern sbrk

section .text
global _start

_start:
  mov rax, 12
  mov rdi, 0
  syscall

  mov rdi, format
  mov rsi, rax
  call printf

  mov rax, 60
  mov rdi, 0
  syscall

section .data
  format db "%p", 10, 0
