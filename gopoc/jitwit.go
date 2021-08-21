package main

/*
#include <unistd.h>
*/
import "C"

import (
	"fmt"
	"golang.org/x/sys/unix"
	"os"
	"syscall"
	"unsafe"
)

type jitFunction func() int

func main() {
	pageSize := int(C.sysconf(30))
	block, err := syscall.Mmap(0, 0, pageSize, unix.PROT_WRITE|unix.PROT_READ, unix.MAP_PRIVATE|unix.MAP_ANONYMOUS)
	if err != nil {
		printErrorAndBail(err)
	}
	defer syscall.Munmap(block)

	// See https://go.googlesource.com/go/+/refs/heads/dev.regabi/doc/asm.html
	// for some details on Go's ABI, which differs from the standard C ABI.

	// movq $42, 0x8(%rsp)
	block[0] = 0x48
	block[1] = 0xc7
	block[2] = 0x44
	block[3] = 0x24
	block[4] = 0x08
	block[5] = 0x2a
	block[6] = 0x00
	block[7] = 0x00
	block[8] = 0x00

	// retq
	block[9] = 0xc3

	err = syscall.Mprotect(block, unix.PROT_READ|unix.PROT_EXEC)
	if err != nil {
		printErrorAndBail(err)
	}

	// https://medium.com/kokster/writing-a-jit-compiler-in-golang-964b61295f
	uncastF := (uintptr)(unsafe.Pointer(&block))
	f := *(*jitFunction)(unsafe.Pointer(&uncastF))
	x := int(f())
	fmt.Printf("%d\n", x)
}

func printErrorAndBail(err error) {
	fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
	os.Exit(2)
}
