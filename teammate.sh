#!/usr/bin/env bash
# Simulates teammates working on the shared origin while you work.
#   ./teammate.sh feature   Priya merges a finished feature into develop
#   ./teammate.sh bug       a bug is reported in production (prints the report)
set -euo pipefail
LAB_HOME="${LAB_HOME:-$HOME/git-lab}"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
git clone -q "$LAB_HOME/origin.git" "$t/w"; cd "$t/w"; git config commit.gpgsign false
as() { local n="$1" e="$2"; shift 2; GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="$e" GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="$e" "$@"; }
case "${1:-}" in
  feature)
    git switch -q develop
    printf '\ndef rate_limit(ip):\n    return True\n' >> app.py
    git add -A; as "Priya Nair" priya@clippy.dev git commit -q -m "Add rate limiting"
    git push -q origin develop
    echo "Priya just merged 'Add rate limiting' into develop." ;;
  bug)
    git switch -q develop
    printf '\n# WIP: experimental premium plans, NOT ready\nPREMIUM_ENABLED = True\n' >> app.py
    git add -A; as "Tomas Costa" tomas@clippy.dev git commit -q -m "WIP: premium plans experiment"
    git push -q origin develop
    cat <<'B'
INCIDENT 07:12 - /healthz in production reports the wrong status.
It always says "ok", even when the app cannot reach its storage.
Customers are not affected yet, but monitoring is blind.
Fix it on the released version (main). Do not ship unfinished work from develop.
B
    ;;
  *) echo "usage: ./teammate.sh feature|bug"; exit 1 ;;
esac
