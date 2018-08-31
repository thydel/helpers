<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [To serve as action templates](#to-serve-as-action-templates)
- [New trim-dupli repos](#new-trim-dupli-repos)
- [Migrate local mercurial `nsf-pair` to github `ar-nfs-pair`](#migrate-local-mercurial-nsf-pair-to-github-ar-nfs-pair)
- [Migrate a local mercurial repo to local git repo](#migrate-a-local-mercurial-repo-to-local-git-repo)
- [Merge selected files from local migrated repo into reorganized git repo](#merge-selected-files-from-local-migrated-repo-into-reorganized-git-repo)
- [Synchronize git repo set on primary and secondary workstation](#synchronize-git-repo-set-on-primary-and-secondary-workstation)
    - [Make a new tool](#make-a-new-tool)
    - [Which require a recent git version](#which-require-a-recent-git-version)
    - [On primary workstation](#on-primary-workstation)
    - [On secondary workstation](#on-secondary-workstation)
    - [Swap primary and secondary and synchronize again](#swap-primary-and-secondary-and-synchronize-again)
- [Add private-misc-notes](#add-private-misc-notes)

<!-- markdown-toc end -->

# To serve as action templates

# New trim-dupli repos

- Edit [github-helper.mk](https://github.com/thydel/helpers/commit/bc0294c691ea5aba195eefd6994f00b73fc016c1)

```bash
./helper.mk install
proot -w ~/usr/thydel.d github create/trim-dupli
proot -w ~/usr/thydel.d github clone/trim-dupli
mk-thydel.mk clean main
```

# Migrate local mercurial `nsf-pair` to github `ar-nfs-pair`

- Edit [github-helper.mk](https://github.com/thydel/helpers/commit/a5018f17318f07960d2c020379f6a6aea2d3a19c)

```bash
./helper.mk install
```

- Create and clone a new github repo

```bash
cd ~/usr/thydel.d;
github create/ar-nfs-pair;
github clone/ar-nfs-pair;
```

- Migrate from mercurial to git

```bash
helper     hg2git hg=$(pwd)/nfs-pair 2git=$thydel/ar-nfs-pair
helper run hg2git hg=$(pwd)/nfs-pair 2git=$thydel/ar-nfs-pair
hg --cwd nfs-pair push git;
(
	cd $thydel/ar-nfs-pair;
	git pull;
	git mv .hgignore .gitignore;
	# edit .gitignore
	git add .;
	git commit -m 'Imports from mercurial';
	git push;
)
```

# Migrate a local mercurial repo to local git repo

- Prepare a local git repo

```bash
name=hgrepo;
git init --bare $name-git.git;
git clone $name-git.git;
```
- Migrate from mercurial to git

```bash
helper     hg2git hg=$(pwd)/$name 2git=$(pwd)/$name-git;
helper run hg2git hg=$(pwd)/$name 2git=$(pwd)/$name-git;
hg --cwd $name push git;
```

# Merge selected files from local migrated repo into reorganized git repo

- Get new repo

```bash
name=hgrepo;
git -C $name-git pull;
```

- Prefix all commit messages

```bash
export prefix=$name;
git -C $name-git filter-branch --msg-filter 'echo -n "$prefix " && cat'
```

- With possible corrections

```bash
git -C $name-git filter-branch --msg-filter -f 'sed "s/$from/$to/"'
```

- When everything OK, remove backup ref

```bash
git -C $name-git update-ref -d refs/original/refs/heads/master

```

- Choose file to merge

```bash
export src=hgrepo;
export dst=gitrepo;
export file=afile;
git -C $src-git format-patch --stdout --root $file | git -C $dst am
```

- Alternative, merge all in subdir

```bash
export src=hgrepo;
export dst=gitrepo;
export file=adir;
git -C $src-git format-patch --stdout --root | git -C $dst am --directory $adir
```

# Synchronize git repo set on primary and secondary workstation

## Make a new tool

[mk-thydel.mk](mk-thydel.mk) include [mk-git-list.mk](mk-git-list.mk)
to generate [thydel.mk](thydel.mk)
  
## Which require a recent git version

```bash
aptitude -t jessie-backports install git
```

## On primary workstation

```bash
mk-thydel.mk clean main
git add thydel.mk; git commit; git push
```

## On secondary workstation

```bash
git pull
mk-thydel.mk clean main
make -C ~/usr/thydel.d -f helpers/thydel.mk thydel
```

## Swap primary and secondary and synchronize again

# Add private-misc-notes

Use [helpers][]
and edit [github-helper.mk][]
to [Add private-misc-notes misc-notes][]

Note:

> `misc-notes` was already created but not declared in
> `github-helper.mk`.  Adding it allows to use `make thydel` on a new
> node to create all declared repos

[helpers]:
	https://github.com/thydel/helpers "github.com repos"

[github-helper.mk]:
	https://github.com/thydel/helpers/blob/master/github-helper.mk "github.com file"

[Add private-misc-notes misc-notes]:
	https://github.com/thydel/helpers/commit/27bde59c2be6f7dd9c5ea3d4beca2271233ab50f "github.com commit"

```
./helper.mk install
github thy create/private-misc-notes
proot -w ~/usr/thydel.d github thy clone/private-misc-notes
mk-thydel.mk clean main # Generate thyde.mk from cloned ones
make -C ~/usr/thydel.d thydel
```

Use [github.com settings][] to declare [private-misc-notes][] private

TODO:

> Use github API to make a private repos

[github.com settings]:
	https://github.com/thydel/private-misc-notes/settings "github.com ops"

[private-misc-notes]:
	https://github.com/thydel/private-misc-notes "github.com repos"
