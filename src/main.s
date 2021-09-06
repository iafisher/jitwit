section .text
global _start

_start:
  mov rdi, 1
  mov rsi, hello
  mov rdx, 14
  mov rax, 1
  syscall

  mov rdi, 0
  mov rax, 60
  syscall

section .data
  hello: db "Hello, world!", 10
