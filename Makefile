OBJ = src/main.o
BIN = jit

$(BIN): $(OBJ)
	ld -nostdlib -o jit $(OBJ)

src/%.o: src/%.s
	nasm -f elf64 -o $@ $<

.PHONY: clean
clean:
	rm -f src/**.o $(BIN)
