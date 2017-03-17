#!/usr/bin/make -f

top: self-help;

staff := staff
$(if $(shell getent group $(staff) | grep -q $(USER) || date),$(error $(USER) not in group $(staff)))

self    := $(lastword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
helper  := $(notdir $(self))
$(self):;

use-ansible.mk := use-ansible

ifeq ($(dir $(self)),./)
install_dir  := /usr/local/bin
install_list := $(self) git-config.yml use-ansible.mk
$(install_dir)/%: %; install $< $@; $(if $($*),(cd $(@D); ln -sf $* $($*)))
install: $(install_list:%=$(install_dir)/%);
endif

git-config: .git/config;
.git/config: $(install_dir)/git-config.yml; $(<F) -e repo=$(CURDIR)
$(install_dir)/git-config.yml:;

ansible:; use-ansible help

define self-help
echo '$(helper) env';
echo '$(helper) ansible';
echo '$(helper) git';
echo '$(helper) git-config';
echo '$(helper) help';
endef
help += self-help

define env
echo 'echo $$PATH | grep ":\.:*" | line > /dev/null || export PATH=$$PATH:.';
echo 'export TERM=eterm-color';
echo 'export GIT_PAGER=cat';
echo "export GIT_EDITOR='emacsclient -s epi -c'";
echo "export GIT_EDITOR='emacsclient -s thy -c'";
endef
help += env

define git
echo 'git config push.default simple';
echo 'git config user.email t.delamare@epiconcept.fr';
echo 'git config user.email t.delamare@laposte.net';
echo 'git config tag.sort version:refname';
echo 'echo '*~' >> .gitignore';
echo 'echo '*~' >> .git/info/exclude';
echo 'echo 'tmp/' >> .git/info/exclude';
echo 'env DISPLAY=:0.0 git rebase -i HEAD~2';
echo "git status";
echo "git diff";
echo "git add . -n";
echo "git add .";
echo "git commit -m 'Makes first commit'";
echo "git log --oneline";
endef
help += git

$(help):; @$(strip $($@))
help: $(help);

.PHONY: top install git-config ansible help $(help)
%.yml:

$(vartar):; @: $(eval $($@))
