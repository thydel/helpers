#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony

install := /usr/local/bin
install.p := $(install)/%
$(install.p): %.sh; install $< $@

~ := lf
$~ := lf lf2
$~.installed := $($~:%=$(install.p))
$~: phony $($~.installed)
