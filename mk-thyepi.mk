#!/usr/bin/make -f

MAKEFLAGS += -Rr

top:; @date

export name := thyepi
export base := $(HOME)/usr/$(name).d

include mk-git-list.mk
