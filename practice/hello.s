# Courtesy of https://gist.github.com/yellowbyte/d91da3c3b0bc3ee6d1d1ac5327b1b4b2
extern exit
extern puts

section .text
global _start

_start:
  mov rdi, hello
  call puts

  mov rdi, 0x0
  call exit

section .data
  hello db "Hello, world!"
