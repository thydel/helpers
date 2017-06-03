#!/usr/bin/make -f

.DEFAULT_GOAL := help
Help = $(eval HELP := T)
. := $(if $(MAKECMDGOALS),,$(Help))
. := $(and $(filter $(MAKECMDGOALS), help), $(Help))
ifdef HELP

fix:
	@echo 'sudo aptitude install make-guile asciidoc'

help:
	@echo 'make -k deps      # may required to ignore errrors on first run'
	@echo 'make deb-src      # must be run once'
	@echo 'make buildpackage # second stage'
	@echo 'make build        # run loop after bootstrap'
	@echo 'make install      # use gdebi to install newly build package'
	@echo 'make once         # populate .gitignore'
	@echo 'make clean        # remove dpkg-depcheck output'
	@echo 'make top          # trigger dpkg-depcheck processing'

else

top:; @date
.PHONY: top

self    := $(lastword $(MAKEFILE_LIST))
dir     := $(dir $(abspath $(self)))
$(self) := $(basename $(self))
build   := $(notdir $($(self)))
$(self):;

base    := $(or $(GIT_CLONE_BASE), ~/usr/ext)
version := devel
version := $(or $(GIT_ANSIBLE_VERSION), stable-2.3)

codename := $(shell lsb_release -cs)
release  := $(shell lsb_release -rs)

dpkg-depcheck = dpkg-depcheck -m -f -warn-local -o $(dir)/$@ 

deb-src.cwd := $(base)/ansible-$(version)
deb-src.cmd := make deb-src

deb-src.run = (cd $(deb-src.cwd); $(deb-src.cmd))
deb-src.out = (cd $(deb-src.cwd); $(dpkg-depcheck) $(deb-src.cmd))

build_version := $(shell cd $(deb-src.cwd); awk '{print$$1}' VERSION)

buildpackage.cwd := $(deb-src.cwd)/deb-build/unstable/ansible-$(build_version)
buildpackage.cmd := dpkg-buildpackage -us -uc -rfakeroot

buildpackage.run = (cd $(buildpackage.cwd); $(buildpackage.cmd))
buildpackage.out = (cd $(buildpackage.cwd); $(dpkg-depcheck) $(buildpackage.cmd))

out2mk  =
out2mk += (
out2mk += echo -n '$1 := ';
out2mk += < $<
out2mk +=   grep '^  '
out2mk += | sed -e 's/^  //' -e 's/:.*//'
out2mk += | sort | tr '\n' ' ';
out2mk += echo;
out2mk += )
out2mk += > $@

prefix := $(build)-$(version)-$(codename)-$(release)

out := $(prefix)-deb-src.out $(prefix)-buildpackage.out

$(out): $(prefix)-% :; $($*)
$(prefix)-deb-src.mk $(prefix)-buildpackage.mk: $(prefix)-%.mk : $(prefix)-%.out; $(call out2mk,$*)

$(self): $(prefix)-deb-src.mk $(prefix)-buildpackage.mk

include $(prefix)-deb-src.mk
include $(prefix)-buildpackage.mk

clean:; rm $(out)
.PHONY: clean

####

lineinfile.mk:;
include lineinfile.mk

lines := $(out)
. := $(foreach _, $(lines), $(call lineinfile, $_, .gitignore))

gitignore: .gitignore
.PHONY: gitignore

####

deps := gdebi build-essential asciidoc $(sort $(deb-src) $(buildpackage))
deps:; sudo aptitude install $($@)
once: .gitignore deps;

.PHONY: deps once

deb-src buildpackage: % :; $($*.run)
build: deb-src buildpackage;

.PHONY: deb-src buildpackage build

deb := $(abspath $(wildcard $(buildpackage.cwd)/../*.deb))
install := sudo gdebi $(deb)
install:; $($@)

main: build install

.PHONY: install main

endif
