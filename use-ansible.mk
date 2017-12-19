#!/usr/bin/make -f

top:; @date

self    := $(lastword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
$(self):;

# get various ansible versions

base := $(or $(GIT_CLONE_BASE), ~/usr/ext)
version := devel
version := stable-2.2
version := stable-2.3
version := stable-2.4
version := stable-2.3 stable-2.4 devel

stables  := 1.9 2.0 2.1 2.2 2.3 2.4
versions := $(stables:%=stable-%) devel

url := git://github.com/ansible/ansible.git

clone = (cd $(base); git clone --branch $(version) --recursive $(url) ansible-$(version))
pull  = (cd $(base)/ansible-$(version); git pull --rebase; git submodule update --init --recursive)
setup = source $(base)/ansible-$(version)/hacking/env-setup -q
pkgs  = sudo aptitude install python-jinja2 python-netaddr
emacs  = (progn
emacs +=   (setenv "ANSIBLE_HOME" (expand-file-name "$(base)/ansible-$(version)"))
emacs +=   (setenv "PYTHONPATH" (expand-file-name "$(base)/ansible-$(version)/lib"))
emacs +=   (setenv "PATH" (concat (expand-file-name "$(base)/ansible-$(version)/bin:") (getenv "PATH"))))

help:
	@$(foreach version,$(versions),echo '$(clone)';)
	@echo
	@$(foreach version,$(versions),echo '$(pull)';)
	@echo
	@$(foreach version,$(versions),echo '$(setup)';)
	@echo
	@$(foreach version,$(versions),echo '$(strip $(emacs))';)
	@echo
	@echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})'

short:
	@$(foreach version,$(version),echo '$(pull)';)
	@$(foreach version,$(version),echo '$(setup)';)
	@echo 'source <(< ~/.gpg-agent-info xargs -i echo export {})'

clone pull setup:; @echo '$($@)'

roles:; ansible-galaxy install -i -r requirements.yml

.PHONY: top help clone pull setup roles
