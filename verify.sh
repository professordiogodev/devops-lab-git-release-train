#!/usr/bin/env bash
# Checks the shared origin. Run with: ./verify.sh
set -uo pipefail
LAB_HOME="${LAB_HOME:-$HOME/git-lab}"
O="$LAB_HOME/origin.git"
[ -d "$O" ] || { echo "Run ./setup.sh first"; exit 1; }
g() { git --git-dir="$O" "$@"; }
pass=0; failn=0
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
ver() { g show "$1:VERSION" 2>/dev/null | tr -d '[:space:]'; }

echo "== Your feature =="
check "a feature branch commit by you is in develop (not Priya, Tomas, Maya)" bash -c "g() { git --git-dir='$O' \"\$@\"; }; g log develop --format=%an | grep -vE 'Priya Nair|Tomas Costa|Maya Santos' | grep -q ."
check "your feature was merged with a merge commit (--no-ff)"  bash -c "git --git-dir='$O' log develop --merges --format=%s | grep -qi 'feature'"
check "Priya's 'Add rate limiting' is still in develop (nobody lost work)" bash -c "git --git-dir='$O' log develop --format=%s | grep -q 'Add rate limiting'"

echo "== Release 1.1.0 =="
check "tag v1.1.0 exists and is annotated"                      bash -c "[ \"\$(git --git-dir='$O' cat-file -t v1.1.0 2>/dev/null)\" = tag ]"
check "v1.1.0 contains your feature and Priya's rate limiting"  bash -c "git --git-dir='$O' log v1.1.0 --format=%s | grep -q 'Add rate limiting' && git --git-dir='$O' log v1.1.0 --format=%an | grep -vE 'Priya Nair|Tomas Costa|Maya Santos' | grep -q ."
check "VERSION is 1.1.0 at the tag"                            test "$(ver v1.1.0)" = 1.1.0
check "main points at a release (merge commit from the release branch)" bash -c "git --git-dir='$O' log main --merges --format=%s | grep -qi 'release'"

echo "== Hotfix 1.1.1 =="
check "tag v1.1.1 exists and is annotated"                      bash -c "[ \"\$(git --git-dir='$O' cat-file -t v1.1.1 2>/dev/null)\" = tag ]"
check "v1.1.1 is built on v1.1.0 (hotfix from main)"            bash -c "git --git-dir='$O' merge-base --is-ancestor v1.1.0 v1.1.1"
check "VERSION is 1.1.1 at the tag"                            test "$(ver v1.1.1)" = 1.1.1
check "the hotfix did NOT ship Tomas's unfinished premium plans" bash -c "! git --git-dir='$O' show v1.1.1:app.py | grep -q PREMIUM_ENABLED"
check "the hotfix touched app.py (the bug fix itself)"          bash -c "git --git-dir='$O' diff v1.1.0 v1.1.1 --stat | grep -q app.py"
check "main is at v1.1.1"                                       bash -c "[ \"\$(git --git-dir='$O' rev-parse main)\" = \"\$(git --git-dir='$O' rev-parse 'v1.1.1^{commit}')\" ] || git --git-dir='$O' merge-base --is-ancestor v1.1.1 main"

echo "== The step everybody forgets =="
check "the hotfix is also in develop (git log develop..main --no-merges is empty)" bash -c "[ -z \"\$(git --git-dir='$O' log develop..main --no-merges --oneline)\" ]"
check "Tomas's WIP is still in develop (you did not drop it)"   bash -c "git --git-dir='$O' log develop --format=%s | grep -q 'WIP: premium'"

echo
if [ "$failn" -eq 0 ]; then echo "ALL CHECKS PASSED ($pass/$pass)"; else echo "$failn check(s) failed, $pass passed"; fi
exit "$failn"
