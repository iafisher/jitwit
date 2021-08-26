extern exit
extern fopen
extern fclose
extern fread
extern free
extern malloc
extern printf
extern puts
extern realloc

section .text
global _start

_start:
  ; FILE* f
  ; size_t count
  ; size_t buflen
  ; size_t capacity
  ; char* buffer
  mov rbp, rsp
  sub rsp, 40

  ; f = fopen(file_path, file_mode)
  mov rdi, file_path
  mov rsi, file_mode
  call fopen
  mov qword [rbp], rax

  ; buflen = 0
  ; capacity = 256
  ; buffer = malloc(capacity)
  mov qword [rbp-16], 0
  mov qword [rbp-24], 256
  mov rdi, qword [rbp-24]
  call malloc
  mov qword [rbp-32], rax

loop:
  ; size_t count = fread(buffer + buflen, 1, 255, f)
  mov rdi, [rbp-32]
  add rdi, qword [rbp-16]
  mov rsi, 1
  mov rdx, 255
  mov rcx, qword [rbp]
  call fread
  mov qword [rbp-8], rax

  ; buflen += count
  add qword [rbp-16], rax

  ; if count != 255 end loop
  cmp qword [rbp-8], 255
  jne end

  ; capacity *= 2
  ; buffer = realloc(buffer, capacity)
  shl qword [rbp-24], 1
  mov rdi, [rbp-32]
  mov rsi, [rbp-24]
  call realloc
  mov [rbp-32], rax
  jmp loop

end:
  ; fclose(f)
  mov rdi, qword [rbp]
  call fclose

  ; buffer[buflen] = '\0'
  lea rax, [rbp-32]
  add rax, qword [rbp-16]
  mov byte [rax], 0

  ; puts(buffer)
  mov rdi, qword[rbp-32]
  call puts

  ; free(buffer)
  mov rdi, qword [rbp-32]
  call free

  ; exit(0)
  mov rdi, 0
  call exit

section .data
  file_path db "fileio.s", 0
  file_mode db "r", 0
