#!/usr/bin/make -f

MAKEFLAGS += -Rr

top:; @date

name := thyepi
base := $(HOME)/usr/$(name).d
exclude := infra-misc-gh-pages

include mk-git-list.mk
