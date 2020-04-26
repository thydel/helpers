#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL := $(shell which bash)

top: self-help;

USER  ?= no_user
staff := staff
$(if $(shell test $(USER) == root || getent group $(staff) | grep -q $(USER) || date),$(error $(USER) not in group $(staff)))

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
mks := github-helper git-index-filter git-dates git-md barchart
github-helper := github
git-index-filter := git-move-whole-tree-in-subdir
git-index-filter += git-rename-top-subdir
git-index-filter += git-merge-top-subdir

$(strip $(foreach _, $(mks), $(call add-mk, $_, $(or $($_), $_))))

awk :=
include.awk := include
awk += include.awk
$(awk):;

python :=
chdir.py := chdir
python += chdir.py
yaml2yaml.py := yaml2yaml
python += yaml2yaml.py
$(python):;

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
install_list := $(self) $(yml) $(mk) $(awk) $(python)
$(install_dir)/%: %; install $< $@; $(if $($*),(cd $(@D); $(strip $(foreach _, $($*), ln -sf $* $_;))))
install: install-share $(install_list:%=$(install_dir)/%);
else
$(install_dir)/git-config.yml:;
endif

git-config: .git/config;
.git/config: $(install_dir)/git-config.yml .stone/git-config; $(<F) -i localhost, -c local -e repo=$(CURDIR) && touch $@
.stone/git-config: .stone; touch $@
.stone:; mkdir $@

ansible:; use-ansible short
ansible/help:; use-ansible $(@F)

git-md git-dates:; $@ help

init-play-dir: .ansible.cfg
.ansible.cfg  = $(<F) -i localhost, -c local -e repo=$(CURDIR)
.ansible.cfg += $(if $(use_ssh_config), -e use_ssh_config=True)
.ansible.cfg += $(if $(vault), -e vault=$(vault))
.ansible.cfg += $(if $(use_merge_hash), -e use_merge_hash=True)
.ansible.cfg += -e use_filter_plugins=True
.ansible.cfg += $(DRY) $(DIF)
.ansible.cfg: $(install_dir)/init-play-dir.yml; $($@)

hg2git  =    test -d "$(hg)"
hg2git += && test -d "$(2git)"
hg2git += && $@.yml -i localhost, -c local -e hg=$(hg) -e git=$(2git) $(DRY) $(DIF)
hg2git:; $($@)

define self-help
echo '$(helper) base-help';
echo '$(helper) more-help';
echo '$(helper) env';
echo 'source <(use-ansible)';
echo 'source <(helper env)';
endef
help += self-help

define base-help
echo '$(helper) start';
echo '$(helper) ssh-agent';
echo '$(helper) env';
echo '$(helper) ansible';
echo '$(helper) git';
echo '$(helper) git2';
echo '$(helper) gh';
echo '$(helper) git-index-filter';
echo '$(helper) git-config';
echo '$(helper) git-dates';
echo '$(helper) git-md';
echo '$(helper) init-play-dir';
echo '$(helper) hg2git hg="" 2git=""';
echo '$(helper) help';
endef
help += base-help

define more-help
echo '$(helper) git_env';
echo '$(helper) ansible_env';
echo '$(helper) ansible/help GIT_CLONE_BASE=';
echo '$(helper) hist';
echo '$(helper) xrandr';
echo '$(helper) aptitude';
echo '$(helper) screen';
echo '$(helper) x2x';
echo '$(helper) rg';
endef
help += more-help

# line(1) is missing from ubuntu
#echo 'echo $$PATH | grep ":\.:*" | line > /dev/null || export PATH=$$PATH:~/.local/bin:.';
# but "head -1" is not similar to "line" because it always exit 0
#echo 'echo $$PATH | grep ":\.:*" | head -1 > /dev/null || export PATH=$$PATH:~/.local/bin:.';

