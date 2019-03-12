#!/usr/bin/make -f

make := $(lastword $(MAKEFILE_LIST))
$(make):;
SHELL := /bin/bash -o pipefail
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
infra-plays-18      := Infra playbooks public parts, reboot
infra-play-users    := Plays for infra-data-users

~  := epi-repos
$~ :=
$~ += amr-disk-part
$~ += amr-pysphere-misc
$~ += ansible-hg-modules
$~ += ar-common-tools
$~ += ar-if-rename-first
$~ += ar-vsphere-clone
$~ += ar-vsphere-disk-add
$~ += ar-vsphere-if-add
$~ += dispatch-log
$~ += infra-misc
$~ += infra-misc-plays
$~ += infra-play-users
$~ += infra-play-users.wiki
$~ += infra-plays-18
$~ += infra-upgrade
$~ += infra-upgrade.wiki
$~ += innobackupx-wrapper
$~ += misc-play
$~ += rsync-pair
$~ += sort-error-log


ap-vmware-utils     := Various ansible playbooks for vmware
ar-add-users-to-group := Ansible role to add users to a group
ar-automysqlbackup  := Ansible role to install and configure automysqlbackup
ar-bsd-mailx        := Ansible role to install and configure bsd-mailx
ar-duplicity        := Ansible role to install and configure duplicity
ar-fill-know_hosts  := Ansible role to reset known_hosts entry on controller and bastion
ar-filter_plugins-misc := Ansible role to provide misc filter plugins
ar-hg-etc-com       := Ansible role to commit etc mercurial repo
ar-jsonnet          := Ansible role to compile and install jsonnet
ar-make		    := Ansible role to run make
ar-multi-screenrc   := Ansible role to install multiple screenrc
ar-my-bash-rc       := Ansible role to install my bashrc
ar-my-dotemacs      := Ansible role to install my dotemacs
ar-my-screenrc      := Ansible role to install my screenrc
ar-nfs-pair	    := Ansible role to configure a NFS pair
ar-ntpdate	    := Ansible role to install and configure ntpdate
ar-regenerate-host-keys := Ansible role to regenerate host keys for cloned nodes
ar-remote-reset-known_hosts-entry := Ansible role to reset a known_hosts entry
ar-reset-known_hosts-entry := Ansible role to reset a known_hosts entry on controller
ar-revaliases-ssmtp := Ansible role for configuring the revaliases file of sSMTP
ar-sudoersd         := Ansible role to configure sudoers.d
ar-user-account	    := Ansible role to create a user account and manage user keys
debconf-preferences := Configure debconf
helpers             := Various helpers
journals            := Various notes
journals-indexed    := Various notes wrapped up
legacy-infra        := Obsolet tools, may contains useful traces
mail-wrapper	    := Filter input lines for patterns then invoque mail with pattern count in subject
misc-notes	    := Various notes
misc-script	    := Various scripts
git-store-dates	    := Store and restore files modification date
ifdef NEVER
one-liner           := Curated bash history
endif
reset-known_hosts   := Reset ~/.ssh/known_hosts for a rem node on local node
WIP                 := Work in progress
packer-infra        := Uses packer to build vmware debian images
ar-rename-user      := Ansible role to rename a user account
mini-play	    := misc tentatively autonomous plays
pysphere-scripts    := misc pysphere scripts
pyvmomi-scripts     := misc pyvmomi scripts

#trim-dupli          := trim duplicity backups
dupli-tools         := Various duplicity tools
dupli-node	    := install and configure duplicity
gpg-tools           := Various gpg tools
jsonnet-mab         := Match and bind

# Privates repos

private-journals    := Various private notes
private-journals-indexed := Various private notes wrapped up
ssh-config          := Try to factorize ssh configs
tmp                 := Temporary zone
tst		    := Test zone
private-bookmarks   := Private bookmarks
private-misc-notes  := Private various notes
private-plays       := Private plays
jsonnet-lib         := Jsonnet lib

# Cloned repos

pyvmomi                   := git@github.com:vmware/pyvmomi.git
pyvmomi-tools		  := git@github.com:vmware/pyvmomi-tools.git
pyvmomi-community-samples := git@github.com:vmware/pyvmomi-community-samples.git
vmware-pyvmomi-examples   := git@github.com:rreubenur/vmware-pyvmomi-examples.git

~  := thy-repos
$~ :=
$~ += ap-vmware-utils
$~ += ar-add-users-to-group
$~ += ar-automysqlbackup
$~ += ar-bsd-mailx
$~ += ar-duplicity
$~ += ar-fill-know_hosts
$~ += ar-filter_plugins-misc
$~ += ar-hg-etc-com
$~ += ar-jsonnet
$~ += ar-make
$~ += ar-multi-screenrc
$~ += ar-my-bash-rc
$~ += ar-my-dotemacs
$~ += ar-my-screenrc
$~ += ar-nfs-pair
$~ += ar-ntpdate
$~ += ar-regenerate-host-keys
$~ += ar-remote-reset-known_hosts-entry
$~ += ar-reset-known_hosts-entry
$~ += ar-revaliases-ssmtp
$~ += ar-sudoersd
$~ += ar-user-account
$~ += debconf-preferences
$~ += helpers
$~ += journals
$~ += journals-indexed
$~ += legacy-infra
$~ += mail-wrapper
$~ += misc-notes
$~ += misc-script
$~ += git-store-dates
ifdef NEVER
$~ += one-liner
endif
$~ += reset-known_hosts
$~ += WIP
$~ += packer-infra
$~ += ar-rename-user
$~ += mini-play
$~ += pysphere-scripts
#$~ += pyvmomi-scripts
#$~ += trim-dupli
$~ += dupli-tools
$~ += dupli-node
$~ += gpg-tools
$~ += jsonnet-mab

$~ += $(epi-repos)

# Privates repos

$~ += private-journals
$~ += private-journals-indexed
$~ += ssh-config
$~ += tmp
$~ += tst
$~ += private-bookmarks
$~ += private-misc-notes
$~ += private-plays
$~ += jsonnet-lib

# Cloned repos

$~ += pyvmomi
$~ += pyvmomi-tools
$~ += pyvmomi-community-samples
$~ += vmware-pyvmomi-examples

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

clone = test -d $* || git clone git@$(user).github.com:$(user)/$*.git
clone/%:; $($(@D))

####

upstream  = test -d .git && git remote -v | grep '$*' &&
upstream += (git remote -v | grep '$($*)' || git remote add upstream $($*)) &&
upstream += git fetch upstream &&
upstream += (git branch | grep tde || (git branch tde; git checkout tde; git push -u origin tde))
upstream/%:; $($(@D))

####

help: $(help);

####

$(vartar):; @: $(eval $($@))
$(varset:%=show/%):; @echo $($(@F))
