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

####

infra-clone         := Clone a new node
misc-play           := Various playbooks
innobackupx-wrapper := Use innobackupx via cron

new := infra-clone misc-play innobackupx-wrapper

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

list-repos.api   = $(github)/users/$(user)/repos
all-repos.jq    := .[] | .name
forked-repos.jq := .[] | select(.fork) | .name
mine-repos.jq   := .[] | select(.fork | not) | .name
repos-sets      += all forked mine

list-repos = curl -s $(list-repos.api) | jq -r '$($1-repos.jq)'
$(repos-sets:%=list/%):; $(call list-repos,$(@F))

define list-repos-help
echo;
echo 'github [thyepi|thydel] list/[all|forked|mine]';
echo 'github [thyepi|thydel] create/$new-repo';
echo 'github [thyepi|thydel] clone/$existing-repo';
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
echo "git commit -m 'Makes firts commit'";
echo "git status";
echo "git diff";
echo "git add . -n";
echo "git log --oneline";
endef
help += lines
lines:; @$(strip $($@))

####

help: $(help);
.PHONY: help $(help)

####

epi     = user := thyepi
thy     = user := thydel
vartar := epi thy

$(vartar):; @: $(eval $($@))
