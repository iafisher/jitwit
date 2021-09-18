; Prints out a program's environment variables.
; Stack layout (memory addresses in increasing order)
; 
;   ...     ^
;   ...     |
;   ...     |
;   ...     stack grows this way
;   ...
;   ...
;   argc    <-- rsp
;   arg[0]  <-- rsp + 8
;   arg[1]
;   ...
;   arg[n]
;   0x0
;   env[0]  <-- environment variables
;   env[1]
;   ...
;   env[m]

extern puts

section .text
global _start

_start:
  ; rax = 8 * (argc + 2)
  mov rax, [rsp]
  inc rax
  inc rax
  shl rax, 3

  add rsp, rax

loop:
  cmp qword [rsp], 0
  je end

  mov rdi, qword [rsp]
  call puts

  add rsp, 8
  jmp loop

end:
  mov rdi, 42
  mov rax, 60
  syscall
