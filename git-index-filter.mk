#!/usr/bin/make -f

make := $(lastword $(MAKEFILE_LIST))
$(make):;

cmd := $(basename $(notdir $(make)))

. := $(or $(filter $(words $(MAKECMDGOALS)), 1), $(error $(make) <subdir>))
. := $(if $(filter $(cmd), git-rename-top-subdir), $(or $(renamed), $(error $(make) <subdir> renamed=<oldname>)))

~ := git-move-whole-tree-in-subdir
# textbook
$~ := s-\t\"*-&newsubdir/-
# we have dash in our names
$~ := s;\t\"*;&$(subdir)/;
# simpler. Don't know if and when git ls-files will quote file names
$~ := s;\t;\t$(subdir)/;
# make it a macro
$~  = s;\t;\t$*/;

~ := git-rename-top-subdir
$~ = s;\t$(renamed)/;\t$*/;

~ := git-merge-top-subdir
$~ = s;\t$*/;\t;

ls-file-sed = git ls-files -s | sed "$($(cmd))"

~  := index-filter
$~  =   $(ls-file-sed)
$~ += | GIT_INDEX_FILE=$$GIT_INDEX_FILE.new git update-index --index-info
$~ +=   && mv $$GIT_INDEX_FILE.new $$GIT_INDEX_FILE

filter-branch = git filter-branch --index-filter '$(index-filter)' HEAD

%:: _; $(strip $(if $(show), $(ls-file-sed), $(filter-branch)))
_:


# from git-filter-branch(1)
#
#       To move the whole tree into a subdirectory, or remove it from there:
#
#           git filter-branch --index-filter \
#                   'git ls-files -s | sed "s-\t\"*-&newsubdir/-" |
#                           GIT_INDEX_FILE=$GIT_INDEX_FILE.new \
#                                   git update-index --index-info &&
#                    mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"' HEAD
