DIFF ?= diff --strip-trailing-cr -u

.PHONY: test
test:
	@pandoc --lua-filter=internal_link.lua sample.md | $(DIFF) expected.html -
