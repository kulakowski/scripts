dcf ?= no

all:
	@:

%:
ifeq ($(dcf), no)
	@clone $@
else
	@clone-dcf $@
endif
