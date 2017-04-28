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

README-toc.md: README-notoc.md; gh-md-toc $< > $@

README.md  = test -f $@ && chmod u+w $@;
README.md += include.awk $< > $@ 
README.md += && chmod a-w $@
README.md: README-notoc.md README-toc.md; $($@)

main: once README.md
.PHONY: main
