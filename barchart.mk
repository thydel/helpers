#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL := $(shell which bash)

.DEFAULT_GOAL := main
.DELETE_ON_ERROR:

xsize ?= 800
ysize ?= 600

define plot
set terminal pngcairo size $(xsize),$(ysize);
$(if $(MAKECMDGOALS), set output "$@";)
$(if $(xlabel), set xlabel "$(xlabel)");
$(if $(ylabel), set ylabel "$(ylabel)");
unset key;
set xtics rotate;
set boxwidth 0.75;
set style fill solid;
$(if $(title), set title "$(title)");
plot $(if $(MAKECMDGOALS), "$<", "<cat") using 2:xtic(1) with boxes;
endef

plotcmd = gnuplot -e '$(strip $(plot))'

%.png: %.txt; < $< $(plotcmd) > $@

main:; @$(plotcmd)
