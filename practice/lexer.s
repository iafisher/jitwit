extern exit
extern free
extern malloc
extern puts
extern strncpy

global _start
_start:
  mov rbp, rsp
  ; struct {
  ;   char* buffer;
  ;   size_t index;
  ; } lexer;
  ; struct {
  ;   int type;
  ;   char* value;
  ; } token;
  sub rsp, 32

  ; lexer.buffer = "x + 1"
  ; lexer.index = 0
  mov qword [rbp], input
  mov qword [rbp-8], 0

loop:
  ; next_token(&lexer, &token)
  mov rdi, rbp
  mov rsi, rbp
  sub rsi, 16
  call next_token

  ; if (token.type == TOKEN_EOF) break
  cmp qword [rbp-16], TOKEN_EOF
  je end

  ; puts(token.value)
  mov rdi, [rbp-24]
  call puts

  ; free(token.value)
  mov rdi, [rbp-24]
  call free

  jmp loop

end:
  ; exit(0)
  mov rdi, 0
  call exit


next_token:
  ; Lexer* lexer
  mov r12, rdi
  ; Token* token
  mov r13, rsi

  ; if (lexer->buffer[lexer->index] == '\0')
  mov rax, [r12-8]
  add rax, [r12]
  cmp qword [rax], 0
  jne next_token_skip_whitespace
  ; token->type = 0
  mov qword [r13], 0
  jmp next_token_end

next_token_skip_whitespace:
  mov rax, qword [r12]
  add rax, qword [r12-8]

  cmp byte [rax], 32
  jne next_token_body
  add qword [r12-8], 1
  jmp next_token_skip_whitespace

next_token_body:
  ; start = lexer->index
  mov r14, qword [r12-8]

next_token_loop:
  mov rax, qword [r12]
  add rax, qword [r12-8]

  cmp byte [rax], 32
  je next_token_loop_end
  cmp byte [rax], 0
  je next_token_loop_end
  ; lexer->index++
  add qword [r12-8], 1
  jmp next_token_loop

next_token_loop_end:
  ; count = lexer->index - start
  mov r15, qword [r12-8]
  sub r15, r14

  ; token->value = malloc(count + 1)
  mov rdi, r15
  inc rdi
  call malloc
  mov qword [r13-8], rax

  ; strncpy(token->value, lexer->buffer + start, count)
  mov rdi, qword [r13-8]
  mov rsi, qword [r12]
  add rsi, r14
  mov rdx, r15
  call strncpy

  ; token->value[count] = '\0'
  mov rax, qword [r13-8]
  add rax, r15
  mov byte [rax], 0

  ; token->type = 1
  mov qword [r13], 1

next_token_end:
  ret
  


section .data
  input db "x + 1", 0

  TOKEN_EOF equ 0
