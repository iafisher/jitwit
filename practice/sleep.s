section .text
global _start

_start:
  mov rax, 2
  call sleep

  mov rdi, 0
  mov rax, 60
  syscall

sleep:
  push rbp
  mov rbp, rsp
  sub rsp, 16

  mov qword [rbp-8], 0
  mov qword [rbp-16], rax

  mov rdi, 0
  mov rsi, 0
  lea rdx, [rbp-16]
  lea r10, [rbp-16]
  mov rax, 230
  syscall

  add rsp, 16
  pop rbp
  ret
