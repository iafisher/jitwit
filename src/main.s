%include "syscall.mac"

extern get_file_size
extern print_int

section .text
global _start

_start:
  mov rdi, path
  call get_file_size

  mov rdi, rax
  call print_int

  syscall1 SYS_exit, 0

section .data
  path: db "/home/iafisher/dev/jitwit/make_elf.py", 0
