# To server as actions templates

## Migrate `nsf-pair`

- Edit [github-helper.mk](https://github.com/thydel/helpers/commit/a5018f17318f07960d2c020379f6a6aea2d3a19c)

```bash
./helper.mk install
```

- Create and clone

```bash
cd ~/usr/thydel.d;
github create/ar-nfs-pair;
github clone/ar-nfs-pair;
```

- Migrate from mercurial

```bash
helper     hg2git hg=$(pwd)/nfs-pair 2git=$thydel/ar-nfs-pair
helper run hg2git hg=$(pwd)/nfs-pair 2git=$thydel/ar-nfs-pair
hg --cwd nfs-pair push git;
(
	cd $thydel/ar-nfs-pair;
	git pull;
	git mv .hgignore .gitignore;
	# edit$thydel/ar-nfs-pair/.gitignore
	git add .;
	git commit -m 'Imports from mercurial';
	git push;
)
```
