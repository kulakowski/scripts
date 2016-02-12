all: fusl

.PHONY: *

mojob := mojo/tools/mojob.py

release := no
ifeq ($(release), no)
build_dir := out/Debug
build_variant := --debug
else
build_dir := out/Release
build_variant := --release
endif

clean:
	@rm -rf $(build_dir)

sync:
	@$(mojob) sync

gen: gn
gn:
	@$(mojob) gn $(build_variant)

build: gn
	@$(mojob) build $(build_variant)

fusl: gn
	@ninja -C $(build_dir) fusl

test: build
	$(mojob) test $(build_variant)
