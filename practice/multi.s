section .text
global _start

_start:
  sub rsp, 16

  ; mmap(...)
  ; addr
  mov rdi, 0
  ; size
  mov rsi, 0x10000
  ; PROT_READ|PROT_WRITE
  mov rdx, 3
  ; MAP_PRIVATE|MAP_ANONYMOUS|MAP_STACK
  mov r10, 0x20022
  ; file descriptor
  mov r8, -1
  ; offset
  mov r9, 0
  mov rax, 9
  syscall 

  ; clone(...)
  mov rdi, 0x3d0f00
  mov rsi, rax
  mov rdx, rsp
  lea r10, [rsp+8]
  mov r8, 0
  mov rax, 56
  syscall

  cmp rax, 0
  je child

  mov r12, rax

  mov rax, 1
  call sleep

  ; print(thread1)
  mov rdi, 1
  mov rsi, thread1
  mov rdx, 9
  mov rax, 1
  syscall

  ; futex(...)
  mov rdi, rsp
  mov rsi, 0
  mov rdx, r12
  mov r10, 0
  mov r8, 0
  mov r9, rsp
  lea r9, [rsp+8]
  mov rax, 202
  syscall

  ; exit_group(0)
  mov rdi, 0
  mov rax, 231
  syscall

child:
  ; print(thread2)
  mov rdi, 1
  mov rsi, thread2
  mov rdx, 9
  mov rax, 1
  syscall

  mov rax, 5
  call sleep

  ; exit(0)
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

section .data
thread1: db "Thread 1", 10
thread2: db "Thread 2", 10
