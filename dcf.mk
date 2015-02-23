release := no
ifeq ($(release), no)
flag_release :=
else
flag_release := --release
endif

verbose := no
ifeq ($(verbose), no)
flag_verbose :=
else
flag_verbose := --verbose
endif

phab := no
ifeq ($(phab), no)
flag_phab :=
else
flag_phab := --phabricator_diff $(shell arc-current-diff)
endif

flags := $(flag_release) $(flag_verbose) $(flag_phab)

xcode := ./setup-apportable-xcode.sh $(flags)

arch := armv7a-neon

xct := ./tests/xct.py --arch $(arch) $(flags)

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

tengu: toolchain
	$(xcode) --tengu $(filter-out $@,$(MAKECMDGOALS))

clean:
	$(xcode) --uninstall $(filter-out $@,$(MAKECMDGOALS))

test: toolchain
	$(xct) $(filter-out $@,$(MAKECMDGOALS))

just_test: toolchain
	$(testcl) --skip_load $(filter-out $@,$(MAKECMDGOALS))

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
