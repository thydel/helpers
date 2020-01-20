. := $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included))

# strange timestamp out of range using 1970-01-01
.adam:; touch -d 1971-01-01 $@

ultimo := /proc/self
$(ultimo):;

old-or-young := && echo .adam || echo $(ultimo)

need-adam  = $(if $($(strip $1-need-adam)),, $(eval $(strip $1-need-adam := _)) $(eval $(strip $1:: .adam)))

lineinfile = $(eval $(strip $2:: $(shell grep -q $1 $2 $(old-or-young)); echo $1 >> $$@))
lineinfile += $(call need-adam, $2)
