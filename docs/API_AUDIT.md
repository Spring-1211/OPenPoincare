# API audit

## Lean/mathlib version choice

This repository defaults to:

```text
leanprover/lean4:v4.31.0-rc2
mathlib v4.31.0-rc2
```

Reason: the supplied design document targets the upstream declaration name:

```lean
SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three
```

Current mathlib `master` uses that name. In mathlib `v4.30.0`, the corresponding declaration was still named:

```lean
SimplyConnectedSpace.nonempty_diffeomorph_sphere_three
```

## Audit commands

```bash
lake env lean Poincare/Foundation/MathlibTarget.lean
lake env lean examples/CheckTarget.lean
```

## Things to re-check on every mathlib bump

- exact final theorem name;
- `ChartedSpace (EuclideanSpace ℝ (Fin 3)) M` notation;
- `IsManifold (𝓘(ℝ, R3)) ∞ M` elaboration;
- sphere model for `S3`;
- `SimplyConnectedSpace` implication to `ConnectedSpace`;
- availability of fundamental group, van Kampen and connected-sum APIs.
