extern exit
extern printf

section .text
global _start

_start:
  ; Stack layout at beginning of execution:
  ;
  ;   argN   <-- rsp + 8*argc
  ;   ...
  ;   arg2
  ;   arg1   <-- rsp + 8
  ;   argc   <-- rsp
  mov r12, [rsp]
  mov r13, rsp
  add r13, 8

loop:
  cmp r12, 1
  je end_of_loop

  add r13, 8
  mov rsi, [r13]
  mov rdi, format
  call printf

  dec r12
  jmp loop
end_of_loop:

  mov rdi, 0
  call exit

section .data
  format db "%s", 10, 0
