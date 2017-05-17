. := $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included))

name ?= thydel
base ?= $(HOME)/usr/$(name).d
list := $(sort $(patsubst $(base)/%/.git, %, $(wildcard $(base)/*/.git)))

get-url = $(shell git -C $(base)/$(strip $1) remote get-url origin)
$(strip $(foreach _, $(list), $(eval $_ := $(call get-url, $_))))

define print
echo '# generated via include mk-git-list.mk';
echo;
echo 'top:; @date';
echo;
echo '~  := $1';
echo '$$~  =';
$(foreach _, $(list), echo '$$~ += $_';)
echo;
($(foreach _, $(list), echo '$_ := $($_)';)) | column -t;
echo;
echo '$$($1):; git clone $$($$@)';
echo '$1: $$($1);';
echo '.PHONY: $1';
endef

$(name).mk:; @($(strip $(call print,$(name)))) > $@; chmod 444 $@
main: $(name).mk;
clean:; @rm -f $(name).mk
.PHONY: main clean
