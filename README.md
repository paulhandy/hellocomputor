# Hello Computor!

This is an example EFI module that makes use of clang, [make,] and optionally qemu.

## Using Make for automatic build

Update gitmodules using `git submodule update --init --recursive`.
Then, you may make and run the emulated efi using `make -f .mk qemu`

## Manually

Clang compiles the special efi binary type on many operating systems without extra steps.

## Install clang

If you already have clang installed and updated, you may skip this step.

On archlinux, install `clang` and `lld` package using pacman.
`sudo pacman -S clang lld `
On debian-based systems (Ubuntu...):
`sudo apt install clang-13 lld --install-suggests`

On windows

Download the latest release installer from their github release page. At the time of writing, it can
be found here:
https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/LLVM-13.0.0-win64.exe
This should install clang and lld.

## Compile EFI executable manually

For each source file ending in `.c`, compile ***.c to objects ***.o (replace MYPROGRAM with your source code file name):
`clang -target x86_64-unknown-windows -ffreestanding -fshort-wchar -mno-red-zone -Iextern/efi -o MYPROGRAM.o -c MYPROGRAM.c`

Then collect all these objects to generate your efi binary (replace MYQUBIC and FIRST/SECOND/.../LAST with your generated objects):
`clang -target x86_64-unknown-windows -nostdlib -Wl,-entry:efi_main -Wl,-subsystem:efi_application -fuse-ld=lld-link -o MYQUBIC.efi FIRST.o SECOND.o .... LAST.o`

You've now created the operating-system-independent binary for your computor.

## Run on Qemu

Perhaps you don't want to go through the hassle of rebooting your PC, like myself. In this case, you
can run it in a virtual machine!

### Install qemu

On archlinux, the command `sudo pacman -S qemu` will install it.

On ubuntu, enter this into a terminal:
`sudo apt update && sudo apt install qemu-kvm qemu virt-manager virt-viewer libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon`

On windows, a qemu executable may be found here: `https://qemu.weilnetz.de/w64/qemu-w64-setup-20211215.exe`

On macOS, it may be installed using `brew install qemu`.


### Install OVMF (Open Virtual Machine Firmware)

I will include OVMF_CODE.fd and OVMF_VARS.fd for reference use. You may choose to install it on your system.

In archlinux, it may be installed using the command: `sudo pacman -S edk2-ovmf`

### Run in qemu

The qemu command may be different on varying systems. On some, it is `qemu-kvm`. On others, `qemu` alone is used.
On mine, the relevant command is `qemu-system-x86_64`.

In the directory where you built your efi binary, create a new directory named, i,e., `BOOT`, and move your program (MYQUBIC.efi) there.

From your terminal, run this command (replacing qemu-* with the appropriate name for your system [typing qemu, and then hittng TAB will help to find it]):
```
qemu-system-x86_64 -enable-kvm -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE.fd -drive if=pflash,format=raw,file=OVMF_VARS.fd -drive index=0,format=raw,file=fat:rw:BOOT
```

### Run on baremetal
If you wish to run bare instead of in QEMU, copy the binary to a thumb drive, insert it into your pc, load the EFI shell.

## EFI Shell

With the EFI Shell loaded, it should list a mapping table, somewhat similar to this:
```
Mapping table
      FS0: Alias(s):HD0a1:;BLK1:
          PciRoot(0x0)/Pci(0x1,0x1)/Ata(0x0)/HD(1,MBR,0xBE1AFDFA,0x3F,0xFBFC1)
     BLK0: Alias(s):
          PciRoot(0x0)/Pci(0x1,0x1)/Ata(0x0)
     BLK2: Alias(s):
          PciRoot(0x0)/Pci(0x1,0x1)/Ata(0x0)
```
If it does not, you may type `map` to see it.
In this case, FS0 contains my binary. To enter it, one types the command
`FS0:`
From here, the commands `ls` or `dir` should show that previously created program. For instance,
```
FS0:\> ls
Directory of: FS0:\
01/17/2022  11:48               3,072  MYQUBIC.efi
          1 File(s)       3,072 bytes
```
If you see the program, in this instance named "MYQUBIC.efi", you run it simply by entering:
```
FS0:\> MYQUBIC.efi

```