define env
echo 'echo $$PATH | grep ":\.:*" | read || export PATH=$$PATH:~/.local/bin:.';
echo '# source <(< ~/.gpg-agent-info xargs -i echo export {})';
echo 'export TERM=eterm-color';
echo 'export PAGER=cat';
echo "export EDITOR='emacsclient -s thy -c'";
echo 'export GIT_PAGER=cat';
echo "export GIT_EDITOR='emacsclient -s epi -c'";
echo "export PASSWORD_STORE_DIR=~/.password-store/";
echo 'export SSH_AUTH_SOCK=/run/user/$$(id -u $$USER)/user-ssh-agent.socket';
echo 'export EPI_SSH_KEY_FILE=~/.ssh/t.delamare@epiconcept.fr';
echo 'export THY_SSH_KEY_FILE=~/.ssh/t.delamare@laposte.net';
echo '# echo export SSH_AUTH_SOCK=/$$(sudo lsof -a -U -u $$USER -c ssh-agent -Fn -w | tail -1 | cut -d/ -f2-)';
endef
help += env

define hist
echo 'hist-file() { echo history | env -i HISTFILE="$$1" HISTTIMEFORMAT="%F+%T " bash --norc -i 2> /dev/null; }';
echo 'histhost() { if test "$$1"; then echo $$HISTDIR/../$$1; else echo $$HISTDIR; fi; }';
echo $$'hh() { source <(find $$(histhost $$2) -type f | xargs grep -l "$$1" | xargs -i echo "hist-file {} | grep \'$$1\'") | sort -k2; }';
endef
help += hist

define xrandr
echo 'xrandr --output HDMI1 --primary # tdelt2';
echo;
echo 'cvt 1280 1024 60 # some unrecognized monitor';
echo 'xrandr --newmode "1280x1024_60.00"  109.00  1280 1368 1496 1712  1024 1027 1034 1063 -hsync +vsync # wato';
echo 'xrandr --addmode DisplayPort-0 "1280x1024_60.00" # wato';
echo 'xrandr --output DisplayPort-0 --mode "1280x1024_60.00" # wato';
endef
help += xrandr

define aptitude
echo 'aptitude --disable-columns search $$search';
echo 'aptitude --disable-columns search -F '%p_%V_%d' $$search | column -t -s_';
echo 'while deborphan | line; do deborphan | xargs -r aptitude -y remove; done';
endef
help += aptitude

define screen
echo 'pgrep screen | xargs ps hukstart_time | tail -n+2';
endef
help += screen

################

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

define git+
echo "mkdir meta; echo -e '---\\\n\\\ndependencies:' >> meta/main.yml";
echo 'git config push.default simple';
echo 'git config user.email t.delamare@epiconcept.fr';
echo 'git config user.email t.delamare@laposte.net';
echo 'git config tag.sort version:refname';
echo 'git config --local core.quotePath False';
echo "echo '*~' >> .gitignore";
echo "echo '*~' >> .git/info/exclude";
echo "echo 'tmp/' >> .git/info/exclude";
echo "git status";
echo "git diff";
echo "git add . -n";
echo "git add .";
echo "git commit -m 'Makes first commit'";
echo "git log --oneline";
endef
help += git+

define git
echo 'env DISPLAY=:0.0 git rebase -i HEAD~2';
echo;
echo "git filter-branch --msg-filter 'echo -n \"\$$prefix \" && cat'";
echo "git filter-branch -f --msg-filter 'sed \"s/\$$from/\$$to/\"'";
echo 'git update-ref -d refs/original/refs/heads/master';
echo;
echo 'git -C $$src format-patch --stdout --root $$file | git am -p1';
echo 'git -C $$src format-patch --stdout --root | git am -p1 --directory $$adir';
echo;
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo echo {}\; git -C {} status -sb | dash";
echo "ls -d */ext/*/.git | cut -d/ -f1-3 | xargs -i echo echo {}\; git -C {} status -sb | dash";
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo echo {}\; git -C {} fetch | dash";
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo echo {}\; git -C {} pull | dash";
echo "ls -d */.git | cut -d/ -f1 | xargs -i echo git-dates run dates repo={} | dash";
echo;
echo "find -maxdepth 1 -type d | xargs touch -d @0";
echo "propagate-date --update --verbose --skipd .git .";
echo 'find -maxdepth 1 -type l | xargs -i echo echo "test -e \$$(readlink {}) \&\& touch -hr \$$(readlink {}) {}" | dash';
echo;
echo "parallel echo git {2} {1} master ::: manin wato  ::: pull push"
endef
help += git

