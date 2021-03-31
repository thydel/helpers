#!/bin/bash

fail() { unset fail; : "${fail:?$@}"; }
check-tty () { [ -t 0 ] && fail "input shouldn't be a TTY"; }

github-file-content () { xargs -ri gh api repos/:owner/:repo/contents/{}${1+?ref=$1}; }
github-url-to-markdown () { jq -r '"\n    " as $s | "[\(.path)]:\($s)\(._links.html)\($s)\"github.com file\""'; }
github-file-to-markdown () { check-tty; github-file-content "$@" | github-url-to-markdown; }
alias ghf2url=github-file-to-markdown

git-repo () { git config --get remote.origin.url | cut -d: -f2 | cut -d. -f-1; }
git-branch-or-tag () { if [ "$1" ]; then git tag | grep $1 || fail no $1 tag; else git branch --show-current; fi; }
git-file-to-url() { xargs -ri echo https://github.com/$(git-repo)/blob/$(git-branch-or-tag "$@")/{}; }
git-url-to-markdown () { jq -Rr '"\n    " as $s | split("/")[-1] as $p | "[\($p)]:\($s)\(.)\($s)\"github.com file\""'; }
git-file-to-markdown () { check-tty; git-file-to-url "$@" | git-url-to-markdown; }
alias gf2url=git-file-to-markdown

declare -f
declare -F | awk '{ print $NF }' | xargs echo export -f
alias
