RELEASE := false
ifeq ($(RELEASE),false)
RELEASE_GEN_FLAG :=
BUILD_NAME := debug
else
RELEASE_GEN_FLAG := -r
BUILD_NAME := release
endif

PACKAGES := packages/gn/default

BOOT_ARGS :=
ALL_BOOT_ARGS := -- virtcon.keymap=dvorak $(BOOT_ARGS)

NOGOMA := false
ifeq ($(NOGOMA),false)
GOMA := --goma
else
GOMA :=
endif

GCC := false
LTO := false
THINLTO := false
ifneq ($(GCC),false)
  BUILD_SUFFIX :=
else
  export USE_CLANG = true
  ifeq ($(LTO),false)
    ifeq ($(THINLTO),false)
      BUILD_SUFFIX := -clang
    else
      export USE_LTO = true
      BUILD_SUFFIX := -thinlto
    endif
  else
    export USE_LTO = true
    export USE_THINLTO = false
    BUILD_SUFFIX := -lto
  endif
endif

KVM := false
ifneq ($(KVM),false)
KVM_FLAGS := -k
else
KVM_FLAGS :=
endif

AUTORUN :=
ifeq ($(AUTORUN),)
AUTORUN_CMD :=
else
AUTORUN_CMD := -c zircon.autorun.boot=$(AUTORUN)
endif

FUCHSIA_DIR := $(HOME)/fuchsia

SCRIPTS_DIR := $(FUCHSIA_DIR)/scripts

ZIRCON_DIR := $(FUCHSIA_DIR)/zircon
ZIRCON_SCRIPTS_DIR := $(ZIRCON_DIR)/scripts

BUILDTOOLS_DIR := $(FUCHSIA_DIR)/buildtools
QEMU_DIR := $(BUILDTOOLS_DIR)/qemu/bin
GOMA_DIR := ~/goma

FUCHSIA_OUT_DIR := $(FUCHSIA_DIR)/out
ZIRCON_OUT_DIR := $(FUCHSIA_OUT_DIR)/build-zircon
ZIRCON_ARM64_OUT_DIR := $(ZIRCON_OUT_DIR)/build-zircon-qemu-arm64$(BUILD_SUFFIX)
ZIRCON_X64_OUT_DIR := $(ZIRCON_OUT_DIR)/build-zircon-pc-x86-64$(BUILD_SUFFIX)
ZIRCON_GCC_X64_OUT_DIR := $(ZIRCON_OUT_DIR)/build-zircon-pc-x86-64
TOOLS_OUT_DIR := $(ZIRCON_OUT_DIR)/build-zircon-pc-x86-64$(BUILD_SUFFIX)/tools

FUCHSIA_OUT_PREFIX := $(FUCHSIA_OUT_DIR)/$(BUILD_NAME)


goma:
	$(GOMA_DIR)/goma_ctl.py ensure_start


arm64:
	$(ZIRCON_SCRIPTS_DIR)/make-parallel -C $(ZIRCON_DIR) BUILDROOT=$(ZIRCON_OUT_DIR) zircon-qemu-arm64

x64:
	$(ZIRCON_SCRIPTS_DIR)/make-parallel -C $(ZIRCON_DIR) BUILDROOT=$(ZIRCON_OUT_DIR) zircon-pc-x86-64

tools:
	$(ZIRCON_SCRIPTS_DIR)/make-parallel -C $(ZIRCON_DIR) BUILDROOT=$(ZIRCON_OUT_DIR) tools


run-arm64: arm64
	$(ZIRCON_SCRIPTS_DIR)/run-zircon -o $(ZIRCON_ARM64_OUT_DIR) -a arm64 -q $(QEMU_DIR) $(KVM_FLAGS) $(AUTORUN_CMD)

run-x64: x64
	$(ZIRCON_SCRIPTS_DIR)/run-zircon -o $(ZIRCON_X64_OUT_DIR) -a x86-64 -q $(QEMU_DIR) $(KVM_FLAGS) $(AUTORUN_CMD)


coretests-arm64: arm64
	$(ZIRCON_SCRIPTS_DIR)/run-zircon -o $(ZIRCON_ARM64_OUT_DIR) -a arm64 -q $(QEMU_DIR) $(KVM_FLAGS) -c userboot=bin/core-tests

coretests-x64: x64
	$(ZIRCON_SCRIPTS_DIR)/run-zircon -o $(ZIRCON_X64_OUT_DIR) -a x86-64 -q $(QEMU_DIR) $(KVM_FLAGS) -c userboot=bin/core-tests


sysroot-arm64: goma
	$(SCRIPTS_DIR)/build-zircon.sh -t aarch64

sysroot-x64: goma
	$(SCRIPTS_DIR)/build-zircon.sh -t x86_64


packages-arm64: sysroot-arm64
	$(FUCHSIA_DIR)/packages/gn/gen.py $(GOMA) --target_cpu aarch64 -m $(PACKAGES) $(RELEASE_GEN_FLAG)

packages-x64: sysroot-x64
	$(FUCHSIA_DIR)/packages/gn/gen.py $(GOMA) --target_cpu x86-64 -m $(PACKAGES) $(RELEASE_GEN_FLAG)


fuchsia-arm64: packages-arm64
	$(BUILDTOOLS_DIR)/ninja -C $(FUCHSIA_OUT_PREFIX)-aarch64

fuchsia-x64: packages-x64
	$(BUILDTOOLS_DIR)/ninja -C $(FUCHSIA_OUT_PREFIX)-x86-64


run-fuchsia-arm64: fuchsia-arm64
	$(ZIRCON_SCRIPTS_DIR)/run-zircon -o $(ZIRCON_ARM64_OUT_DIR) -a arm64 -q $(QEMU_DIR) -x $(FUCHSIA_OUT_PREFIX)-aarch64/user.bootfs

run-fuchsia-x64: fuchsia-x64
	$(ZIRCON_SCRIPTS_DIR)/run-zircon -o $(ZIRCON_X64_OUT_DIR) -a x86-64 -q $(QEMU_DIR) -x $(FUCHSIA_OUT_PREFIX)-x86-64/user.bootfs


boot: x64 tools
	$(TOOLS_OUT_DIR)/bootserver -1 $(ZIRCON_GCC_X64_OUT_DIR)/zircon.bin $(ALL_BOOT_ARGS)

fuchsia-boot: fuchsia-x64 tools
	$(TOOLS_OUT_DIR)/bootserver -1 $(ZIRCON_GCC_X64_OUT_DIR)/zircon.bin $(FUCHSIA_OUT_PREFIX)-x86-64/user.bootfs $(ALL_BOOT_ARGS)


reboot: tools
	$(TOOLS_OUT_DIR)/netruncmd : "dm reboot"

trace:
	:

listen: tools
	$(TOOLS_OUT_DIR)/loglistener

symbolize:
	:
