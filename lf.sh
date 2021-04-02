#!/bin/bash

fail() { unset fail; : "${fail:?$@}"; }
check-tty () { [ -t 0 ] && fail "input shouldn't be a TTY"; }

jq-md-url () { jq --argjson s '"\n    "' -r "$1"; }

github-files () { gh api /repos/:owner/:repo/git/trees/$(git branch --show-current)?recursive=1 | jq -r '.tree|map(.path)[]'; }

github-file-content () { xargs -ri gh api repos/:owner/:repo/contents/{}${1+?ref=$1}; }
github-url-to-markdown () { jq-md-url '"[\(.path)]:\($s)\(._links.html)\($s)\"github.com file\"\n"'; }
github-file-to-markdown () { check-tty; github-file-content "$@" | github-url-to-markdown; }
alias ghf2md=github-file-to-markdown

git-url () { git config --get remote.origin.url; }
git-repo () { git-url | cut -d: -f2 | cut -d. -f-1; }
git-repo () { git-url | jq -Rr 'split(":")[1]|split(".")[:-1][]'; }
git-site () { git-url | jq -Rr 'split(":")[0]|split("@")[1]'; }
git-branch-or-tag () { if [ "$1" ]; then git tag | grep $1 || fail no $1 tag; else git branch --show-current; fi; }
git-file-to-url() { xargs -ri echo https://$(git-site)/$(git-repo)/blob/$(git-branch-or-tag "$@")/{}; }
git-url-to-markdown () { jq -R | jq-md-url 'split("/")[-1] as $p | "[\($p)]:\($s)\(.)\($s)\"github.com file\"\n"'; }
git-file-to-markdown () { check-tty; git-file-to-url "$@" | git-url-to-markdown; }
alias gf2md=git-file-to-markdown

github-repo-to-js () { gh api repos/:owner/:repo | jq '{ name, user: .owner.login, url: .html_url, type: (if .private then "private" else "public" end) }'; }
git-commit-to-js () { git log -${1:-1} --pretty='{ "comment": "%s", "commit": "%H" }'; }
github-repo-and-commit-to-js () { (github-repo-to-js; git-commit-to-js "$@") | jq -n 'input as $r | [inputs] | map([$r, .] | add)[]'; }

github-repo-to-md () { github-repo-to-js | jq-md-url '"[\(.name)]:\($s)\(.url)\($s)\"github.com \(.type) repo\""'; }
alias ghr2md=github-repo-to-md

github-commit-to-md () { github-repo-and-commit-to-js "$@" | jq-md-url '"[\(.comment)]:\($s)\(.url)/commit/\(.commit)\($s)\"github.com commit\"\n"'; }
alias ghc2md=github-commit-to-md

relative-file-to-js () { jq -R '{ url: ., name: split(".")[0] | split("_")[2] }'; }
relative-file-to-md () { check-tty; relative-file-to-js | jq-md-url '"[\(.name)]:\($s)\(.url)\($s)\"github.com relative file\"\n"'; }
alias ghrf2md=relative-file-to-md

list () { fmt -1; }
args () { tr '\n' ' '; }
apply () { : ${1:?}; read; ${ECHO:+echo} "$@" $REPLY; }
map () { : ${1:?}; while read; do "$@" ${ECHO:+echo} $REPLY; done; }

func-name () { echo ${BASH_ALIASES[${1:?}]:-$1}; }
show-func-maybe-export () { func-name $1 | { read f; declare -f $f; (($t)) && echo export -f $f || true; }; }
show-func () { t=0 show-func-maybe-export $1; }
export-func () { t=1 show-func-maybe-export $1; }
run-func () { show-func $1; echo "$@"; }
with-funcs () { echo "$@" | list | map export-func; }
alias show=show-func shox=export-func run=run-func with=with-funcs

ssh-forget-ip () { (cd; ssh-keygen -f .ssh/known_hosts -R ${1:?}); }
ssh-learn-ip () { (cd; ssh-keyscan -H ${1:?} | tee -a .ssh/known_hosts); }
an-ip-changed () { ssh-forget-ip $1; ssh-learn-ip $1; }

func-on-a-line.awk () { awk 'NR == 1 { ++f; print; next } /; *$/ || /^{/ { --f } f == 1 { print $0 ";"; next } 1'; }
func-on-a-line.sed () { sed -r -e 's/^ +//' -e 's/ +$//'; }
func-on-a-line () { show-func $1 | tac | func-on-a-line.awk | func-on-a-line.sed | tac | args; echo; }
alias short=func-on-a-line
list-all-func () { declare -F | awk '{ print $NF }'; }

show-all-func () { list-all-func | map show-func; }
show-all-func-on-a-line () { list-all-func | map func-on-a-line; }
export-all-func () { list-all-func | args | apply echo export -f; }

(($#)) && { "$@"; exit $?; }

show-all-func-on-a-line
export-all-func
alias
