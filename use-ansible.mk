#!/usr/bin/make -f

top:; @date

self    := $(lastword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
$(self):;

# get various ansible versions

base := ~/usr/ext
version := devel
version := stable-2.2
version := stable-2.3

stables  := 1.9 2.0 2.1 2.2 2.3
versions := $(stables:%=stable-%) devel

url := git://github.com/ansible/ansible.git

clone = (cd $(base); git clone --branch $(version) --recursive $(url) ansible-$(version))
pull  = (cd $(base)/ansible-$(version); git pull --rebase; git submodule update --init --recursive)
setup = source $(base)/ansible-$(version)/hacking/env-setup -q
pkgs  = sudo aptitude install python-netaddr

help:
	@$(foreach version,$(versions),echo '$(clone)';)
	@echo
	@$(foreach version,$(versions),echo '$(pull)';)
	@echo
	@$(foreach version,$(versions),echo '$(setup)';)
	@echo
	@echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})'

clone pull setup:; @echo '$($@)'

roles:; ansible-galaxy install -i -r requirements.yml

.PHONY: top help clone pull setup roles
