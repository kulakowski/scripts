drive:=

.PHONY: *

bootstrap:
	./build/bootstrap.bash

bootstrap-internal:
	./build/bootstrap.bash
	cp tq-manifest/root.bp .root.bp

fuchsia:
	./fuchsia-build fuchsia/bootimg/pixel2

mojo:
	./fuchsia-build fuchsia/rootimg/mojo

flutter:
	./fuchsia-build fuchsia/flutter

modular:
	./fuchsia-build fuchsia/modular

modular-server:
	./fuchsia-build fuchsia/modular/server

install:
	@sudo ./color/doit.sh $(drive)

llvm:
	./fuchsia-build fuchsia/llvm/cmake

jiri:
	jiri rebuild

update:
	jiri update && jiri update -manifest=gclient
