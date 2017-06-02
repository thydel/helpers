#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL := $(shell which bash)

top: self-help;

staff := staff
$(if $(shell getent group $(staff) | grep -q $(USER) || date),$(error $(USER) not in group $(staff)))

self    := $(lastword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
helper  := $(notdir $(self))
$(self):;

define add-mk
$(eval $1.mk:;)
$(eval $1.mk := $(firstword $2))
$(foreach _, $(wordlist 2, $(words $2), $2), $(eval $1.mk += $_))
$(eval mk += $1.mk)
endef

mk :=
mks := use-ansible github-helper git-index-filter git-dates git-md
github-helper := github
git-index-filter := git-move-whole-tree-in-subdir
git-index-filter += git-rename-top-subdir
git-index-filter += git-merge-top-subdir

$(strip $(foreach _, $(mks), $(call add-mk, $_, $(or $($_), $_))))

awk :=
include.awk := include
awk += include.awk
$(awk):;

yml :=
yml += git-config.yml
yml += init-play-dir.yml
yml += hg2git.yml
$(yml):;

sharedir  := /usr/local/share
sharedirs := make ansible
install-share :=

$(sharedirs:%=$(sharedir)/%/.stone):; mkdir -p $(@D); touch $@

define Install-Share
$(eval $2:;)
$(eval $(sharedir)/$1/$2: $2 $(sharedir)/$1/.stone; install -m 0644 $$< $$@)
$(eval install-share += $(sharedir)/$1/$2)
endef

$(strip $(call Install-Share,make,lineinfile.mk))
$(strip $(foreach _, ansible git,$(call Install-Share,ansible,check-$_-version.yml)))

install-share: $(install-share)
.PHONY: install-share

install_dir := /usr/local/bin
ifeq ($(dir $(self)),./)
install_list := $(self) $(yml) $(mk) $(awk)
$(install_dir)/%: %; install $< $@; $(if $($*),(cd $(@D); $(strip $(foreach _, $($*), ln -sf $* $_;))))
install: install-share $(install_list:%=$(install_dir)/%);
else
$(install_dir)/git-config.yml:;
endif

git-config: .git/config;
.git/config: $(install_dir)/git-config.yml .stone/git-config; $(<F) -i localhost, -c local -e repo=$(CURDIR)
.stone/git-config: .stone; touch $@
.stone:; mkdir $@

ansible:; use-ansible short
ansible/help:; use-ansible $(@F)

git-md git-dates:; $@ help

init-play-dir: .ansible.cfg
.ansible.cfg = $(<F) -i localhost, -c local -e repo=$(CURDIR) -e use_ssh_config=True $(DRY) $(DIF)
.ansible.cfg: $(install_dir)/init-play-dir.yml; $($@)

hg2git  =    test -d "$(hg)"
hg2git += && test -d "$(2git)"
hg2git += && $@.yml -i localhost, -c local -e hg=$(hg) -e git=$(2git) $(DRY) $(DIF)
hg2git:; $($@)

define self-help
echo '$(helper) start';
echo '$(helper) env';
echo '$(helper) git_env';
echo '$(helper) ansible_env';
echo '$(helper) ansible';
echo '$(helper) ansible/help GIT_CLONE_BASE=';
echo '$(helper) git';
echo '$(helper) git-index-filter';
echo '$(helper) git-config';
echo '$(helper) git-dates';
echo '$(helper) git-md';
echo '$(helper) init-play-dir';
echo '$(helper) hg2git hg="" 2git=""';
echo '$(helper) hist';
echo '$(helper) help';
echo 'source <(helper env)';
endef
help += self-help

define env
echo 'echo $$PATH | grep ":\.:*" | line > /dev/null || export PATH=$$PATH:.';
echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})';
echo 'export TERM=eterm-color';
echo 'export PAGER=cat';
echo 'export GIT_PAGER=cat';
echo "export GIT_EDITOR='emacsclient -s epi -c'";
echo '# echo export SSH_AUTH_SOCK=/$$(sudo lsof -a -U -u $$USER -c ssh-agent -Fn -w | tail -1 | cut -d/ -f2-)';
endef
help += env

define hist
echo 'hist-file() { echo history | env -i HISTFILE="$$1" HISTTIMEFORMAT="%F+%T " bash --norc -i 2> /dev/null; }';
echo 'histhost() { if test "$$1"; then echo $$HISTDIR/../$$1; else echo $$HISTDIR; fi; }';
echo $$'hh() { source <(find $$(histhost $$2) -type f | xargs grep -l "$$1" | xargs -i echo "hist-file {} | grep \'$$1\'") | sort -k2; }';
endef
help += hist

define git_env
echo 'export GIT_PAGER=cat';
echo "export GIT_EDITOR='emacsclient -s epi -c'";
echo "export GIT_EDITOR='emacsclient -s thy -c'";
endef
help += git_env

define ansible_env
echo 'export ANSIBLE_STDOUT_CALLBACK=debug';
echo 'export ANSIBLE_STDOUT_CALLBACK=default';
echo 'export ANSIBLE_STDOUT_CALLBACK=dense';
echo 'export ANSIBLE_STDOUT_CALLBACK=json';
echo 'export ANSIBLE_STDOUT_CALLBACK=minimal';
echo 'export ANSIBLE_STDOUT_CALLBACK=oneline';
echo 'export ANSIBLE_STDOUT_CALLBACK=selective';
echo 'unset ANSIBLE_STDOUT_CALLBACK';
endef
help += ansible_env

define git-index-filter
echo 'git-move-whole-tree-in-subdir $$subdir show=1';
echo 'git-move-whole-tree-in-subdir $$subdir';
echo 'git-rename-top-subdir $$newname renamed=$$oldname show=1';
echo 'git-rename-top-subdir $$newname renamed=$$oldname';
echo 'git-merge-top-subdir $$subdir show=1';
echo 'git-merge-top-subdir $$subdir';
endef
help += git-index-filter

define git
echo 'git config push.default simple';
echo 'git config user.email t.delamare@epiconcept.fr';
echo 'git config user.email t.delamare@laposte.net';
echo 'git config tag.sort version:refname';
echo "echo '*~' >> .gitignore";
echo "echo '*~' >> .git/info/exclude";
echo "echo 'tmp/' >> .git/info/exclude";
echo "mkdir meta; echo -e '---\\\n\\\ndependencies:' >> meta/main.yml";
echo 'env DISPLAY=:0.0 git rebase -i HEAD~2';
echo "git filter-branch --msg-filter 'echo -n \"\$$prefix \" && cat'";
echo "git filter-branch --msg-filter 'sed \"s/\$$from/\$$to/\"'";
echo "git status";
echo "git diff";
echo "git add . -n";
echo "git add .";
echo "git commit -m 'Makes first commit'";
echo "git log --oneline";
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo echo {}\; git -C {} status -sb | dash";
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo echo {}\; git -C {} fetch | dash";
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo git-dates run dates repo={} | dash";
endef
help += git

define start
echo 'gpg-agent --daemon --write-env-file';
echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})';
echo 'pass dummy';
endef
help += start

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
