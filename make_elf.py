import math
import os
import stat


CODE = bytes(
    # fmt: off
    [
        0xBF, 0x01, 0x00, 0x00, 0x00,              # mov    edi, 1
        0x48, 0xBE, 0x0F, 0x20, 0x40, 0x00, 0x00,  # movabs rsi, 0x40200F
        0x00, 0x00, 0x00,                          #
        0xBA, 0x10, 0x00, 0x00, 0x00,              # mov    edx, 0x10
        0xB8, 0x01, 0x00, 0x00, 0x00,              # mov    eax, 0x1
        0x0F, 0x05,                                # syscall
        0x48, 0x31, 0xFF,                          # xor    rdi, rdi
        0xB8, 0x3C, 0x00, 0x00, 0x00,              # mov    eax, 0x3C
        0x0F, 0x05,                                # syscall
    ]
    # fmt: on
)
CODE_BIG = bytes(
    [
        # xor rdi, rdi
        0x48,
        0x31,
        0xFF,
    ]
    + ([0x48, 0xFF, 0xC7] * 5000)
    + [0xB8, 0x3C, 0x00, 0x00, 0x00]
    + [0x0F, 0x05]
)
DATA = b"Hello, world!\n\0Goodbye, world!\n\0"


ELF_MAGIC = b"\x7FELF"
ELF_LITTLE_ENDIAN = 1
ELF_64_BIT = 2
ELF_TYPE_EXEC = 2
ELF_ARCH_X86_64 = 0x3E
ELF_HEADER_SIZE = 64
ELF_PROGRAM_HEADER_SIZE = 56
ELF_SEGMENT_LOAD = 1
ELF_FLAGS_READ = 4
ELF_FLAGS_WRITE = 2
ELF_FLAGS_EXEC = 1

DEFAULT_ALIGNMENT = 4096
NUMBER_OF_PROGRAM_HEADERS = 3
HEADER_SIZE = ELF_HEADER_SIZE + (NUMBER_OF_PROGRAM_HEADERS * ELF_PROGRAM_HEADER_SIZE)
ENTRY_POINT_BASE = 0x400000
ENTRY_POINT = ENTRY_POINT_BASE + DEFAULT_ALIGNMENT


class ElfWriter:
    def __init__(self, *, code, data):
        self.buffer = bytearray()
        self.code = code
        self.data = data
        self.code_segment_size = math.ceil(len(self.code) / 4096) * 4096
        self.data_segment_size = math.ceil(len(self.data) / 4096) * 4096

    def write(self, path):
        self.buffer.clear()

        self._write_elf_header()
        self._write_program_headers()
        self._write_code()
        self._write_data()

        with open(path, "wb") as f:
            f.write(self.buffer)

        st = os.stat(path)
        os.chmod(path, st.st_mode | stat.S_IEXEC)

    def _write_elf_header(self):
        # Magic number
        self.buffer.extend(ELF_MAGIC)
        # ELF class = 64 bit (1 byte)
        self._write_int(ELF_64_BIT, width=1)
        # Endianness (1 byte)
        self._write_int(ELF_LITTLE_ENDIAN, width=1)
        # ELF version = 1 (1 byte)
        self._write_int(1, width=1)
        # OS ABI = SysV (1 byte)
        self._write_int(0, width=1)
        # OS ABI version = unset (1 byte)
        self._write_int(0, width=1)
        # padding
        self._pad(7)
        # Object file type = EXEC
        self._write_int(ELF_TYPE_EXEC, width=2)
        # Target architecture = x86-64
        self._write_int(ELF_ARCH_X86_64, width=2)
        # ELF version = 1
        self._write_int(1, width=4)
        # Entry point
        self._write_int(ENTRY_POINT, width=8)
        # Program header table offset
        self._write_int(ELF_HEADER_SIZE, width=8)
        # Section header table offset
        self._write_int(0, width=8)
        # Processor flags
        self._write_int(0, width=4)
        # Header size
        self._write_int(ELF_HEADER_SIZE, width=2)
        # Program header entry size
        self._write_int(ELF_PROGRAM_HEADER_SIZE, width=2)
        # Number of program header entries
        self._write_int(NUMBER_OF_PROGRAM_HEADERS, width=2)
        # Section header entry size
        self._write_int(0, width=2)
        # Number of section header entries
        self._write_int(0, width=2)
        # Index of section name header
        self._write_int(0, width=2)

    def _write_program_headers(self):
        # Segment type
        self._write_int(ELF_SEGMENT_LOAD, width=4)
        # Segment flags
        self._write_int(ELF_FLAGS_READ, width=4)
        # Segment offset
        self._write_int(0x0, width=8)
        # Virtual address
        self._write_int(ENTRY_POINT_BASE, width=8)
        # Physical address
        self._write_int(ENTRY_POINT_BASE, width=8)
        # File size
        size = HEADER_SIZE
        self._write_int(size, width=8)
        # Memory size
        self._write_int(size, width=8)
        # Alignment
        self._write_int(DEFAULT_ALIGNMENT, width=8)

        # Segment type
        self._write_int(ELF_SEGMENT_LOAD, width=4)
        # Segment flags
        self._write_int(ELF_FLAGS_READ | ELF_FLAGS_EXEC, width=4)
        # Segment offset
        self._write_int(DEFAULT_ALIGNMENT, width=8)
        # Virtual address
        self._write_int(ENTRY_POINT, width=8)
        # Physical address
        self._write_int(ENTRY_POINT, width=8)
        # File size
        size = len(self.code)
        self._write_int(size, width=8)
        # Memory size
        self._write_int(size, width=8)
        # Alignment = 4096
        self._write_int(DEFAULT_ALIGNMENT, width=8)

        # Segment type
        self._write_int(ELF_SEGMENT_LOAD, width=4)
        # Segment flags
        self._write_int(ELF_FLAGS_READ | ELF_FLAGS_WRITE, width=4)
        # Segment offset
        self._write_int(DEFAULT_ALIGNMENT + self.code_segment_size, width=8)
        # Virtual address
        addr = ENTRY_POINT + self.code_segment_size
        self._write_int(addr, width=8)
        # Physical address
        self._write_int(addr, width=8)
        # File size
        size = len(self.data)
        self._write_int(size, width=8)
        # Memory size
        self._write_int(size, width=8)
        # Alignment
        self._write_int(DEFAULT_ALIGNMENT, width=8)

    def _write_code(self):
        self._pad(DEFAULT_ALIGNMENT - HEADER_SIZE)
        self.buffer.extend(self.code)

    def _write_data(self):
        self._pad(DEFAULT_ALIGNMENT - (len(self.code) % 4096))
        self.buffer.extend(self.data)

    def _write_int(self, x, *, width):
        self.buffer.extend(x.to_bytes(width, "little"))

    def _pad(self, n):
        self.buffer.extend(bytes([0] * n))


if __name__ == "__main__":
    writer = ElfWriter(code=CODE, data=DATA)
    writer.write("myelf")
