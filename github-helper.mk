#!/usr/bin/make -f

make := $(lastword $(MAKEFILE_LIST))
$(make):;
SHELL := bash
.DEFAULT_GOAL := main

main:; @date

####

github := https://api.github.com
users  := thydel thyepi
user   ?= thydel
.      := $(or $(filter $(user),$(users)),$(error $(user) not in $(users)))

vartar :=
varset :=
epi     = user := thyepi
thy     = user := thydel
vartar += epi thy
varset += user

####

amr-disk-part       := Ansible role to export disk partitioning ansible modules.
ar-common-tools     := Ansible role to install basics pkgs after clone, wrapped by route add and del.
ar-if-rename-first  := Ansible role to rename first eth iface, then fix its config.
ar-vsphere-clone    := Ansible role to Clone a new VM via pysphere, then setup DHCPd and reconfigure VM id.
ar-vsphere-disk-add := Ansible role to add a disk to a VM via pysphere, then partition, mkfs and crypt.
ar-vsphere-if-add   := Ansible role to add an eth iface to a VM via pysphere, then configure it.
innobackupx-wrapper := Use innobackupx via cron
misc-play           := Various playbooks

~  := epi-repos
$~ :=
$~ += amr-disk-part
$~ += ar-common-tools
$~ += ar-if-rename-first
$~ += ar-vsphere-clone
$~ += ar-vsphere-disk-add
$~ += ar-vsphere-if-add
$~ += innobackupx-wrapper
$~ += misc-play

ar-hg-etc-com       := Ansible role to commit etc mercurial repo
one-liner           := Curated bash history
debconf-preferences := Configure debconf
reset-known_hosts   := Reset ~/.ssh/known_hosts for a rem node on local node
ar-jsonnet          := Ansible role to compile and install jsonnet
ar-ntpdate	    := Ansible role to install and configure ntpdate
ar-make		    := Ansible role to run make
ar-user-account	    := Ansible role to create a user account and manage user keys
ar-add-users-to-group := Ansible role to add users to a group
helpers             := Various helpers
ar-reset-known_hosts-entry := Ansible role to reset a known_hosts entry on controller
ar-remote-reset-known_hosts-entry := Ansible role to reset a known_hosts entry

~  := thy-repos
$~ :=
$~ += one-liner
$~ += debconf-preferences
$~ += reset-known_hosts
$~ += ar-hg-etc-com
$~ += ar-jsonnet
$~ += ar-ntpdate
$~ += ar-make
$~ += ar-user-account
$~ += ar-add-users-to-group
$~ += helpers
$~ += ar-reset-known_hosts-entry
$~ += ar-remote-reset-known_hosts-entry

####

help :=

# Ensure we won't block on pass because gpg-agent absent or key not in
# cache

gpg-agent-info-export = < ~/.gpg-agent-info xargs -i echo export {}
gpg-agent-info-export:; @echo 'source <($(gpg-agent-info-export))'
help += gpg-agent-info-export

check-pass := timeout 1 pass dummy < /dev/null > /dev/null 2>&1 || date
check-pass:; @echo '$(check-pass)'
help += check-pass
$(eval $(shell $(gpg-agent-info-export)))
$(and $(shell $(check-pass)),$(info source <($(gpg-agent-info-export)))$(error check-pass failed))
pass-dummy:; @$(check-pass)
.PHONY: pass-dummy

# Ensure we won't fail because my agent reach his maximum lifetime

$(if $(filter $(shell ssh-add -l > /dev/null || echo T),T),$(error your agent has no keys))

####

show   ?= show-name+desc
name    = show := show-name
desc    = show := show-desc
vartar += name desc
varset += show

show-name.jq      := .name
show-name.sh      := cat
show-desc.jq      := .description
show-desc.sh      := cat
show-name+desc.jq := (.name, .description)
show-name+desc.sh := paste - - | column -ts$$'\t'

list-repos.api   = $(github)/users/$(user)/repos?per_page=100
all-repos.jq    := .[] | $($(show).jq)
forked-repos.jq := .[] | select(.fork) | $($(show).jq)
mine-repos.jq    = .[] | select(.fork | not) | $($(show).jq)
repos-sets      += all forked mine

list-repos = curl -s $(list-repos.api) | jq -r '$($1-repos.jq)' | $($(show).sh)
$(repos-sets:%=list/%):; $(call list-repos,$(@F))

ws :=
ws +=

define list-repos-help
echo;
echo 'github [epi|thy] list/[all|forked|mine]';
echo 'github [epi|thy] create/[$(subst $(ws),|,$($(user)-repos))]';
echo 'github [epi|thy] clone/$$existing-repo';
echo;
endef
list-repos-help:; @$(strip $($@))
help += list-repos-help

####

get-repos.api  = $(github)/repos/$(user)/$1
get-repos.jq  := .name

get-repos = curl -s $(call get-repos.api,$1) | jq -e -r '$($0.jq)'
get/%:; -$(call get-repos,$*)

####

create-repos.api := $(github)/user/repos

define create-repos.jq
{
  name: "$1",
  description: "$(or $($1),$(error unknown $1))"
}
endef

define create-repos
(
  p=$$(pass github/$(user));
  jq -n '$(strip $(call create-repos.jq,$1))'
  | curl -s -u $(user):$$p $(create-repos.api) -d @-
)
endef

create/%:; @$(call get-repos,$*) > /dev/null || $(strip $(call create-repos,$*))

####

clone = git clone git@$(user).github.com:$(user)/$*.git
clone/%:; $($(@D))

####

define lines
echo 'echo $$PATH | grep ":\.:*" | line > /dev/null || export PATH=$$PATH:.';
echo 'export GIT_PAGER=cat';
echo "export GIT_EDITOR='emacsclient -s epi -c'";
echo "export GIT_EDITOR='emacsclient -s thy -c'";
echo 'git config push.default simple';
echo 'git config user.email t.delamare@epiconcept.fr';
echo 'git config user.email t.delamare@laposte.net';
echo 'git config tag.sort version:refname';
echo 'echo '*~' >> .gitignore';
echo 'echo '*~' >> .git/info/exclude';
echo 'echo 'tmp/' >> .git/info/exclude';
echo 'env DISPLAY=:0.0 git rebase -i HEAD~2';
echo "git commit -m 'Makes first commit'";
echo "git status";
echo "git diff";
echo "git add .";
echo "git add . -n";
echo "git log --oneline";
endef
help += lines
lines:; @$(strip $($@))

####

help: $(help);
.PHONY: help $(help)

####

$(vartar):; @: $(eval $($@))
$(varset:%=show/%):; @echo $($(@F))
