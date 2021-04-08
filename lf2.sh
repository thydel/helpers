#!/bin/bash

declare -A import assert awk help
declare -a narg

fail() { unset -v fail; : "${fail:?$@}"; }

put1 () { (($# > 1)) || fail "$@" put array var [val]; }
put2 () { local -n __=$1; echo ${__[$2]}; }
put3 () { local -n __=$1; [[ "$3" ]] && __[$2]+="${@:3:$#} " || unset __[$2]; }
put () { put1 "$@" && { (($# == 2)) && put2 $1 "${@:2:$#}"; } || { (($# > 2)) && put3 $1 $2 "${@:3:$#}"; }; }

f.narg() { narg[$1]+=" ${@:2:$#}"; }

awk.f () { echo "$1 () { awk '${awk[$1]}'; }"; }

at-least-one-arg () { (($# - 1 > 0)) || fail ${FUNCNAME[0]} "$@"; }
zero-arg () { (($# - 1 == 0)) || fail ${FUNCNAME[0]} "$@"; }

load () { source <($@); }
put assert at-least-one-arg load

lista () { for i in "$@"; do echo "$i"; done; }
listi () { while read; do for i in $REPLY; do echo "$i"; done; done; }
list () { (($#)) && lista "$@" || listi; }
put import list lista listi

args () { while read; do echo -n "$REPLY "; done; }

map () { while read; do ${ECHO:+echo} "$@" "$REPLY"; done; }
put assert at-least-one-arg map

ssh-forget-ip () { (cd; ssh-keygen -f .ssh/known_hosts -R $1); }
ssh-learn-ip () { (cd; ssh-keyscan -H $1 | tee -a .ssh/known_hosts); }
an-ip-changed () { ssh-forget-ip $1; ssh-learn-ip $1; }

put import an-ip-changed ssh-forget-ip ssh-learn-ip
f.narg 1 an-ip-changed ssh-forget-ip ssh-learn-ip

show () { declare -f $1; }
f.narg 1 run

put awk func-on-a-line.awk 'f && /^ +};?/ { print $0 ";"; next }'
put awk func-on-a-line.awk 'f { --f; print $0 ";"; next } NR == 1 || /^ +};?/ { print; ++f; next } 1'
load awk.f func-on-a-line.awk
func-on-a-line.sed () { sed -r -e 's/^ +//' -e 's/ +$//'; }
func-on-a-line () { show $1 | tac | func-on-a-line.awk | func-on-a-line.sed | tac | args; echo; }
alias short=func-on-a-line

list-all-func () { declare -F | awk '{ print $NF }'; }
show-all-func () { list-all-func | map show; }
put import show-all-func map show

show-all-func-on-a-line () { list-all-func | map func-on-a-line; }

closure () { { for i in "$@"; do echo $i; closure ${import[$i]}; done; } | sort -u; }
use () { closure "$@" | map show; }
put import use closure map show

run () { use $1; echo "$@"; }
f.narg 1 run
put import run use

rem () { run "${@:2:$#}" | ssh $1 bash; }
put import rem run

narg () { show $2 | { mapfile; echo "${MAPFILE[@]:0:2}"; echo ': ${'$1':?};'; echo "${MAPFILE[@]:2}"; }; }
f.narg 2 narg
nargs () { for i in ${!narg[@]}; do echo ${narg[$i]} | list | map narg $i; done; }
put assert zero-arg nargs

load nargs

assert () { show $2 | { mapfile; echo "${MAPFILE[@]:0:2}"; echo $1 $2 '"$@"'; echo "${MAPFILE[@]:2}"; }; }
asserts () { for i in ${!assert[@]}; do echo ${assert[$i]} | list | map assert $i; done; }
put assert zero-arg asserts

load asserts

apt-alien () { aptitude search '~i(!~ODebian)'; }
put help apt-alien show installed package not from Debian
apt-held () { aptitude search "~ahold"; }
put help apt-held package on hold

(($#)) && { "$@"; exit $?; }

# show-all-func
show-all-func-on-a-line
declare -p import narg assert awk help
alias
