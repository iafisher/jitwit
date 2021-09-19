extern get_file_size
extern print_int

SYSCALL_EXIT equ 60

section .text
global _start

_start:
  mov rdi, path
  call get_file_size
  mov rdi, rax
  call print_int

  mov rdi, 0
  mov rax, SYSCALL_EXIT
  syscall

section .data
  path: db "/home/iafisher/dev/jitwit/make_elf.py", 0
