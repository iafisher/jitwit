extern exit
extern fopen
extern fclose
extern fread
extern printf

section .text
global _start

_start:
  ; FILE* f;
  ; size_t count;
  ; char buffer[256];
  mov rbp, rsp
  sub rsp, 280

  ; f = fopen(file_path, file_mode)
  mov rdi, file_path
  mov rsi, file_mode
  call fopen
  mov qword [rbp], rax

loop:
  ; size_t count = fread(buffer, 1, 255, f)
  lea rdi, [rbp-272]
  mov rsi, 1
  mov rdx, 255
  mov rcx, qword [rbp]
  call fread
  mov qword [rbp-8], rax

  ; buffer[count] = '\0'
  lea rdx, [rbp-272]
  add rax, rdx
  mov byte [rax], 0

  ; printf("%s", buffer)
  mov rdi, printf_format
  lea rsi, [rbp-272]
  mov rax, 0
  call printf

  ; if count == 255 continue loop
  cmp qword [rbp-8], 255
  je loop

  ; fclose(f)
  mov rdi, qword [rbp]
  call fclose

  ; exit(0)
  mov rdi, 0
  call exit

section .data
  printf_format db "%s", 0
  file_path db "fileio.s", 0
  file_mode db "r", 0
