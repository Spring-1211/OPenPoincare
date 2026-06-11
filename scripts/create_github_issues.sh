#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
This helper intentionally does not auto-create issues yet.

Recommended workflow:
1. Review docs/FIRST_30_ISSUES.md.
2. Edit titles/owners for your organization.
3. Use GitHub CLI manually, for example:

   gh issue create --title "Verify exact mathlib Poincaré target" \
     --body-file docs/FIRST_30_ISSUES.md \
     --label "infrastructure,lean,target-audit"

A future version can parse the table and create one issue per row after owner labels are finalized.
MSG
