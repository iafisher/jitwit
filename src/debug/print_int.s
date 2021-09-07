section .text
global print_int

print_int:
  cmp rdi, 0
  je print_int_zero

  push rbp
  mov rbp, rsp
  sub rsp, 22

  ; rax = n
  ; r12 = length of string
  ; rsi = pointer to current position in char buffer
  mov rax, rdi
  cdq
  mov r12, 1
  mov rsi, rsp

  dec rsi
  ; buffer[end] = '\n'
  mov byte [rsi], 10

print_int_loop:
  cmp rax, 0
  je print_int_loop_end

  ; rax = n / 10
  ; rdx = n % 10
  mov rcx, 10
  cdq
  idiv rcx

  ; buffer[rsi] = n % 10
  dec rsi
  add dl, 48
  mov byte [rsi], dl
  inc r12
  jmp print_int_loop

print_int_loop_end:
  ; write(stdout, buffer, buffer_length)
  mov rdi, 2
  mov rdx, r12
  mov rax, 1
  syscall

  pop rbp
  add rsp, 22
  ret

print_int_zero:
  push rbp
  mov rbp, rsp
  sub rsp, 2

  ; buffer[0] = '0'
  ; buffer[1] = '\n'
  mov byte [rbp], 48
  mov byte [rbp+1], 10

  ; write(stdout, buffer, buffer_length)
  mov rdi, 2
  mov rsi, rbp
  mov rdx, 2
  mov rax, 1
  syscall

  pop rbp
  add rsp, 2
  ret
