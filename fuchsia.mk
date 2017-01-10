PACKAGES :=
ifeq ($(PACKAGES),)
FLAGS_PACKAGES :=
else
FLAGS_PACKAGES := -m $(PACKAGES)
endif

arm32:
	bash -c ". scripts/env.sh && mset arm32 && mbuild"

arm64:
	bash -c ". scripts/env.sh && mset arm64 && mbuild"

x64:
	bash -c ". scripts/env.sh && mset x86-64 && mbuild"


run-arm32:
	bash -c ". scripts/env.sh && mset arm32 && mbuild && mrun"

run-arm64:
	bash -c ". scripts/env.sh && mset arm64 && mbuild && mrun"

run-x64:
	bash -c ". scripts/env.sh && mset x86-64 && mbuild && mrun"


fuchsia-arm64:
	bash -c ". scripts/env.sh && fset arm64 && fgen $(FLAGS_PACKAGES) && fbuild"

fuchsia-x64:
	bash -c ". scripts/env.sh && fset x86-64 && fgen $(FLAGS_PACKAGES) && fbuild"


fuchsia-run-arm64:
	bash -c ". scripts/env.sh && fset arm64 && fgen $(FLAGS_PACKAGES) && fbuild && frun"

fuchsia-run-x64:
	bash -c ". scripts/env.sh && fset x86-64 && fgen $(FLAGS_PACKAGES) && fbuild && frun"


boot:
	bash -c ". scripts/env.sh && mset x86-64 && mbuild && mboot -1"

fuchsia-boot:
	bash -c ". scripts/env.sh && fset x86-64 && fbuild && fboot -1"

reboot:
	bash -c ". scripts/env.sh && fset x86-64 && freboot"

trace:
	bash -c ". scripts/env.sh && fset x86-64 && ftrace"

symbolize:
	bash -c ". scripts/env.sh && fset x86-64 && fsymbolize"
