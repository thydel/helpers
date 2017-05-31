#!/usr/bin/make -f

MAKEFLAGS += -Rr

top:; @date

name := thyepi
base := $(HOME)/usr/$(name).d

include mk-git-list.mk
