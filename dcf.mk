release ?= no
ifeq ($(release), no)
release_flag :=
else
release_flag := --release
endif
xcode := ./setup-apportable-xcode.sh $(release_flag)
arch := armv7a-neon
xct := ./tests/xct.py --arch $(arch) $(release_flag)
dcf := $(shell basename $(shell git rev-parse --show-toplevel))
dt := bin/dt
update_toolchain := update_toolchain
branch :=

.phony: *

all: toolchain
	@:

xc: toolchain
	$(xcode) $(filter-out $@,$(MAKECMDGOALS))

sb: toolchain
	$(xcode) --sbandroid $(filter-out $@,$(MAKECMDGOALS))

clean:
	$(xcode) --clean $(filter-out $@,$(MAKECMDGOALS))

test: toolchain
	$(xct) $(filter-out $@,$(MAKECMDGOALS))

toolchain: checkout
	@$(dt) $(update_toolchain) $(filter-out $@,$(MAKECMDGOALS))

checkout:
ifdef branch
	git checkout $(branch)
else
	@:
endif

%:
	@:
