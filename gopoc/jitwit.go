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

	// mov $42, %rax
	block[0] = 0x48
	block[1] = 0xc7
	block[2] = 0xc0
	block[3] = 0x2a
	block[4] = 0x00
	block[5] = 0x00
	block[6] = 0x00

	// retq
	block[7] = 0xc3

	// block[0] = 0x48
	// block[1] = 0xb8

	// multiplier := 101
	// block[2] = byte((multiplier & 0x00000000000000ff) >> 0)
	// block[3] = byte((multiplier & 0x000000000000ff00) >> 8)
	// block[4] = byte((multiplier & 0x0000000000ff0000) >> 16)
	// block[5] = byte((multiplier & 0x00000000ff000000) >> 24)
	// block[6] = byte((multiplier & 0x000000ff00000000) >> 32)
	// block[7] = byte((multiplier & 0x0000ff0000000000) >> 40)
	// block[8] = byte((multiplier & 0x00ff000000000000) >> 48)
	// // block[9] = byte((multiplier & 0xff00000000000000) >> 56)
	// block[9] = 0

	// block[10] = 0x48
	// block[11] = 0x0f
	// block[12] = 0xaf
	// block[13] = 0xc7

	// block[14] = 0xc3

	err = syscall.Mprotect(block, unix.PROT_READ|unix.PROT_EXEC)
	if err != nil {
		printErrorAndBail(err)
	}

	// https://medium.com/kokster/writing-a-jit-compiler-in-golang-964b61295f
	unsafeF := (uintptr)(unsafe.Pointer(&block))
	f := *(*jitFunction)(unsafe.Pointer(&unsafeF))
	x := f()
	// TODO: Why doesn't this print 42?
	fmt.Printf("%d\n", x)
}

func printErrorAndBail(err error) {
	fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
	os.Exit(2)
}
