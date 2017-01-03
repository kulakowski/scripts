FUCHSIA_DIR := /slice/fuchsia
MAGENTA_DIR := $(FUCHSIA_DIR)/magenta
TOOLCHAIN_DIR := $(MAGENTA_DIR)/prebuilt/downloads
QEMU_DIR := $(FUCHSIA_DIR)/third_party/qemu
BUILDTOOLS_DIR := $(FUCHSIA_DIR)/buildtools
SDK_DIR := $(FUCHSIA_DIR)/buildtools/sdk/toolchains

CLANG := no
ifneq (no,$(CLANG))
FLAGS_CLANG := CLANG=1 FUCHSIA=1 ARCH_x86_64_TOOLCHAIN_PREFIX=$(SDK_DIR)/clang+llvm-x86_64-linux/bin/ LIBGCC=$(SDK_DIR)/clang+llvm-x86_64-linux/lib/clang/3.9.0/lib/fuchsia/libclang_rt.builtins-x86_64.a
export PATH := $(PATH):$(SDK_DIR)/clang+llvm-x86_64-linux/bin
else
FLAGS_CLANG :=
endif

export PATH := $(PATH):$(TOOLCHAIN_DIR)/aarch64-elf-5.3.0-Linux-x86_64/bin
export PATH := $(PATH):$(TOOLCHAIN_DIR)/arm-eabi-5.3.0-Linux-x86_64/bin
export PATH := $(PATH):$(TOOLCHAIN_DIR)/x86_64-elf-5.3.0-Linux-x86_64/bin
export PATH := $(PATH):$(QEMU_DIR)/aarch64-softmmu
export PATH := $(PATH):$(QEMU_DIR)/arm-softmmu
export PATH := $(PATH):$(QEMU_DIR)/x86_64-softmmu

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
FLAGS_RELEASE := -r
BUILD_CMD := ./scripts/make-release
GN_OUT_DIR := release
else
FLAGS_RELEASE :=
BUILD_CMD := ./scripts/make-parallel
GN_OUT_DIR := debug
endif

J := no
ifneq (no,$(J))
FLAGS_J := -j $(J)
FLAGS_NINJA_J := -j $(J)
else
FLAGS_J := -j
FLAGS_NINJA_J :=
endif

K := no
ifneq (no,$(K))
FLAGS_K := -k
else
FLAGS_K :=
endif

MAKE := $(FLAGS_DEBUG) OBJDUMP_LIST_FLAGS="-M intel" make $(FLAGS_CLANG) $(FLAGS_J) $(FLAGS_K)

GDB := no
ifneq (no,$(GDB))
FLAGS_GDB := -- -s -S
else
FLAGS_GDB :=
endif

S := 4
FLAGS_S := -s $(S)

BOOTFS := no
ifneq (no,$(BOOTFS))
FLAGS_BOOTFS := -x ../$(BOOTFS)
FLAGS_BOOTSERVER := $(BOOTFS)
else
FLAGS_BOOTFS :=
FLAGS_BOOTSERVER :=
endif

PACKAGES :=
ifneq (,$(PACKAGES))
FLAGS_PACKAGES := -m $(PACKAGES)
else
FLAGS_PACKAGES :=
endif

GOMA :=
ifneq (,$(GOMA))
FLAGS_GOMA := --goma
else
FLAGS_GOMA :=
endif

all: buildall
	@:

toolchain:
	$(MAGENTA_DIR)/scripts/download-toolchain

update:
	jiri update

clean:
	@rm -rf $(MAGENTA_DIR)/build-*

arm32: toolchain
	@cd $(MAGENTA_DIR) && $(BUILD_CMD) magenta-qemu-arm32

run-arm32: arm32
	@cd $(MAGENTA_DIR) && ./scripts/run-magenta-arm32 $(FLAGS_RELEASE) $(FLAGS_S) $(FLAGS_BOOTFS) $(FLAGS_GDB) -m 4096

debug-arm32:
	@arm-eabi-gdb magenta/build-magenta-qemu-arm32/lk.elf

arm64: toolchain
	@cd $(MAGENTA_DIR) && $(BUILD_CMD) magenta-qemu-arm64

run-arm64: arm64
	@cd $(MAGENTA_DIR) && ./scripts/run-magenta-arm64 $(FLAGS_RELEASE) $(FLAGS_S) $(FLAGS_BOOTFS) $(FLAGS_GDB) -m 4096

debug-arm64:
	@aarch64-elf-gdb magenta/build-magenta-qemu-arm64/lk.elf

x64: toolchain
	@cd $(MAGENTA_DIR) && $(BUILD_CMD) magenta-pc-x86-64

run-x64: x64
	@cd $(MAGENTA_DIR)/ && ./scripts/run-magenta-x86-64 $(FLAGS_RELEASE) $(FLAGS_S) $(FLAGS_BOOTFS) $(FLAGS_GDB) -m 4096

grub: toolchain
	@cd $(MAGENTA_DIR) && ./scripts/make-magenta-x86-64-grub

bootserver: x64
	$(BUILDTOOLS_DIR)/bootserver $(MAGENTA_DIR)/build-magenta-pc-x86-64/magenta.bin $(FLAGS_BOOTSERVER) -- "gfxconsole.keymap=dvorak netsvc.disable=true dummy"

buildall: toolchain
	cd $(MAGENTA_DIR) && env $(FLAGS_DEBUG) $(FLAGS_CLANG) ./scripts/buildall -r

fuchsia-x64: x64
	./scripts/build-sysroot.sh -t x86_64
	./packages/gn/gen.py $(FLAGS_PACKAGES) $(FLAGS_RELEASE) $(FLAGS_GOMA) --target_cpu x86-64
	$(BUILDTOOLS_DIR)/ninja $(FLAGS_NINJA_J) -C out/$(GN_OUT_DIR)-x86-64

fuchsia-arm64: arm64
	./scripts/build-sysroot.sh -t aarch64
	./packages/gn/gen.py $(FLAGS_PACKAGES) $(FLAGS_RELEASE) $(FLAGS_GOMA) --target_cpu aarch64
	$(BUILDTOOLS_DIR)/ninja $(FLAGS_NINJA_J) -C out/$(GN_OUT_DIR)-aarch64

fuchsia-clean:
	@rm -rf $(FUCHSIA_DIR)/out

listen:
	$(BUILDTOOLS_DIR)/loglistener
