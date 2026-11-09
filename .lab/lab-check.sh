#!/usr/bin/env bash
rc=0
grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md && echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED" || { echo "- ❌ paste the verify.sh output ('ALL CHECKS PASSED') into SUBMISSION.md"; rc=1; }
grep -qE '(\*|\|)\s+[0-9a-f]{7}' SUBMISSION.md && echo "- ✅ SUBMISSION.md includes a git graph" || { echo "- ❌ paste your 'git log --oneline --graph --all' into SUBMISSION.md"; rc=1; }
exit $rc
