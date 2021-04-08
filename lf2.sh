#!/bin/bash

declare -A import=() assert=() awk=() help=() comment=()
declare -a narg=()

put1 () { (($# > 1)) || fail "$@" put array var [val]; }
put2 () { local -n __=$1; echo "${__[$2]}"; }
put3 () { local -n __=$1; local e; [[ -v txt ]] || e="${IFS:0:1}"; [[ "$3" ]] && __[$2]+="${@:3:$#}$e" || unset __[$2]; }
put () { put1 "$@" && { (($# == 2)) && put2 $1 "${@:2:$#}"; } || { (($# > 2)) && put3 $1 $2 "${@:3:$#}"; }; }

txt () { txt= "$@"; }
cmnt='txt put comment'

$cmnt fail 'fail with an error message without exiting current shell'
fail() { unset -v fail; : "${fail:?$@}"; }

$cmnt check-tty 'fail if stdin is a tty'
check-tty () { [ -t 0 ] && fail "input shouldn't be a TTY"; }

f.narg() { narg[$1]+=" ${@:2:$#}"; }

awk.f () { echo "$1 () { awk '${awk[$1]}'; }"; }

at-least-one-arg () { (($# - 1 > 0)) || fail ${FUNCNAME[0]} "$@"; }
zero-arg () { (($# - 1 == 0)) || fail ${FUNCNAME[0]} "$@"; }

load () { source <($@); }
put assert at-least-one-arg load

####


$cmnt join 'convert lines of args to line of args '
$cmnt join 'by joining IFS separated words from input whith "$1" (default " ").'$'\n'
$cmnt join 'When "$1" is "\n" acts as "split($join)"'
join () { while read -r; do echo -n "${REPLY}"; echo -ne "${1:-${IFS:0:1}}"; done; }
args () { join; }
put import args join

$cmnt split 'converts args to lines of arg'
split () { for i in "$@"; do echo "$i"; done; }
put assert check-tty split

$cmnt list 'convert args or lines of args to line of args'
list () { (($#)) && split "$@"; [[ -t 0 ]] || join '\n'; }
put import list split join

####

map () { while read; do ${ECHO:+echo} "$@" "$REPLY"; done; }
put assert at-least-one-arg map

ssh-forget-ip () { (cd; ssh-keygen -f .ssh/known_hosts -R $1); }
ssh-learn-ip () { (cd; ssh-keyscan -H $1 | tee -a .ssh/known_hosts); }
an-ip-changed () { ssh-forget-ip $1; ssh-learn-ip $1; }

put import an-ip-changed ssh-forget-ip ssh-learn-ip
f.narg 1 an-ip-changed ssh-forget-ip ssh-learn-ip

func-name () { echo ${BASH_ALIASES[${1:?}]:-$1}; }
show-func-maybe-export () { func-name $1 | { read f; declare -f $f; (($t)) && echo export -f $f || true; }; }
show-func () { t=0 show-func-maybe-export $1; }
export-func () { t=1 show-func-maybe-export $1; }
run-func () { show-func $1; echo "$@"; }
with-funcs () { echo "$@" | list | map export-func; }
alias show=show-func shox=export-func run=run-func with=with-funcs

put awk func-on-a-line.awk 'f && /^ +};?/ { print $0 ";"; next }'
put awk func-on-a-line.awk 'f { --f; print $0 ";"; next } NR == 1 || /^ +};?/ { print; ++f; next } 1'
load awk.f func-on-a-line.awk
func-on-a-line.sed () { sed -r -e 's/^ +//' -e 's/ +$//'; }
func-on-a-line () { show-func $1 | tac | func-on-a-line.awk | func-on-a-line.sed | tac | args; echo; }
alias short=func-on-a-line

list-all-func () { declare -F | awk '{ print $NF }'; }
show-all-func () { list-all-func | map show-func; }
put import show-all-func map show-func

show-all-func-on-a-line () { list-all-func | map func-on-a-line; }

closure () { { for i in "$@"; do echo $i; closure ${import[$i]}; done; } | sort -u; }
use () { closure "$@" | map show-func; }
put import use closure map show-func

run () { use $1; echo "$@"; }
f.narg 1 run
put import run use

rem () { run "${@:2:$#}" | ssh $1 bash; }
put import rem run

narg () { show-func $2 | { mapfile; echo "${MAPFILE[@]:0:2}"; echo ': ${'$1':?};'; echo "${MAPFILE[@]:2}"; }; }
f.narg 2 narg
nargs () { for i in ${!narg[@]}; do echo ${narg[$i]} | list | map narg $i; done; }
put assert zero-arg nargs

load nargs

assert () { show-func $2 | { mapfile; echo "${MAPFILE[@]:0:2}"; echo $1 $2 '"$@"'; echo "${MAPFILE[@]:2}"; }; }
asserts () { for i in ${!assert[@]}; do echo ${assert[$i]} | list | map assert $i; done; }
put assert zero-arg asserts

load asserts

################

apt-alien () { aptitude search '~i(!~ODebian)'; }
put help apt-alien show installed package not from Debian
apt-held () { aptitude search "~ahold"; }
put help apt-held package on hold

################

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

(($#)) && { "$@"; exit $?; }

# show-all-func
show-all-func-on-a-line
declare -p import narg assert awk help comment
alias