FUCHSIA_SRC := /slice/fuchsia
MAGENTA_SRC := $(FUCHSIA_SRC)/magenta
TOOLCHAIN_SRC := $(FUCHSIA_SRC)/third_party/gcc_none_toolchains
QEMU_SRC := $(FUCHSIA_SRC)/third_party/qemu
SDK_SRC := $(FUCHSIA_SRC)/buildtools/sdk/toolchains

CLANG := no
ifneq (no,$(CLANG))
FLAGS_CLANG := CLANG=1 FUCHSIA=1 ARCH_x86_64_TOOLCHAIN_PREFIX=$(SDK_SRC)/clang+llvm-x86_64-linux/bin/ LIBGCC=$(SDK_SRC)/clang+llvm-x86_64-linux/lib/clang/3.9.0/lib/fuchsia/libclang_rt.builtins-x86_64.a
export PATH := $(PATH):$(SDK_SRC)/clang+llvm-x86_64-linux/bin
else
FLAGS_CLANG :=
endif

export PATH := $(PATH):$(TOOLCHAIN_SRC)/aarch64-elf-5.3.0-Linux-x86_64/bin
export PATH := $(PATH):$(TOOLCHAIN_SRC)/arm-eabi-5.3.0-Linux-x86_64/bin
export PATH := $(PATH):$(TOOLCHAIN_SRC)/x86_64-elf-5.3.0-Linux-x86_64/bin
export PATH := $(PATH):$(QEMU_SRC)/aarch64-softmmu
export PATH := $(PATH):$(QEMU_SRC)/arm-softmmu
export PATH := $(PATH):$(QEMU_SRC)/x86_64-softmmu

export ENABLE_BUILD_LISTFILES := true
export ENABLE_BUILD_SYSROOT := true

DEBUG := no
ifneq (no,$(DEBUG))
FLAGS_DEBUG := DEBUG=0
else
FLAGS_DEBUG :=
endif

RELEASE := no
ifneq (no,$(RELEASE))
FLAGS_RELASE := -r
else
FLAGS_RELEASE :=
endif

J := no
ifneq (no,$(J))
FLAGS_J := -j $(J)
else
FLAGS_J := -j
endif

K := no
ifneq (no,$(K))
FLAGS_K := -k
else
FLAGS_K :=
endif

MAKE := $(FLAGS_DEBUG) make $(FLAGS_CLANG) $(FLAGS_J) $(FLAGS_K)

GDB := no
ifneq (no,$(GDB))
FLAGS_GDB := -- -s -S
else
FLAGS_GDB :=
endif

U := no
ifneq (no,$(U))
FLAGS_U := -u
else
FLAGS_U :=
endif

BOOTFS := no
ifneq (no,$(BOOTFS))
FLAGS_BOOTFS := -x ../$(BOOTFS)
FLAGS_BOOTSERVER := ../$(BOOTFS)
else
FLAGS_BOOTFS :=
FLAGS_BOOTSERVER :=
endif

all: buildall
	@:

clean:
	@rm -rf $(MAGENTA_SRC)/build-*

arm32:
	@$(MAKE) -C magenta magenta-qemu-arm32

run-arm32: arm32
	@cd $(MAGENTA_SRC) && ./scripts/run-magenta-arm32 $(FLAGS_RELEASE) $(FLAGS_U) $(FLAGS_BOOTFS) $(FLAGS_GDB)

debug-arm32:
	@arm-eabi-gdb magenta/build-magenta-qemu-arm32/lk.elf

arm64:
	@$(MAKE) -C magenta magenta-qemu-arm64

run-arm64: arm64
	@cd $(MAGENTA_SRC) && ./scripts/run-magenta-arm64 $(FLAGS_RELEASE) $(FLAGS_U) $(FLAGS_BOOTFS) $(FLAGS_GDB)

debug-arm64:
	@aarch64-elf-gdb magenta/build-magenta-qemu-arm64/lk.elf

x64:
	@$(MAKE) -C magenta magenta-qemu-x86-64

run-x64: x64
	@cd $(MAGENTA_SRC)/ && ./scripts/run-magenta-x86-64 $(FLAGS_RELEASE) $(FLAGS_U) $(FLAGS_BOOTFS) $(FLAGS_GDB)

buildall:
	cd $(MAGENTA_SRC) && env $(FLAGS_DEBUG) $(FLAGS_CLANG) ./scripts/buildall -r

pc:
	@$(MAKE) -C magenta magenta-pc-uefi

bootserver: pc
	$(MAGENTA_SRC)/build-magenta-pc-uefi/tools/bootserver $(MAGENTA_SRC)/build-magenta-pc-uefi/magenta.bin $(FLAGS_BOOTSERVER)
