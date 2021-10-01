OBJ = src/get_file_size.o src/main.o src/debug/print_int.o
BIN = jit
DEBUG_FLAGS = -g -F dwarf

$(BIN): $(OBJ)
	ld -nostdlib -o jit $(OBJ)

src/%.o: src/%.s
	nasm $(DEBUG_FLAGS) -f elf64 -Isrc/include -o $@ $<

.PHONY: clean
clean:
	rm -f src/**.o $(BIN)
