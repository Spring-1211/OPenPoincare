# First 30 GitHub issues

Use this as the initial GitHub project backlog. Each issue should link to the relevant Lean file and blueprint node.

| # | Title | Purpose | Files | Source | Acceptance criteria | Difficulty | Owner |
|---:|---|---|---|---|---|---:|---|
| 1 | Verify exact mathlib Poincaré target | Fix final theorem target | `Poincare/Foundation/MathlibTarget.lean` | mathlib `PoincareConjecture` | `#check` output recorded | 1 | Lean |
| 2 | Set up Lake project and CI | project builds | root, `.github/workflows/lean.yml` | Lake docs | `lake build` passes | 1 | infra |
| 3 | Initialize leanblueprint | web/pdf/DAG | `blueprint/` | leanblueprint | `leanblueprint web` passes | 2 | infra |
| 4 | Create MT introduction source map | locate Theorems 0.1--0.5 | `docs/SOURCE_MAP.md` | MT intro | reviewed table | 2 | geometry |
| 5 | Define pending theorem policy | prevent uncontrolled black boxes | `Foundation/Pending.lean` | project policy | script reports pending | 2 | Lean |
| 6 | Bundled closed smooth 3-manifold | reduce typeclass noise | `Foundation/ClosedSmooth3Manifold.lean` | mathlib manifold | compiles | 2 | Lean |
| 7 | Sphere `S³` notation audit | align final target | `Foundation/Dimension3.lean` | mathlib sphere | `#check` examples | 1 | Lean |
| 8 | Define MT classification interface | top-level bridge | `MorganTian/Interface.lean` | MT Thm 0.1 | compiles with pending | 2 | topology |
| 9 | Define allowed summand predicates | space-form and bundle abstract API | `Topology/AllowedSummands.lean` | MT Thm 0.1 | reviewer accepts | 3 | topology |
| 10 | Connected-sum expression API | endgame skeleton | `Topology/ConnectedSum.lean` | 3-topology | compiles | 3 | Lean/topology |
| 11 | Finite-list connected sum induction | classification induction | `Topology/ExtinctionToClassification.lean` | MT Cor 0.5 | list part no-sorry | 3 | Lean |
| 12 | Fundamental group hypothesis from simply connected | trivial group case | `Topology/SimplyConnectedEndgame.lean` | algebraic topology | compiles | 2 | algebraic topology |
| 13 | Space-form simply connected interface | exclude quotient factors | `Topology/SphericalSpaceForm.lean` | MT Cor 0.2 | statement reviewed | 3 | topology |
| 14 | `S²`-bundle not simply connected | exclude bundle factors | `Topology/SphereBundlesOverS1.lean` | MT Thm 0.1 | statement reviewed | 3 | topology |
| 15 | Connected sum of spheres identity | final endgame step | `Topology/ConnectedSum.lean` | 3-topology | statement compiles | 3 | topology |
| 16 | Simply connected endgame theorem | Ricci-free main result | `Topology/SimplyConnectedEndgame.lean` | MT Cor 0.2 | proof skeleton compiles | 4 | topology + Lean |
| 17 | Prove `poincare_from_morgan_tian` | top-level bridge | `Topology/SimplyConnectedEndgame.lean` | MT 0.1 -> Cor 0.2 | compiles | 3 | Lean |
| 18 | Riemannian conventions document | fix signs | `Riemannian/CurvatureConventions.lean` | MT Ch.1 | expert approved | 2 | geometry |
| 19 | Ricci flow structure statement | PDE entry | `RicciFlow/Basic.lean` | MT Def.3.1 | pending statement reviewed | 4 | geometry + Lean |
| 20 | Generalized Ricci flow structure | surgery precondition | `RicciFlow/Generalized.lean` | MT Def.3.34--3.36 | ordinary RF embeds | 4 | geometry |
| 21 | L-length definitions | Perelman entry | `Perelman/LLength.lean` | MT Def.6.2 | definition compiles | 4 | geometry |
| 22 | Reduced volume interface | noncollapsing precondition | `Perelman/ReducedVolume.lean` | MT Ch.6--8 | blueprint node exists | 5 | geometry |
| 23 | κ-solution interface | canonical neighborhood precondition | `Perelman/KappaSolution.lean` | MT Ch.9 | statement reviewed | 4 | geometry |
| 24 | Canonical neighborhood definitions | surgery geometry | `Perelman/CanonicalNeighborhood.lean` | MT Ch.9--11 | compiles | 4 | geometry |
| 25 | Surgery spacetime structure | main surgery object | `Surgery/SurgerySpaceTime.lean` | MT Ch.14 | statement reviewed | 5 | geometry + Lean |
| 26 | Surgery topological effect interface | MT0.3 topology output | `Topology/SurgeryTopology.lean` | MT §5.5 | statement reviewed | 4 | topology |
| 27 | Long-time surgery theorem interface | MT0.3/15.9 | `Surgery/LongTimeExistence.lean` | MT Ch.15--17 | source map complete | 5 | geometry |
| 28 | Forward difference quotient API | extinction calculus | `Extinction/ForwardDifference.lean` | MT Ch.2 §7 | basic lemma no-sorry | 3 | analysis |
| 29 | Finite extinction interface | MT0.4/18.1 | `Extinction/FiniteTimeExtinction.lean` | MT Ch.18--19 | source map complete | 5 | geometry |
| 30 | Weekly blueprint audit script | prevent drift | `scripts/check_blueprint.py` | LeanArchitect/CI | reports stale nodes | 3 | infra |