#echo "f() { find -name .hide -prune -o -name .git | grep -v .hide | xargs dirname; }";
define git2
echo;
echo "f() { touch .hide.txt; find -name .hide -prune -o -name .git | grep -v -f .hide.txt | xargs dirname; }";
echo "f | xargs -i echo echo {}\; git -C {} status -sb | dash";
echo "f | xargs -i echo echo {}\; git -C {} fetch | dash";
echo "f | xargs -i echo echo {}\; git -C {} pull | dash";
echo "f | xargs -i echo git-dates run dates repo={} | dash";
echo;
endef
help += git2

define gh
echo;
echo "gh() { ln -sf config.yml.${GITHUB_USER:-thyepi} ~/.config/gh/config.yml; command gh "$@"; }";
echo;
endef
help += gh

define ssh-agent
echo 'ssh-add ~/.ssh/t.delamare@laposte.net';
echo 'ssh-add ~/.ssh/t.delamare@epiconcept.fr';
echo 'env SSH_AUTH_SOCK=/run/user/$$(id -u thy)/user-ssh-agent.socket ssh-add -l';
echo 'export SSH_AUTH_SOCK=/run/user/$$(id -u thy)/user-ssh-agent.socket';
echo;
echo 'env SSH_AUTH_SOCK=$$XDG_RUNTIME_DIR/keyring/ssh ssh-add -l';
echo 'export SSH_AUTH_SOCK=$$XDG_RUNTIME_DIR/keyring/ssh';
echo 'ls /tmp/ssh-*/* | cut -d. -f2 | xargs ps';
echo 'ls /tmp/ssh-*/* | xargs -i echo env SSH_AUTH_SOCK={} ssh-add -l';
echo 'ls /tmp/ssh-*/* | xargs -i echo export SSH_AUTH_SOCK={}';
endef
help += ssh-agent

define start
echo 'gpg-agent --daemon --write-env-file';
echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})';
echo 'pass dummy';
endef
help += start

define once
echo 'ssh mine gpg2 --export --armor thy | gpg2 --import';
echo 'ssh mine gpg2 --export-secret-keys --armor thy | gpg2 --import';
echo 'ssh mine gpg2 --export-ownertrust | gpg2 --import-ownertrust';
echo;
echo 'sudo aptitude install pinentry-curses pinentry-tty';
echo 'echo pinentry-program /usr/bin/pinentry-tty >> ~/.gnupg/gpg-agent.conf';
echo 'echo default-cache-ttl $((3600 * 24)) >> ~/.gnupg/gpg-agent.conf';
echo 'echo max-cache-ttl $((3600 * 24 * 7)) >> ~/.gnupg/gpg-agent.conf';
echo;
echo 'sudo aptitude install pass';
echo 'git -C ~/usr/perso.d clone pass-store';
echo 'ln -s ~/usr/perso.d/pass-store ~/.password-store';
echo 'pass git pull';
echo;
echo 'ssh -o PreferredAuthentications=password some'
echo 'ssh-copy-id -o PreferredAuthentications=password some'
echo 'ssh some'
echo;
echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PreferredAuthentications=password multi-boot'
echo 'ssh-copy-id -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PreferredAuthentications=password multi-boot'
echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no multi-boot'

endef
help += once

define x2x
echo 'ssh -X right.lan x2x -to :0 -east';
echo 'ssh -X left.lan  x2x -to :0 -west';
endef
help += x2x

define rg
echo 'rgf() { rg -L --no-messages "$$1" | cut -c-$${2:-96}; }';
endef
help += rg

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
