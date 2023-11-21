qemu-system-riscv64 -machine virt -nographic -bios default -device loader,file=$(UCOREIMG),addr=0x80200000 -s -S

riscv64-unknown-elf-gdb \
    -ex 'file bin/kernel' \
    -ex 'set arch riscv:rv64' \
    -ex 'target remote localhost:1234'
