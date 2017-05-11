#!/usr/bin/make -f

SHELL := $(shell which bash)

top:; @date
.PHONY: top

self    := $(lastword $(MAKEFILE_LIST))
dir     := $(dir $(abspath $(self)))
$(self) := $(basename $(self))
name    := $(notdir $($(self)))
$(self):;

. := $(and $(shell test -d .git || date),$(error not in a git dir))

targets := 
targets.help := targets (including phony ones) run commands
meta-targets :=
meta-targets.help := meta-targets are sequence of targets
pseudo-targets :=
pseudo-targets.help := pseudo-targets set paramaters and must be given before targets

# http://stackoverflow.com/questions/2458042/restore-files-modification-time-in-git
# http://stackoverflow.com/questions/2179722/checking-out-old-file-with-original-create-modified-timestamps

restore-dates.help := Set modification time of working files to either commiter (default) or author date
targets += restore-dates

Author    := @%at
Author    := %ai
Committer := @%ct
Committer := %ci

restore-dates  =
restore-dates +=   git ls-files -z
restore-dates += | xargs -0i git log -1 --format='touch -d "$($(DATE))" "{}";' {}
restore-dates += | $(RUN)

touch-dirs.help := Set modification time of working dir to begining of time
touch-dirs.help += So that propagate-date works correctly
targets += touch-dirs

touch-dirs  =
touch-dirs +=   find -name .git -prune -o -type d ! -name . -print0
touch-dirs += | grep -vz '^./.git$$'
touch-dirs += | xargs -0 echo touch -d @0
touch-dirs += | $(RUN)

propagate-date.help := propagate date of newest entry of each dirs up to top dir
targets += propagate-date

propagate-date = propagate-date $(EXEC) --skipd .git $(VERB) .

dates := restore-dates touch-dirs propagate-date

dates.help := $(dates)
meta-targets += dates

$(dates):; $($@)
.PHONY: $(dates)
dates: $(dates)
.PHONY: dates

# git-config(1)
# « If this variable is set to false, the bytes higher than 0x80 are not
# quoted but output as verbatim »

config.help := Do not quote non ascii char in file name
targets += config

core.quotePath/false:; git config --get $(@D) > /dev/null || git config --local $(@D) $(@F)
config: core.quotePath/false
.PHONY: config core.quotePath/false

RUN  := cat
EXEC := --no-exec
VERB := -v
DATE := Committer
define run
RUN  := dash
EXEC :=
VERB :=
endef
author := DATE := Author

vartar := run author

$(vartar):; @: $(eval $($@))

run.help := All targets default to dry-run mode, run modifier go run-mode
pseudo-targets += run

author.help := Use git author date instead of committer date
pseudo-targets += author

help += echo;
help += $(foreach t, targets meta-targets pseudo-targets,
help +=   echo -e " $t: $($t)";
help +=   echo -e " $t: $($t.help)\n";
help +=   $(foreach h, $($t),
help +=     echo -e "\t$h: $($h.help)";
help +=   )
help +=	  echo;
help += )

help.help := This help
targets += help
help:; @$(strip $($@))
.PHONY: help
.DEFAULT_GOAL := help
