section .text
global _start

_start:
  mov rdi, 6
  call alloc

  mov byte [rax], 'h'
  mov byte [rax+1], 'e'
  mov byte [rax+2], 'l'
  mov byte [rax+3], 'l'
  mov byte [rax+4], 'o'
  mov byte [rax+5], 10

  mov rdi, 1
  mov rsi, rax
  mov rdx, 6
  mov rax, 1
  syscall

  xor rdi, rdi
  mov rax, 60
  syscall

alloc:
  mov r12, rdi

  ; brk(0) - to get the current top of the heap
  mov rdi, 0
  mov rax, 12
  syscall

  ; brk(addr + size)
  mov rdi, rax
  add rdi, r12
  mov rax, 12
  syscall

  sub rax, r12
  ret
