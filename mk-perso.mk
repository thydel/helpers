#!/usr/bin/make -f

MAKEFLAGS += -Rr

top:; @date

name := perso
base := $(HOME)/usr/$(name).d

include mk-git-list.mk
