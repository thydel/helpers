#!/bin/bash

declare -A import
declare -a narg
declare -A assert
declare -A awk

f.import () { import[$1]="${@:2:$#}"; }
f.narg() { narg[$1]+=" ${@:2:$#}"; }
f.assert() { assert[$1]+="${@:2:$#} "; }

f.awk () { awk[$1]+="${@:2:$#} "; }
awk.f () { echo "$1 () { awk '${awk[$1]}'; }"; }

fail() { unset -v fail; : "${fail:?$@}"; }
at-least-one-arg () { (($# - 1 > 0)) || fail ${FUNCNAME[0]} "$@"; }
zero-arg () { (($# - 1 == 0)) || fail ${FUNCNAME[0]} "$@"; }

load () { source <($@); }
f.assert at-least-one-arg load

lista () { for i in "$@"; do echo "$i"; done; }
listi () { while read; do for i in $REPLY; do echo "$i"; done; done; }
list () { (($#)) && lista "$@" || listi; }
f.import list lista listi

args () { while read; do echo -n "$REPLY "; done; }

map () { while read; do ${ECHO:+echo} "$@" "$REPLY"; done; }
f.assert at-least-one-arg map

ssh-forget-ip () { (cd; ssh-keygen -f .ssh/known_hosts -R $1); }
ssh-learn-ip () { (cd; ssh-keyscan -H $1 | tee -a .ssh/known_hosts); }
an-ip-changed () { ssh-forget-ip $1; ssh-learn-ip $1; }

f.import an-ip-changed ssh-forget-ip ssh-learn-ip
f.narg 1 an-ip-changed ssh-forget-ip ssh-learn-ip

show () { declare -f $1; }
f.narg 1 run

f.awk func-on-a-line.awk 'f && /^ +};?$/ { print $0 ";"; next }'
f.awk func-on-a-line.awk 'f { --f; print $0 ";"; next } NR == 1 || /^ +};?$/ { print; ++f; next } 1'
load awk.f func-on-a-line.awk
func-on-a-line.sed () { sed -r -e 's/^ +//' -e 's/ +$//'; }
func-on-a-line () { show $1 | tac | func-on-a-line.awk | func-on-a-line.sed | tac | args; echo; }

list-all-func () { declare -F | awk '{ print $NF }'; }
show-all-func () { list-all-func | map show; }
f.import show-all-func map show

show-all-func-on-a-line () { list-all-func | map func-on-a-line; }

closure () { { for i in "$@"; do echo $i; closure ${import[$i]}; done; } | sort -u; }
use () { closure "$@" | map show; }
f.import use closure map show

run () { use $1; echo "$@"; }
f.narg 1 run

narg () { show $2 | { mapfile; echo "${MAPFILE[@]:0:2}"; echo ': ${'$1':?};'; echo "${MAPFILE[@]:2}"; }; }
f.narg 2 narg
nargs () { for i in ${!narg[@]}; do echo ${narg[$i]} | list | map narg $i; done; }
f.assert zero-arg nargs

load nargs

assert () { show $2 | { mapfile; echo "${MAPFILE[@]:0:2}"; echo $1 $2 '"$@"'; echo "${MAPFILE[@]:2}"; }; }
asserts () { for i in ${!assert[@]}; do echo ${assert[$i]} | list | map assert $i; done; }
f.assert zero-arg asserts

load asserts

(($#)) && { "$@"; exit $?; }

# show-all-func
show-all-func-on-a-line
declare -p import
declare -p narg
declare -p assert
declare -p awk
