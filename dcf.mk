release := no
ifeq ($(release), no)
flag_release :=
else
flag_release := --release
endif

xcode := ./setup-apportable-xcode.sh $(flag_release)

arch := armv7a-neon

phab := no
ifeq ($(phab), no)
flag_phab :=
else
flag_phab := --phabricator_diff $(shell arc-current-diff)
endif
xct := ./tests/xct.py --arch $(arch) $(flag_release) $(flag_phab)

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
