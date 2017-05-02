# Customizing git log

- [The shortest possible output from git log containing author and date][1]
- [Custom log format omits newline at end of output][2]

[1]: http://stackoverflow.com/questions/1441010/the-shortest-possible-output-from-git-log-containing-author-and-date "stackoverflow"
[2]: http://stackoverflow.com/questions/9007181/custom-log-format-omits-newline-at-end-of-output "stackoverflow"

# Using multiple id

Used to go thru ssh alias

```txt
Host thydel.gist.github.com
	IdentityFile ~/.ssh/id_thydel
```

But here is a more self-contained alternative

```bash
git config --local core.sshCommand 'ssh -F /etc/ssh/ssh_config -i ~/.ssh/id_thydel'
```
