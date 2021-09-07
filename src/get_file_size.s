section .text
global get_file_size

get_file_size:
  push rbp
  mov rbp, rsp
  ; enough room on the stack to store `struct stat`
  sub rsp, 144

  lea rsi, [rbp-144]
  mov rax, 4
  syscall

  mov rax, qword [rbp-96]

  add rsp, 144
  pop rbp
  ret
