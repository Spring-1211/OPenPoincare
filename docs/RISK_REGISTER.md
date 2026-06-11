# Risk register

| # | Risk | Severity | Early warning sign | Mitigation | First test theorem |
|---:|---|---:|---|---|---|
| 1 | mathlib lacks connected sum | High | endgame cannot express decomposition | abstract predicate first | `connectedSum_sphere_identity` |
| 2 | van Kampen unavailable | High | no `π₁` connected-sum theorem | interface, separate algebraic topology project | `pi1_connectedSum` |
| 3 | spherical space-form quotient API missing | High | cannot exclude nontrivial quotients | abstract `IsSphericalSpaceForm` | `simplyConnected_sphericalSpaceForm_diffeomorphic_sphere` |
| 4 | Moise theorem missing | Medium | topological/smooth target confusion | prove smooth target first | `homeomorph_to_diffeomorph_three_interface` |
| 5 | Riemannian curvature API insufficient | Extreme | Ricci-flow equations cannot be stated | minimal internal convention layer | `scalar_curvature_evolution_statement` |
| 6 | curvature sign mismatch | Extreme | evolution equations disagree | central convention file | constant-curvature sphere tests |
| 7 | Ricci PDE existence too large | Extreme | short-time existence stalls | keep as interface | `ricciFlow_shortTimeExistence_compact` |
| 8 | generalized Ricci flow model wrong | Extreme | surgery spacetime cannot connect | regular-part first design | `ordinary_to_generalized_statement` |
| 9 | surgery spacetime quotient too complex | Extreme | typeclass/quotient explosion | data-structure first | `SurgerySpaceTime` |
| 10 | κ-solution compactness too large | Extreme | canonical neighborhoods blocked | interface layer | `kappaSolution_compactness` |
| 11 | reduced volume needs weak analysis | Extreme | cut-locus/measure-zero bottleneck | prove smooth-domain special cases first | `reducedVolume_monotone` |
| 12 | minimal disk theory missing | Extreme | `W₂/W₃` cannot be defined | interface and separate project | `W2_minArea_nontrivialPi2` |
| 13 | curve-shortening ramp technicalities | Extreme | Chapter 19 cannot be decomposed | dedicated ramp subproject | `curveShortening_ramp_regular` |
| 14 | Lean performance issues | Medium/High | slow imports and `simp` explosions | small files, profiling | `lake build` timing |
| 15 | blueprint/Lean drift | High | `\lean{}` names stale | audit script and checkdecls | `scripts/check_blueprint.py` |
| 16 | statements too strong | High | expert flags missing assumptions | adversarial review | `MT03_statement_review` |
| 17 | reviewer imbalance | High | Lean PRs lack domain review | required reviewer expertise | weekly audit |
| 18 | upstream PR friction | Medium | private API grows | early mathlib coordination | small helper PRs |
