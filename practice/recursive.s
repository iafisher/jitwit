extern exit
extern printf

global _start
section .text

_start:
  mov rdi, 12
  call fib

  mov rdi, format
  mov rsi, rax
  call printf

  mov rdi, 0
  call exit

fib:
  ; rdi (parameter): the desired Fibonacci number
  ; rax: the i'th Fibonacci number
  mov rax, 1
  ; rcx: the (i-1)'th Fibonacci number
  mov rcx, 0
  ; rdx: i
  mov rdx, 1

fib_loop:
  cmp rdi, rdx
  je fib_end

  mov r8, rax
  add rax, rcx
  mov rcx, r8
  inc rdx

  jmp fib_loop

fib_end:
  ret

fib_done:
  mov rax, rdi
  ret

section .data
  format db "%d", 0xa
