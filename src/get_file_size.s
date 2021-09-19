section .text
global get_file_size

SYSCALL_STAT      equ 4
SIZEOF_STRUCT_SAT equ 144
OFFSET_ST_SIZE    equ 96

get_file_size:
  push rbp
  mov rbp, rsp
  ; enough room on the stack to store `struct stat`
  sub rsp, SIZEOF_STRUCT_SAT

  lea rsi, [rbp-SIZEOF_STRUCT_SAT]
  mov rax, SYSCALL_STAT
  syscall

  mov rax, qword [rbp-OFFSET_ST_SIZE]

  add rsp, 144
  pop rbp
  ret
