#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>

typedef void (*function_ptr)();

int main(int argc, char* argv[]) {
    // Machine code for
    //   mov rdi, 42
    //   mov rax, 60
    //   syscall
    //
    // i.e.,
    //
    //   exit(42)
    const char code[] = "\xbf\x2a\x00\x00\x00\xb8\x3c\x00\x00\x00\x0f\x05";
    char* buffer = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0);

    size_t length = sizeof code / sizeof *code;
    for (size_t i = 0; i < length; i++) {
        buffer[i] = code[i];
    }

    int err = mprotect(buffer, 4096, PROT_READ|PROT_EXEC);
    if (err != 0) {
        perror("mprotect() failed");
        return 1;
    }

    function_ptr f = (function_ptr)buffer;
    f();
    // Run `echo $?` in the shell after running this program to verify that the machine
    // code was indeed run and exited the program with a status code of 42.
}
