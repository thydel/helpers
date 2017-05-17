# To serve as action templates

## Migrate local mercurial `nsf-pair` to github `ar-nfs-pair`

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

## Migrate a local mercurial repo to local git repo

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

## Merge selected files from local migrated repo into reorganized git repo

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

## Synchronize git repo set on primary and secondary workstation

### Make a new tool

[mk-thydel.mk](mk-thydel.mk) include [mk-git-list.mk](mk-git-list.mk)
to generate [thydel.mk](thydel.mk)
  
### On primary workstation

```bash
mk-thydel.mk clean main
git add thydel.mk; git commit; git push
```

### On secondary workstation

```bash
git pull
mk-thydel.mk clean main
make -C ~/usr/thydel.d -f helpers/thydel.mk thydel
```

### Swap primary and secondary and synchronize again
