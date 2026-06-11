# Project status

## Status summary

This repository is a **formalization blueprint and Lean skeleton**. It is designed so a team can upload it to GitHub, open the first issues, and begin formalization without first re-designing the project architecture.

It intentionally contains `sorry` in major interface theorems. These are not hidden assumptions; they are tracked technical debt.

## Version pin

- Lean toolchain: `leanprover/lean4:v4.31.0-rc2`
- mathlib dependency: `leanprover-community/mathlib`, version `v4.31.0-rc2`
- Reason: current mathlib `master` tracks the theorem name `SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three`.

## Build expectations

Expected first-time local workflow:

```bash
lake update
lake exe cache get
lake build
```

The repository does not include `.lake/` or generated build artifacts. After the first successful `lake update`, commit the generated `lake-manifest.json` if your team wants fully pinned dependency hashes.

## Pending theorem policy

Allowed temporarily:

- `sorry` in explicitly named interface theorems;
- abstract predicates for Morgan--Tian connected-sum classification, spherical space forms, `S²`-bundles, surgery topology and finite extinction.

Disallowed:

- `axiom` for mathematical shortcuts;
- untracked `unsafe` declarations;
- theorem names copied from an LLM without `#check` or source locator;
- Ricci/surgery/extinction nodes whose proof sketch says only “standard argument”.

## Immediate next steps

1. Run `lake update && lake exe cache get && lake build`.
2. Commit the generated `lake-manifest.json`.
3. Open the 30 seed issues in `docs/FIRST_30_ISSUES.md`.
4. Assign at least one Lean reviewer and one mathematics reviewer for every interface theorem.
5. Run `python3 scripts/check_pending.py` weekly and paste the report into project discussions.
