SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

build:
	swift build -c release

test:
	swift test

swift-release-notes: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: swift-release-notes
	@install -d "$(bindir)"
	@install "$(shell swift build -c release --show-bin-path)/swift-release-notes" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/swift-release-notes"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release
