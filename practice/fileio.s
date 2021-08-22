extern exit
extern fopen
extern fclose
extern fread
extern puts

section .text
global _start

_start:
  mov rsp, rbp
  sub rsp, 256

  ; FILE* f = fopen(file_path, file_mode)
  mov rdi, file_path
  mov rsi, file_mode
  call fopen
  mov qword [rbp-8], rax

  ; size_t count = fread(buffer, 1, 255, f)
  lea rdi, [rbp-272]
  mov rsi, 1
  mov rdx, 255
  mov rcx, qword [rbp-8]
  call fread

  ; buffer[count] = '\0'
  lea rdx, [rbp-272]
  add rax, rdx
  mov byte [rax], 0

  ; puts(buffer)
  lea rdi, [rbp-272]
  call puts

  ; fclose(f)
  mov rdi, qword [rbp-8]
  call fclose

  ; exit(0)
  mov rdi, 0
  call exit

section .data
  file_path db "fileio.s"
  file_mode db "r"
