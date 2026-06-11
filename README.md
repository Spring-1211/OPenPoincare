# Poincaré Lean 4 Formalization Blueprint

> A proof-engineering blueprint and Lean 4 skeleton for a long-term formalization of the three-dimensional smooth Poincaré conjecture via the Morgan--Tian organization of Perelman's proof.

本仓库不是宣称“庞加莱猜想已经在 Lean 中完成形式化”，而是一个可审查、可扩展、可分工、可持续迭代的 **Lean formalization blueprint project**。它把目标拆成：最终 mathlib theorem target、Morgan--Tian 大定理 interface、拓扑 endgame、Ricci flow、Perelman reduced geometry、surgery、finite-time extinction 和项目治理基础设施。

## Current target

The current project target is the mathlib-style smooth three-dimensional Poincaré statement:

```lean
theorem Poincare.poincare_three_smooth_project
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace Poincare.R3 M]
    [IsManifold (𝓘(ℝ, Poincare.R3)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M] :
    Nonempty (M ≃ₘ⟮3, 3⟯ Poincare.S3)
```

The upstream mathlib declaration being tracked is:

```lean
#check SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three
```

This project pins Lean/mathlib to `v4.31.0-rc2` because that name matches current mathlib `master` and the supplied design document. If you move to the latest stable release, audit `docs/API_AUDIT.md` first: mathlib `v4.30.0` used the nearby name `SimplyConnectedSpace.nonempty_diffeomorph_sphere_three`.

## What is included

- A Lake/mathlib Lean project with a module hierarchy under `Poincare/`.
- A `leanblueprint` LaTeX blueprint skeleton under `blueprint/`.
- A top-level proof-engineering DAG organized around Morgan--Tian Theorems 0.1, 0.3, 0.4 and the simply connected endgame.
- Foundation, topology, Ricci flow, Perelman, surgery and extinction interface modules.
- CI workflows for Lean, pending-theorem audit and blueprint build.
- Project governance documents: source map, risk register, first 30 issues, contributor guide and audit checklist.

## Repository layout

```text
.
├── Poincare.lean
├── Poincare/
│   ├── Main.lean
│   ├── Foundation/
│   ├── Topology/
│   ├── MorganTian/
│   ├── Riemannian/
│   ├── RicciFlow/
│   ├── Perelman/
│   ├── Surgery/
│   └── Extinction/
├── blueprint/
│   └── src/
├── docs/
├── examples/
├── scripts/
└── .github/
```

## Quick start

Install Lean through `elan`, then run:

```bash
git clone <your-repo-url>
cd poincare-lean-blueprint
lake update
lake exe cache get
lake build
python3 scripts/check_pending.py
```

For the blueprint:

```bash
python3 -m pip install leanblueprint
leanblueprint web
leanblueprint pdf
```

## Development policy

The `main` branch is allowed to contain explicit `sorry` only for tracked interface theorems. The long-term no-sorry branch should gradually remove these interfaces. New interface theorems must include:

1. mathematical source locator,
2. blueprint label,
3. purpose,
4. owner/reviewer expertise,
5. replacement plan,
6. risk classification.

Do **not** add `axiom` or `unsafe` as a shortcut for mathematical content.

## Milestones

| Period | Goal |
|---:|---|
| 0--12 months | Compiling Lean skeleton, blueprint DAG, exact target audit, Morgan--Tian interface, topology endgame under explicit assumptions. |
| 1--3 years | 3-manifold topology infrastructure: connected sum expression API, fundamental group of connected sums, spherical space-form and `S²`-bundle interfaces. |
| 3--6 years | Riemannian/Ricci/Perelman definitions and core theorem statements with reviewed source locators. |
| 6--10 years | Replace surgery and finite-extinction interfaces with progressively formalized proofs. |

## Status

This is a professional project skeleton with many deliberate pending theorem interfaces. See `PROJECT_STATUS.md` and `docs/FIRST_30_ISSUES.md` before starting implementation work.
