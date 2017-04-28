# Usage

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

### config

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

### migration tool

```bash
helper hg2git hg="" 2git=""
```

To prepare a Mercurial to git migration using a playbook
