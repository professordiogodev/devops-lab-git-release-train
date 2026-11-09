#!/usr/bin/env bash
# Builds the Clippy team's Git world under $LAB_HOME (default: ~/git-lab). Safe to re-run: it starts over.
set -euo pipefail
LAB_HOME="${LAB_HOME:-$HOME/git-lab}"
rm -rf "$LAB_HOME"; mkdir -p "$LAB_HOME"; cd "$LAB_HOME"
git init -q --bare -b main origin.git

as() { local n="$1" e="$2"; shift 2; GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="$e" GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="$e" "$@"; }
seed=$(mktemp -d); cd "$seed"; git init -q -b main; git config commit.gpgsign false
cat > app.py <<'P'
"""Clippy (tiny teaching copy)."""
VERSION = open("VERSION").read().strip()

def healthz():
    return {"status": "ok", "version": VERSION}

def shorten(url):
    return "abc123"
P
echo "1.0.0" > VERSION
printf '# Clippy\n\nA URL shortener.\n' > README.md
git add -A; as "Maya Santos" maya@clippy.dev git commit -q -m "Initial Clippy service"
as "Maya Santos" maya@clippy.dev git tag -a v1.0.0 -m "First release"
git switch -q -c develop
printf 'def stats():\n    return {"links": 0}\n' > stats.py; git add -A
as "Priya Nair" priya@clippy.dev git commit -q -m "Add /stats endpoint"
printf '\n## Running\n\nuvicorn api.main:app\n' >> README.md; git add -A
as "Tomas Costa" tomas@clippy.dev git commit -q -m "Document how to run Clippy"
git remote add origin "$LAB_HOME/origin.git"; git push -q origin main develop --tags
cd "$LAB_HOME"; rm -rf "$seed"

git clone -q origin.git clippy; cd clippy
git switch -q develop; git switch -q main
git config user.name  "$(git config --global user.name  2>/dev/null || echo 'You')"
git config user.email "$(git config --global user.email 2>/dev/null || echo 'you@example.com')"
git config commit.gpgsign false
echo
echo "Ready. Your working copy is: $LAB_HOME/clippy   (origin is $LAB_HOME/origin.git)"
echo "Open README.md and start Part 1."
