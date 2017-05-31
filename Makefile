top:; @date

MAKEFLAGS += -Rr
SHELL := /bin/bash
Makefile:;

%.html: %.md; pandoc -s -o $@ $<
html: $(patsubst %.md,%.html,$(wildcard *.md));
.PHONY: html

gh-md-toc  = wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc;
gh-md-toc += chmod +x $@
gh-md-toc:; $($@)

lineinfile.mk:;
include lineinfile.mk

lines := .adam gh-md-toc *html README-toc.md
. := $(foreach _, $(lines), $(call lineinfile, $_, .gitignore))

once: gh-md-toc .gitignore
.PHONY: once

%-toc.md: %-notoc.md; gh-md-toc $< > $@

2toc  = test -f $@ && chmod u+w $@;
2toc += include.awk $< > $@ 
2toc += && chmod a-w $@
%.md: %-notoc.md %-toc.md; $(2toc)

main: once README.md HISTORY.md
.PHONY: main
