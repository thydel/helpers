#!/usr/bin/make -f

top: self-help;

staff := staff
$(if $(shell getent group $(staff) | grep -q $(USER) || date),$(error $(USER) not in group $(staff)))

self    := $(lastword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
helper  := $(notdir $(self))
$(self):;

mk :=

use-ansible.mk:;
use-ansible.mk := use-ansible
mk += use-ansible.mk

github-helper.mk:;
github-helper.mk := github
mk += github-helper.mk

git-index-filter.mk:;
git-index-filter.mk := git-move-whole-tree-in-subdir
git-index-filter.mk += git-rename-top-subdir
mk += git-index-filter.mk

yml :=
yml += git-config.yml
yml += init-play-dir.yml

install_dir  := /usr/local/bin
ifeq ($(dir $(self)),./)
install_list := $(self) $(yml) $(mk)
$(install_dir)/%: %; install $< $@; $(if $($*),(cd $(@D); $(strip $(foreach _, $($*), ln -sf $* $_;))))
install: $(install_list:%=$(install_dir)/%);
else
$(install_dir)/git-config.yml:;
endif

git-config: .git/config;
.git/config: $(install_dir)/git-config.yml .stone/git-config; $(<F) -i localhost, -c local -e repo=$(CURDIR)
.stone/git-config: .stone; touch $@
.stone:; mkdir $@

ansible:; use-ansible short

init-play-dir: .ansible.cfg
.ansible.cfg = $(<F) -i localhost, -c local -e repo=$(CURDIR) -e use_ssh_config=True $(DRY) $(DIF)
.ansible.cfg: $(install_dir)/init-play-dir.yml; $($@)

define self-help
echo '$(helper) env';
echo '$(helper) ansible';
echo '$(helper) git';
echo '$(helper) git-index-filter';
echo '$(helper) git-config';
echo '$(helper) init-play-dir';
echo '$(helper) help';
endef
help += self-help

define env
echo 'echo $$PATH | grep ":\.:*" | line > /dev/null || export PATH=$$PATH:.';
echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})';
echo 'echo export SSH_AUTH_SOCK=/$$(sudo lsof -a -U -u $$USER -c ssh-agent -Fn -w | tail -1 | cut -d/ -f2-)';
echo 'export TERM=eterm-color';
echo 'export GIT_PAGER=cat';
echo "export GIT_EDITOR='emacsclient -s epi -c'";
echo "export GIT_EDITOR='emacsclient -s thy -c'";
endef
help += env

define git-index-filter
echo 'git-move-whole-tree-in-subdir $$subdir show=1';
echo 'git-move-whole-tree-in-subdir $$subdir';
echo 'git-rename-top-subdir $$newname renamed=$$oldname show=1';
echo 'git-rename-top-subdir $$newname renamed=$$oldname';
endef
help += git-index-filter

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

DRY := -C
DIF :=

run := DRY :=
dif := DIF := -D

vartar := run dif

$(vartar):; @: $(eval $($@))
