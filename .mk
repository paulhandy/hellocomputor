TARGET = hellocomputor.efi
ARCH = $(shell uname -m | sed s,i[3456789]86,ia32,)

CC = clang

CPTR_CFLAGS := \
	      -target x86_64-unknown-windows \
	      -ffreestanding \
	      -fshort-wchar \
	      -mno-red-zone

CPTR_LDFLAGS :=	\
	-target x86_64-unknown-windows \
	-nostdlib \
	-Wl,-entry:efi_main \
	-Wl,-subsystem:efi_application \
	-fuse-ld=lld-link

EFIINCS = -I./extern/efi

CPTR_CFLAGS += $(EFIINCS)
CPTR_LDFLAGS += $(EFILIB) $(LIB)


OUTDIR = objs
BINDIR = ./EFI
SRCDIR = src

SRCS = $(wildcard *.c $(foreach fd, $(SRCDIR), $(fd)*.c))
OBJS = $(addprefix $(OUTDIR)/, $(SRCS:c=o))

all: $(BINDIR)/$(TARGET)

qemu: all
	qemu-system-x86_64 -enable-kvm \
	-drive if=pflash,format=raw,readonly=on,file=./ovmf/OVMF_CODE.fd \
	-drive if=pflash,format=raw,file=./ovmf/OVMF_VARS.fd \
	-drive index=0,format=raw,file=fat:rw:$(BINDIR)
	#-nographic \

$(BINDIR)/$(TARGET): $(OBJS)
	@ mkdir -p $(@D)
	@ $(CC) $(CPTR_LDFLAGS) -o $@ $^

$(OUTDIR)/%.o: %.c
	@ mkdir -p $(@D)
	@ $(CC) $(CPTR_CFLAGS) -o $@ -c $^

