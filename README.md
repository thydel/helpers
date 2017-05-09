
Table of Contents
=================

   * [Usage](#usage)
      * [To generate TOC](#to-generate-toc)
      * [Install helpers](#install-helpers)
      * [Meta help](#meta-help)
      * [Typical sequence for a new playbook repos](#typical-sequence-for-a-new-playbook-repos)
         * [environment](#environment)
         * [Config](#config)
      * [Migration tool](#migration-tool)
      * [Github helper](#github-helper)
      * [Git index-filter wrapper](#git-index-filter-wrapper)
   * [Misc](#misc)
      * [GitHub Readme Instant Preview](#github-readme-instant-preview)
   * [Build ansible](#build-ansible)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

# Usage

## To generate TOC

```bash
make once
make README.md
```

## Install helpers

```bash
./helper.mk install
```

Currently tied to [debian](https://wiki.debian.org/SystemGroups)
`staff` *group* (no need to sudo to install in `/usr/local` if
`$USER` is in `staff` *group*)

## Meta help

```bash
helper
```

Then cut-and-paste required lines

## Typical sequence for a new playbook repos

### environment

```bash
helper env
```

For PATH, GPG_AGENT_INFO, SSH_AUTH_SOCK, etc...

```bash
helper git_env
```

For GIT_PAGER, GIT_EDITOR, etc...

```bash
helper ansible_env
```

For ANSIBLE_STDOUT_CALLBACK

```bash
helper ansible/help GIT_CLONE_BASE=$SOMEDIR
```

For initial `ansible` clone, then

```bash
helper ansible
```

To invoke `ansible` env-setup for default version 

### Config

```bash
helper git
```

To choose `git` identity to use and some history lines

```bash
helper git-config
```

To config locally using a playbook


```bash
helper init-play-dir
```

To create a playbook dir skeleton using a playbook

## Migration tool

```bash
helper hg2git hg="" 2git=""
helper run hg2git hg="" 2git=""
```
To prepare a Mercurial to git migration using a playbook

## Github helper

`github-helper.mk` Provides:

	- github [epi|thy] list/[all|forked|mine]
	- github [epi|thy] create/[]
	- github [epi|thy] clone/$existing-repo

## Git index-filter wrapper

`git-index-filter.mk` Provides:

	- git-move-whole-tree-in-subdir
	- git-rename-top-subdir
	- git-merge-top-subdir
	
# Misc

[Grip]: https://github.com/joeyespo/grip "github"

## GitHub Readme Instant Preview

See [Grip][Grip]

```bash
grip -b
```

# Build ansible

[build-ansible.mk](build-ansible.mk) allow to build and install a ansible debian package

The First run on a worksation where all needed packages to build
ansible are already installed will also generate a list of packages
to install to successfully build ansible on a fresh debian install
with similar debian release.

e.g.

- [build-ansible-stable-2.3-jessie-8.8-deb-src.mk](build-ansible-stable-2.3-jessie-8.8-deb-src.mk)
- [build-ansible-stable-2.3-jessie-8.8-buildpackage.mk](build-ansible-stable-2.3-jessie-8.8-buildpackage.mk)

First, clone or pull an ansible version

```bash
use-ansible help
(cd ~/usr/ext; git clone --branch stable-2.3 --recursive git://github.com/ansible/ansible.git ansible-stable-2.3)
(cd ~/usr/ext/ansible-stable-2.3; git pull --rebase; git submodule update --init --recursive)
```

Then, instead of running fromt sources

```bash
source ~/usr/ext/ansible-stable-2.3/hacking/env-setup -q
```

Use `build-ansible.mk`

```bash
build-ansible.mk once
build-ansible.mk deb-src
build-ansible.mk buildpackage
build-ansible.mk install
```

Or

```
build-ansible.mk main
```

You can set `GIT_CLONE_BASE` and `GIT_ANSIBLE_VERSION`
