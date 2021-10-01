%include 'syscall.mac'

section .text
global get_file_size

SIZEOF_STRUCT_STAT equ 144
OFFSET_ST_SIZE     equ 96

get_file_size:
  push rbp
  mov rbp, rsp
  ; enough room on the stack to store `struct stat`
  sub rsp, SIZEOF_STRUCT_STAT

  lea rsi, [rbp-SIZEOF_STRUCT_STAT]
  syscall2 SYS_stat, rdi, rsi

  mov rax, qword [rbp-OFFSET_ST_SIZE]

  add rsp, 144
  pop rbp
  ret
