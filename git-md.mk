#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL := $(shell which bash)

top:; @date
.PHONY: top

self    := $(lastword $(MAKEFILE_LIST))
dir     := $(dir $(abspath $(self)))
$(self) := $(basename $(self))
name    := $(notdir $($(self)))
$(self):;

git-test := git rev-parse --is-inside-work-tree > /dev/null 2>&1 || date
. := $(and $(shell $(git-test)),$(error not in a git dir))

%.html: %.md; pandoc -s -o $@ $<
html: $(patsubst %.md,%.html,$(wildcard *.md));
.PHONY: html

gh-md-toc  = wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc;
gh-md-toc += chmod +x $@
gh-md-toc:; $($@)

lineinfile.mk:;
include /usr/local/share/make/lineinfile.mk

lines := .adam gh-md-toc *.html *-toc.md
. := $(foreach _, $(lines), $(call lineinfile, $_, .gitignore))

once: gh-md-toc .gitignore
.PHONY: once

%-toc.md: %-notoc.md; gh-md-toc $< > $@

noto2toc  = test -f $@ && chmod u+w $@;
noto2toc += include.awk $< > $@ 
noto2toc += && chmod a-w $@
%.md: %-notoc.md %-toc.md; $(noto2toc)

main: once README.md
.PHONY: main

help:
	@echo git-md once
	@echo git mv afile.md afile-notoc.md
	@echo "echo -e '1i\n#include afile-toc.md\n.\nwq' | ed afile-notoc.md"
	@echo git-md afile.md

grip:; ls *.md | xargs -i echo grip -b {}
.PHONY: grip
