RELEASE := false
ifeq ($(RELEASE),false)
RELEASE_GEN_FLAG :=
BUILD_NAME := debug
else
RELEASE_GEN_FLAG := -r
BUILD_NAME := release
endif

PACKAGES := default

BOOT_ARGS :=
ALL_BOOT_ARGS := -- virtcon.keymap=dvorak $(BOOT_ARGS)

NOGOMA := false
ifeq ($(NOGOMA),false)
GOMA := --goma
else
GOMA :=
endif

ifeq ($(USE_CLANG),true)
CLANG_SUFFIX := -clang
else
CLANG_SUFFIX :=
endif


FUCHSIA_DIR := $(HOME)/fuchsia

SCRIPTS_DIR := $(FUCHSIA_DIR)/scripts

MAGENTA_DIR := $(FUCHSIA_DIR)/magenta
MAGENTA_SCRIPTS_DIR := $(MAGENTA_DIR)/scripts

BUILDTOOLS_DIR := $(FUCHSIA_DIR)/buildtools
QEMU_DIR := $(BUILDTOOLS_DIR)/qemu/bin
GOMA_DIR := ~/goma

FUCHSIA_OUT_DIR := $(FUCHSIA_DIR)/out
MAGENTA_OUT_DIR := $(FUCHSIA_OUT_DIR)/build-magenta
MAGENTA_ARM64_OUT_DIR := $(MAGENTA_OUT_DIR)/build-magenta-qemu-arm64$(CLANG_SUFFIX)
MAGENTA_X64_OUT_DIR := $(MAGENTA_OUT_DIR)/build-magenta-pc-x86-64$(CLANG_SUFFIX)
TOOLS_OUT_DIR := $(MAGENTA_OUT_DIR)/build-magenta-pc-x86-64$(CLANG_SUFFIX)/tools

FUCHSIA_OUT_PREFIX := $(FUCHSIA_OUT_DIR)/$(BUILD_NAME)


goma:
	$(GOMA_DIR)/goma_ctl.py ensure_start


arm64:
	$(MAGENTA_SCRIPTS_DIR)/make-parallel -C $(MAGENTA_DIR) BUILDROOT=$(MAGENTA_OUT_DIR) magenta-qemu-arm64

x64:
	$(MAGENTA_SCRIPTS_DIR)/make-parallel -C $(MAGENTA_DIR) BUILDROOT=$(MAGENTA_OUT_DIR) magenta-pc-x86-64

tools:
	$(MAGENTA_SCRIPTS_DIR)/make-parallel -C $(MAGENTA_DIR) BUILDROOT=$(MAGENTA_OUT_DIR) tools


run-arm64: arm64
	$(MAGENTA_SCRIPTS_DIR)/run-magenta -o $(MAGENTA_ARM64_OUT_DIR) -a arm64 -q $(QEMU_DIR)

run-x64: x64
	$(MAGENTA_SCRIPTS_DIR)/run-magenta -o $(MAGENTA_X64_OUT_DIR) -a x86-64 -q $(QEMU_DIR)


sysroot-arm64: goma
	$(SCRIPTS_DIR)/build-magenta.sh -t aarch64

sysroot-x64: goma
	$(SCRIPTS_DIR)/build-magenta.sh -t x86_64


packages-arm64: sysroot-arm64
	$(FUCHSIA_DIR)/packages/gn/gen.py $(GOMA) --target_cpu aarch64 -m $(PACKAGES) $(RELEASE_GEN_FLAG)

packages-x64: sysroot-x64
	$(FUCHSIA_DIR)/packages/gn/gen.py $(GOMA) --target_cpu x86-64 -m $(PACKAGES) $(RELEASE_GEN_FLAG)


fuchsia-arm64: packages-arm64
	$(BUILDTOOLS_DIR)/ninja -C $(FUCHSIA_OUT_PREFIX)-aarch64

fuchsia-x64: packages-x64
	$(BUILDTOOLS_DIR)/ninja -C $(FUCHSIA_OUT_PREFIX)-x86-64


run-fuchsia-arm64: fuchsia-arm64
	$(MAGENTA_SCRIPTS_DIR)/run-magenta -o $(MAGENTA_ARM64_OUT_DIR) -a arm64 -q $(QEMU_DIR) -x $(FUCHSIA_OUT_PREFIX)-aarch64/user.bootfs

run-fuchsia-x64: fuchsia-x64
	$(MAGENTA_SCRIPTS_DIR)/run-magenta -o $(MAGENTA_X64_OUT_DIR) -a x86-64 -q $(QEMU_DIR) -x $(FUCHSIA_OUT_PREFIX)-x86-64/user.bootfs


boot: x64 tools
	$(TOOLS_OUT_DIR)/bootserver -1 $(MAGENTA_X64_OUT_DIR)/magenta.bin $(ALL_BOOT_ARGS)

fuchsia-boot: fuchsia-x64 tools
	$(TOOLS_OUT_DIR)/bootserver -1 $(MAGENTA_X64_OUT_DIR)/magenta.bin $(FUCHSIA_OUT_PREFIX)-x86-64/user.bootfs $(ALL_BOOT_ARGS)


reboot: tools
	$(TOOLS_OUT_DIR)/netruncmd : "dm reboot"

trace:
	:

listen: tools
	$(TOOLS_OUT_DIR)/loglistener

symbolize:
	:
