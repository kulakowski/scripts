.PHONY: *

FILES := \
	bin/main.dart \
	lib/graph.dart \
	lib/parser.dart \
	lib/recipe.dart \
	lib/session.dart \

all: test check

test:
	pub run test test/recipe_test.dart

run:
	dart bin/main.dart

check:
	dartanalyzer --strong $(FILES) | \
	egrep -v '(will need runtime check to cast to type .*<|No issues found| warnings found)'

format:
	git cl format
