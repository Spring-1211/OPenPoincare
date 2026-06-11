# Poincaré Lean 4 Formalization Blueprint 设计方案

这份方案的定位不是“证明已经形式化”，而是建立一个 **专家可审查、Lean statement 可编译核查、依赖可追踪、多人可分工、长期可迭代** 的庞加莱猜想形式化 Blueprint。数学主线建议以 Morgan–Tian 对 Perelman 证明的组织为主：先做 Ricci flow with surgery 的长时间存在，再做有限时间灭绝，再把 surgery 的拓扑效果降为 connected-sum 分类，最后由 simply connected endgame 推出 (S^3)。Morgan–Tian 的书明确说明其目标是给出 Perelman 三篇预印本的完整细节证明，并分为 Riemannian/Ricci 背景、Perelman length function 与 non-collapsing、Ricci flow with surgery、finite-time extinction 四大部分；这正好对应形式化工程的分层。

---

## 一、什么是世界级形式化 Blueprint

顶级形式化 Blueprint 不是普通证明大纲，而是一个 **proof engineering contract**。它至少要同时服务四类读者：几何分析专家、三维拓扑专家、Lean/mathlib 专家、项目管理者。每个 theorem/definition 节点都应有：

| 维度                   | 世界级要求                                                                                          |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| 人类数学路线               | 每个节点有清楚 informal statement、证明思路、数学来源、是否为 Perelman/Morgan–Tian/Kleiner–Lott/经典拓扑定理              |
| Lean 绑定              | 每个节点绑定 `\lean{...}` 声明；statement 与 Lean declaration 同步                                         |
| 依赖 DAG               | 用 `\uses{...}` 生成数学依赖图；另外单独记录 Lean import dependency                                           |
| 粒度控制                 | 顶层 theorem 粗，中层 lemma 可分工，叶子 lemma 小到可被 Lean/LLM/人类局部证明                                        |
| source locator       | 每个节点给出书籍章节、定理号、页码或 mathlib 文件路径                                                                |
| mathlib gap analysis | 明确“已存在 / 大概率缺失 / 需查证 / 需新建基础设施”                                                                |
| pending theorem 管理   | 允许短期 interface theorem，但必须有 source、purpose、replacement plan、owner、risk                         |
| CI / no-sorry gate   | skeleton 分支允许 pending；核心分支逐步启用 no-sorry gate                                                   |
| 多人协作                 | 每个节点有 owner expertise、priority、status、reviewer                                                 |
| AI 接口                | 每个 theorem statement 小而明确，可由 theorem-statement agent、search agent、proof agent、audit agent 分别处理 |
| 专家审查                 | 有数学忠实性、Lean statement 忠实性、正则性假设、曲率约定、拓扑/光滑桥接等 checklist                                        |

当前最成熟的人类可读 Blueprint 工具是 `leanblueprint`：它是一个用于 Lean 4 项目的 plasTeX 插件，可以写 LaTeX blueprint 并连接 Lean 代码。leanblueprint 的仓库列出 Sphere Eversion、Liquid Tensor、PFR、FLT 等多个使用案例。([GitHub][1]) Tao 的 PFR 项目展示了理想工作流：Blueprint 自动生成依赖图，颜色区分“statement 已形式化”“proof 已完成”等状态，并且可以从图节点跳到人类可读陈述、Lean 文档和源码。([What's new][2]) FLT 项目则展示了大型、多作者、长期项目如何同时维护 website、documentation、blueprint、Lean 源码和 contribution workflow。([GitHub][3])

对庞加莱项目，我建议采用 **leanblueprint + Lean-first skeleton + LeanArchitect 辅助同步** 的混合模式。LeanArchitect 的目标是从 Lean 源码直接生成 blueprint data，通过 `@[blueprint]` 标签抽取 theorem/definition、自动推断依赖、判断是否 sorry-free；这可以降低 LaTeX blueprint 与 Lean 代码长期漂移的风险。([GitHub][4])

---

## 二、项目最终 theorem target

### 2.1 当前 mathlib 状态核查

截至本次联网核查，mathlib 已有模块：

```lean
Mathlib.Geometry.Manifold.PoincareConjecture
```

该模块导入了 simply connected、diffeomorphism、homotopy equivalence、sphere instances 等基础模块；文档说明 `≃ₕ` 表示 homotopy equivalence，`≃ₜ` 表示 homeomorphism，`≃ₘ⟮n,n⟯` 表示以 (n)-维欧氏空间为模型空间的 diffeomorphism。([leanprover-community.github.io][5])

源码中已经有三维拓扑庞加莱和三维光滑庞加莱的声明，但仍是 `proof_wanted`：

```lean
proof_wanted SimplyConnectedSpace.nonempty_homeomorph_sphere_three ...
proof_wanted SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three ...
```

三维光滑目标声明大意是：

```lean
proof_wanted SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three
  [T2Space M]
  [ChartedSpace ℝ³ M]
  [IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
  [SimplyConnectedSpace M]
  [CompactSpace M] :
  Nonempty (M ≃ₘ⟮3, 3⟯ S³)
```

源码中的 exact pretty syntax 需要本地 `#check SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three` 验证，但目标名称、类型类结构和 `proof_wanted` 状态已经可以从当前 mathlib 源码确认。([GitHub][6])

### 2.2 closed smooth 3-manifold 的 Lean 表达

在 mathlib 目标 statement 中，“closed smooth 3-manifold” 实际被拆成：

```lean
[T2Space M]
[ChartedSpace ℝ³ M]
[IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
[CompactSpace M]
```

解释：

| 数学条件                     | Lean 表达                                             | 备注                                                                                                                                                         |
| ------------------------ | --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hausdorff                | `[T2Space M]`                                       | mathlib manifold 通常显式要求                                                                                                                                    |
| 无边界 3-维 charted manifold | `[ChartedSpace ℝ³ M]`                               | 模型空间是 (\mathbb R^3)，不是 half-space                                                                                                                          |
| smooth                   | `[IsManifold (𝓘(ℝ, ℝ³)) ∞ M]`                      | (C^\infty) smooth manifold                                                                                                                                 |
| closed                   | `[CompactSpace M]` 加无边界模型                           | “closed” 在流形语境中是 compact without boundary                                                                                                                  |
| simply connected         | `[SimplyConnectedSpace M]`                          | mathlib 定义 simply connected space via fundamental groupoid equivalent to `Discrete Unit`；文档也给出 loop-nullhomotopic 表征。([leanprover-community.github.io][7]) |
| (S^3)                    | `sphere (0 : EuclideanSpace ℝ (Fin 4)) 1`，局部记号 `S³` | mathlib 文件用 superscript macro                                                                                                                              |
| diffeomorphic to (S^3)   | `Nonempty (M ≃ₘ⟮3, 3⟯ S³)`                          | 与 mathlib 目标一致                                                                                                                                             |

### 2.3 topological vs smooth Poincaré

Morgan–Tian 在引言脚注中指出，每个 topological 3-manifold 有 differentiable structure，且 smooth 3-manifold 间的 homeomorphism 可近似为 diffeomorphism，因此 3 维的 topological classification up to homeomorphism 与 smooth classification up to diffeomorphism 等价；这就是通常称为 Moise theorem 及其后果的桥接。

Lean 中必须把这件事拆开：

```lean
-- 需查证 mathlib 是否已有；大概率缺失。
theorem moise_smooth_structure_exists_for_topological_three_manifold : ...

theorem three_manifold_homeomorph_approximates_diffeomorph
  (e : M ≃ₜ N) :
  Nonempty (M ≃ₘ⟮3, 3⟯ N) := ...
```

第一阶段应避开 Moise 负担，直接证明 mathlib 的 **smooth statement**。拓扑版 `nonempty_homeomorph_sphere_three` 可以作为副目标，但不要让它阻塞主线。

### 2.4 最小目标与增强目标

| 目标层级                   | Lean target                                                                   | 项目意义                                                  |
| ---------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------- |
| Minimal target         | 替换 `SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three` 的 `proof_wanted` | 项目核心目标                                                |
| Intermediate target    | 从 Morgan–Tian classification interface 推出 smooth Poincaré                     | 0–12 月可实现骨架                                           |
| Stronger target        | 形式化 spherical space-form conjecture                                           | 与 Morgan–Tian Corollary 0.2(b) 对齐                     |
| Future target          | 完整 Theorem 0.1 / Corollary 0.5                                                | 包含 finite fundamental group/free product/S²-bundle 分类 |
| Not first-stage target | 完整 Thurston geometrization                                                    | 需要大时间塌缩和 collapsing theory，不适合作为第一阶段                  |

---

## 三、数学主证明链

Morgan–Tian 引言给出的关键结构是：

1. Theorem 0.1：若闭连通 3-流形基本群是有限群与无限循环群的自由积，则它是球面空间形式、(S^2\times S^1)、非定向 (S^2)-bundle over (S^1) 的 connected sum。
2. Corollary 0.2：推出 closed simply connected 3-manifold diffeomorphic to (S^3)，以及 spherical space-form conjecture。
3. Theorem 0.3：在无 locally separating (RP^2) 条件下，Ricci flow with surgery 全时间存在；surgery time 离散；拓扑变化是 connected-sum decomposition 加标准分量移除。
4. Theorem 0.4：若 (\pi_1) 是有限群与无限循环群的自由积，则 Ricci flow with surgery finite-time extinct。
5. Corollary 0.5：finite extinction、connected sum of spherical space-forms and (S^2)-bundles over (S^1)、fundamental group free product 等条件等价。

### 3.1 顶层 DAG

```text
Poincare_3_smooth
│
├── MT_0_1_classification
│   │
│   ├── MT_0_3_long_time_surgery_flow
│   │   ├── normalized_initial_metric
│   │   ├── generalized_ricci_flow
│   │   ├── reduced_volume_noncollapsing
│   │   ├── kappa_solution_canonical_neighborhoods
│   │   ├── standard_solution
│   │   ├── controlled_surgery
│   │   └── no_accumulation_of_surgery_times
│   │
│   ├── MT_0_4_finite_time_extinction
│   │   ├── pi2_extinction_via_W2
│   │   ├── pi3_loop_space_width
│   │   ├── Dini_forward_difference_quotients
│   │   ├── lower_semicontinuity_at_surgery
│   │   └── curve_shortening_ramp_solutions
│   │
│   └── surgery_topological_effect
│       ├── sphere_surgery_connected_sum
│       ├── removed_components_standard_topology
│       └── downward_induction_connected_sum_classification
│
└── simply_connected_endgame
    ├── simply_connected_excludes_nontrivial_space_forms
    ├── simply_connected_excludes_S2_bundles
    ├── connected_sum_fundamental_group_free_product
    └── connected_sum_of_S3s_is_S3
```

### 3.2 核心节点表

| ID              | informal statement                                                                      | source                                  | proposed Lean name                                        | dependencies                                       | status                            | difficulty | owner expertise               | validation test                              | risk                                           |
| --------------- | --------------------------------------------------------------------------------------- | --------------------------------------- | --------------------------------------------------------- | -------------------------------------------------- | --------------------------------- | ---------: | ----------------------------- | -------------------------------------------- | ---------------------------------------------- |
| `PC3`           | every compact simply connected smooth 3-manifold is diffeomorphic to (S^3)              | mathlib current target                  | `SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three` | `MT_0_1_classification`, endgame                   | existing statement, proof missing |          5 | Lean manifold + 3-topology    | `#check` exact target compiles               | target statement may need exact model notation |
| `MT01`          | free product finite/cyclic (\pi_1) implies connected sum classification                 | Morgan–Tian Theorem 0.1                 | `Poincare.MorganTian.classification`                      | long-time surgery, extinction, topology            | interface first                   |          5 | 3-topology + Ricci surgery    | simply connected specialization proves `PC3` | too broad for early Lean                       |
| `MT03`          | Ricci flow with surgery exists all (t\ge0), surgery times discrete, topology controlled | Morgan–Tian Theorem 0.3; Chapters 13–17 | `Poincare.Surgery.long_time_existence_with_surgery`       | Ricci/Perelman/surgery                             | interface long-term               |          5 | geometric analysis            | statement accepted by experts                | enormous analytic infrastructure               |
| `MT04`          | group hypothesis implies finite-time extinction                                         | Morgan–Tian Theorem 0.4; Chapter 18     | `Poincare.Extinction.finite_time_extinction`              | `MT03`, (W_2), loop width                          | interface long-term               |          5 | Ricci flow + minimal surfaces | derives empty time slice                     | boundary/ramp analysis                         |
| `SURG_TOP`      | surgery changes topology by (S^2)-surgery/connected sum and removes standard components | Morgan–Tian 0.3, §5.5 intro, Appendix   | `Poincare.Topology.surgery_topological_effect`            | connected sum API, canonical-neighborhood topology | partial early                     |          4 | 3-manifold topology           | formal statement about finite sequence       | connected sum not in mathlib                   |
| `EXT_CLASS`     | finite extinction plus surgery topology gives connected sum classification              | Morgan–Tian proof after Theorem 0.4     | `Poincare.Topology.extinction_to_classification`          | `SURG_TOP`, finite sequence induction              | early interface/provable          |          3 | topology + Lean               | finite list induction compiles               | encoding connected sum                         |
| `SC_END`        | simply connected member of classification is (S^3)                                      | Corollary 0.2(a)                        | `Poincare.Topology.simplyConnected_endgame`               | (\pi_1) of summands/free products                  | early target                      |        3–4 | algebraic topology            | no Ricci imports                             | need van Kampen/free product                   |
| `RV_MONO`       | reduced volume monotonicity                                                             | Morgan–Tian Chapters 6–8                | `Poincare.Perelman.reducedVolume_mono`                    | L-length/L-geodesics/Jacobi                        | future                            |          5 | geometric analysis            | noncollapsing theorem uses it                | weak derivatives/cut locus                     |
| `KAPPA_COMPACT` | compactness of based (\kappa)-solutions                                                 | Morgan–Tian Theorem 9.64                | `Poincare.Perelman.kappaSolution_compactness`             | Hamilton compactness + noncollapse                 | future                            |          5 | Ricci flow                    | canonical neighborhoods follows              | smooth convergence API missing                 |
| `SURG_NO_ACC`   | surgery times do not accumulate on compact intervals                                    | Morgan–Tian Chapter 17                  | `Poincare.Surgery.surgeryTimes_locallyFinite`             | volume evolution + surgery removes volume          | future                            |          4 | Ricci surgery                 | local finiteness instance                    | quantitative parameters                        |

Morgan–Tian’s surgery spacetime model is not just “a list of manifolds by time”: it is a singular 4-dimensional spacetime with time function, exposed regions and horizontal metric, whose smooth part is a generalized Ricci flow. This matters for Lean modeling because all analytic estimates live on the regular generalized-flow part, while topology changes at singular surgery times.

### 3.3 为什么不把完整几何化作为第一阶段目标

完整 Thurston geometrization requires long-time analysis as (t\to\infty), collapsed spaces with curvature locally bounded below, and additional collapsing/stability theory. Morgan–Tian explicitly says their book does **not** explicate the additional long-time/collapsing results needed for geometrization, but instead proves Theorem 0.1 via finite-time extinction for the cases needed for Poincaré and spherical space-form.

形式化上，这意味着：

| 路线                        | 优点                                                 | 缺点                                                                | 第一阶段建议           |
| ------------------------- | -------------------------------------------------- | ----------------------------------------------------------------- | ---------------- |
| Finite extinction route   | 目标直接；避免 (t\to\infty) collapsing；Morgan–Tian 给出详细证明 | 仍需 Ricci surgery、minimal disk width、curve shortening              | 采用               |
| Full geometrization route | 更强                                                 | 多出 collapsed Alexandrov/Perelman stability/Shioya–Yamaguchi 等巨大理论 | 远期扩展             |
| Pure 3-topology route     | 避免 PDE                                             | 无法形式化 Perelman route，且三维分类本身也巨大                                   | 只做 endgame，不做主证明 |

---

## 四、Lean module architecture

建议仓库结构：

```text
Poincare/
  Main.lean
  Blueprint/
    blueprint.tex
    content.tex
    macros.tex
  Poincare/
    Foundation/
      ProjectConventions.lean
      Pending.lean
      Dimension3.lean
    Topology/
      ClosedSmooth3Manifold.lean
      ConnectedSum.lean
      SphericalSpaceForm.lean
      SphereBundlesOverS1.lean
      PrimeDecompositionInterface.lean
      SurgeryTopology.lean
      ExtinctionToClassification.lean
      SimplyConnectedEndgame.lean
    Riemannian/
      MetricTensor.lean
      LeviCivita.lean
      CurvatureConventions.lean
      CurvatureComparison.lean
      InjectivityRadius.lean
      NonnegativeCurvature.lean
      CheegerGromov.lean
    RicciFlow/
      Basic.lean
      Generalized.lean
      NormalizedInitialMetric.lean
      EvolutionEquations.lean
      MaximumPrinciple.lean
      ShiEstimates.lean
      HamiltonCompactness.lean
      Pinching.lean
    Perelman/
      LLength.lean
      LGeodesic.lean
      ReducedLength.lean
      ReducedVolume.lean
      Noncollapsing.lean
      KappaSolution.lean
      CanonicalNeighborhood.lean
      BoundedCurvatureAtBoundedDistance.lean
    Surgery/
      Neck.lean
      Cap.lean
      StandardSolution.lean
      SurgerySpaceTime.lean
      SurgeryOperation.lean
      ControlledSurgery.lean
      LongTimeExistence.lean
    Extinction/
      ForwardDifference.lean
      PathsOfComponents.lean
      Pi2W2.lean
      LoopSpaceWidth.lean
      CurveShortening.lean
      RampSolutions.lean
      FiniteTimeExtinction.lean
```

| 模块           | 数学内容                                           | mathlib 依赖                                                                                                                               | 早期产出                      | 长期建设                              | 适合上游 |
| ------------ | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- | --------------------------------- | ---- |
| `Foundation` | notation、dimension 3、pending theorem policy    | `Mathlib.Geometry.Manifold.PoincareConjecture`                                                                                           | 最终 target 对齐              | no-sorry gate                     | 部分   |
| `Topology`   | connected sum、space forms、(S^2)-bundle、endgame | fundamental group, manifolds, sphere                                                                                                     | topology endgame          | prime decomposition, van Kampen   | 高    |
| `Riemannian` | metric, curvature, comparison                  | `Geometry.Manifold.Riemannian.Basic` 等；mathlib 已有 Riemannian manifold 基础，但 Ricci curvature API 需核查。([leanprover-community.github.io][8]) | curvature convention      | Cheeger–Gromov                    | 高    |
| `RicciFlow`  | Ricci flow PDE                                 | manifold + analysis                                                                                                                      | theorem interfaces        | existence, maximum principle, Shi | 中高   |
| `Perelman`   | reduced geometry                               | RicciFlow                                                                                                                                | theorem interfaces        | reduced volume monotonicity       | 中    |
| `Surgery`    | surgery spacetime, neck/cap                    | RicciFlow + Topology                                                                                                                     | topology effect interface | full controlled surgery           | 部分   |
| `Extinction` | (W_2), loop space width, Dini derivatives      | Topology + RicciFlow                                                                                                                     | ForwardDifference API     | minimal disk/ramp analysis        | 部分   |

Lake 项目应固定 `lean-toolchain`、`lakefile.toml`/`lakefile.lean` 和 `lake-manifest.json`；Lake 官方文档把这些列为标准 workspace 结构，并说明 manifest 固定依赖版本。([Lean Language][9])

---

## 五、拓扑 endgame 优先方案

第一阶段目标：**先不证明 Ricci flow**，只假设一个 Morgan–Tian classification interface，然后在 Lean 中推出 mathlib 的 smooth 3D Poincaré statement。

### 5.1 早期 interface

```lean
namespace Poincare

-- 需设计；第一版可作为 interface theorem。
structure IsSphericalSpaceForm (M : Type u) [TopologicalSpace M] : Prop where
  -- e.g. ∃ finite Γ acting freely/smoothly/isometrically on S³, M ≃ₘ quotient
  exists_quotient : Prop

structure IsS2BundleOverS1 (M : Type u) [TopologicalSpace M] : Prop where
  -- two diffeo types in dimension 3: orientable S²×S¹ and nonorientable bundle
  bundle_data : Prop

inductive MorganTianSummand (M : Type u) [TopologicalSpace M] : Prop
| spherical : IsSphericalSpaceForm M → MorganTianSummand M
| s2bundle : IsS2BundleOverS1 M → MorganTianSummand M

-- A placeholder for "M is diffeomorphic to a finite connected sum of allowed summands".
structure IsMorganTianConnectedSum
    (M : Type u) [TopologicalSpace M] : Prop where
  summands : List (ClosedSmooth3Manifold)
  allowed : ∀ N ∈ summands, MorganTianSummand N.carrier
  diffeo_connectedSum : Prop

theorem morgan_tian_classification_interface
    {M : Type u}
    [TopologicalSpace M] [T2Space M]
    [ChartedSpace ℝ³ M] [IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
    [CompactSpace M] [ConnectedSpace M]
    (hπ : Pi1FreeProductFiniteAndInfiniteCyclic M) :
    IsMorganTianConnectedSum M := by
  -- pending / proof_wanted
  sorry

end Poincare
```

这里 `ClosedSmooth3Manifold` 是否作为 bundled structure 需要慎重。Lean 中 topology/manifold typeclass 参数很重，早期建议用 bundled object 包装，避免反复传巨大实例：

```lean
structure ClosedSmooth3Manifold where
  carrier : Type u
  top : TopologicalSpace carrier
  t2 : T2Space carrier
  charted : ChartedSpace ℝ³ carrier
  smooth : IsManifold (𝓘(ℝ, ℝ³)) ∞ carrier
  compact : CompactSpace carrier
```

这段代码需本地 `#check` 调整 universe/typeclass instance syntax。

### 5.2 connected sum API

大概率需要新建。最小 API 不必一开始构造 connected sum 的 quotient，而可以先用 **diffeomorphism-to-connected-sum expression** 的抽象 predicate：

```lean
inductive ConnectedSumExpr : Type (u+1)
| atom : ClosedSmooth3Manifold → ConnectedSumExpr
| sphere : ConnectedSumExpr
| sum : ConnectedSumExpr → ConnectedSumExpr → ConnectedSumExpr

def RealizesConnectedSum (M : ClosedSmooth3Manifold) (e : ConnectedSumExpr) : Prop := ...
```

早期 theorem：

```lean
theorem connectedSum_sphere_left
  (M : ClosedSmooth3Manifold) :
  RealizesConnectedSum M (ConnectedSumExpr.sum ConnectedSumExpr.sphere (.atom M)) := ...

theorem pi1_connectedSum
  (M N : ClosedSmooth3Manifold) :
  FundamentalGroup (ConnectedSum M N) base ≃*
    FreeProduct (FundamentalGroup M baseM) (FundamentalGroup N baseN) := ...
```

实际 `FreeProduct`、van Kampen、basepoint 管理是否可直接使用 mathlib 需查证。当前 mathlib 已有 `FundamentalGroup` 定义和 path-connected basepoint independence，但搜索没有确认 van Kampen/connected sum 已现成。([leanprover-community.github.io][10])

### 5.3 spherical space-form API

Morgan–Tian 的 spherical space-form 是 (S^3) 被有限群自由线性作用的商。 Lean 中建议先使用抽象 predicate：

```lean
structure IsSphericalSpaceForm (M : Type u)
    [TopologicalSpace M] [ChartedSpace ℝ³ M] : Prop where
  Γ : Type v
  instGroup : Group Γ
  instFinite : Fintype Γ
  action : MulAction Γ S³
  free_action : Prop
  quotient_diffeomorphic : Nonempty (M ≃ₘ⟮3,3⟯ QuotientByAction Γ S³)
```

关键 endgame theorem：

```lean
theorem simplyConnected_sphericalSpaceForm_diffeomorphic_sphere
    {M : ClosedSmooth3Manifold}
    (hssf : IsSphericalSpaceForm M.carrier)
    [SimplyConnectedSpace M.carrier] :
    Nonempty (M.carrier ≃ₘ⟮3,3⟯ S³) := ...
```

证明逻辑：若 (M \cong S^3/\Gamma)，则 (\pi_1(M)\cong \Gamma)；simple connected 迫使 (\Gamma) 平凡，商即 (S^3)。这需要 covering space/fundamental group of quotient API，早期可设为 interface。

### 5.4 (S^2)-bundle over (S^1) API

Morgan–Tian Theorem 0.1 中允许 copies of (S^2\times S^1) 和唯一非定向 (S^2)-bundle over (S^1)。

早期定义：

```lean
inductive S2BundleType
| orientable
| nonorientable

structure IsS2BundleOverS1 (M : ClosedSmooth3Manifold) : Prop where
  bundleType : S2BundleType
  diffeo_model : Prop
```

排除 theorem：

```lean
theorem not_simplyConnected_s2BundleOverS1
    {M : ClosedSmooth3Manifold}
    (h : IsS2BundleOverS1 M)
    [SimplyConnectedSpace M.carrier] :
    False := ...
```

数学理由：任意 (S^2)-bundle over (S^1) 的 fundamental group 至少映到 (\pi_1(S^1)\cong \mathbb Z)，非平凡。Lean 中需要 fiber bundle long exact sequence 或直接模型计算；早期可 interface。

### 5.5 endgame theorem sketches

```lean
theorem simplyConnected_morganTianConnectedSum_implies_sphere
    {M : ClosedSmooth3Manifold}
    [SimplyConnectedSpace M.carrier]
    (hMT : IsMorganTianConnectedSum M) :
    Nonempty (M.carrier ≃ₘ⟮3,3⟯ S³) := by
  -- Plan:
  -- 1. Use π₁ of connected sum = free product of π₁ summands.
  -- 2. Since π₁ M is trivial, each summand's π₁ is trivial.
  -- 3. S²-bundles excluded.
  -- 4. Spherical space-form summands must be S³.
  -- 5. Connected sum of finitely many S³ is S³.
  sorry
```

```lean
theorem poincare_from_morgan_tian
    {M : Type u}
    [TopologicalSpace M] [T2Space M]
    [ChartedSpace ℝ³ M] [IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M] :
    Nonempty (M ≃ₘ⟮3,3⟯ S³) := by
  -- obtain group hypothesis from simply connected
  -- apply MT classification
  -- apply endgame
  sorry
```

这一层的主要缺口不是 Ricci flow，而是 mathlib 中 3-manifold topology API：connected sum、sphere theorem、prime decomposition、van Kampen for connected sums、space-form quotient、(S^2)-bundle classification。建议第一年把这些全声明成 interface，并优先真正证明其中纯代数/纯列表/有限 induction 部分。

---

## 六、Riemannian/Ricci/Perelman/Surgery/Extinction 分层 Blueprint

### 6.1 Riemannian geometry theorem table

| ID               | proposed Lean name                        | statement sketch                                                            | source                            | status           | difficulty |
| ---------------- | ----------------------------------------- | --------------------------------------------------------------------------- | --------------------------------- | ---------------- | ---------: |
| `RiemMetric`     | `Poincare.Riemannian.ContMDiffMetric`     | smooth positive definite metric tensor on tangent bundle                    | MT Ch.1; mathlib Riemannian basic | partial existing |          3 |
| `LeviCivita`     | `leviCivita_unique`                       | unique torsion-free metric-compatible connection                            | MT Theorem 1.2                    | likely missing   |          4 |
| `CurvConvention` | `curvatureConvention_MT`                  | (R(X,Y)Z=\nabla_X\nabla_YZ-\cdots); sign conventions fixed                  | MT Def.1.4                        | missing          |          3 |
| `RicScalar`      | `ricci_scalar_def`                        | Ricci and scalar curvature definitions                                      | MT Def.1.8                        | missing/partial  |          4 |
| `BishopGromov`   | `bishop_gromov_relativeVolume`            | relative volume comparison under Ricci lower bound                          | MT Theorem 1.34                   | missing          |          5 |
| `InjVol`         | `injRadius_of_curvatureBound_volumeLower` | bounded curvature + volume lower bound gives injectivity radius lower bound | MT Theorem 1.36                   | missing          |          5 |
| `Soul`           | `soul_theorem_positiveCurvature_three`    | complete noncompact positive curvature implies diffeo (\mathbb R^3)         | MT Theorem 2.7 / Remark 2.8       | interface        |          5 |
| `Splitting`      | `cheeger_gromoll_splitting`               | nonnegative Ricci + line implies product                                    | MT Theorem 2.13                   | interface        |          5 |
| `CGCompact`      | `cheeger_gromov_compactness_smooth`       | curvature derivative bounds + noncollapse imply smooth subsequential limit  | MT Ch.5                           | interface        |          5 |

### 6.2 Ricci flow theorem table

| ID                | Lean name                                     | statement sketch                                    | source                | status    | difficulty |
| ----------------- | --------------------------------------------- | --------------------------------------------------- | --------------------- | --------- | ---------: |
| `RicciFlowDef`    | `RicciFlow`                                   | (∂_t g=-2Ric(g))                                    | MT Def.3.1            | missing   |          4 |
| `GeneralizedRF`   | `GeneralizedRicciFlow`                        | spacetime + time + vector field + horizontal metric | MT Def.3.34–3.36      | missing   |          4 |
| `ShortTime`       | `ricciFlow_shortTimeExistence_compact`        | compact initial metric has unique local solution    | MT Theorem 3.11       | interface |          5 |
| `CurvEvol`        | `riemann_curvature_evolution`                 | evolution equations for Rm/Ric/R/volume             | MT Theorem 3.13       | future    |          5 |
| `DistanceVar`     | `distance_variation_under_ricciFlow`          | lower bound on derivative of distance               | MT Prop.3.21          | future    |          4 |
| `Shi`             | `shi_derivative_estimates`                    | curvature bound controls derivatives                | MT Theorems 3.27–3.29 | interface |          5 |
| `MaxScalar`       | `scalar_maximum_principle_ricciFlow`          | scalar curvature minimum inequality                 | MT Prop.4.1           | future    |          4 |
| `MaxTensor`       | `hamilton_tensor_maximum_principle`           | convex invariant tensor maximum principle           | MT Theorem 4.7        | interface |          5 |
| `Pinching`        | `curvature_pinched_toward_positive_preserved` | Hamilton–Ivey pinching                              | MT Theorem 4.26/4.32  | interface |          5 |
| `HamiltonCompact` | `hamilton_compactness_ricciFlows`             | smooth limit of based Ricci flows                   | MT Theorem 5.15       | interface |          5 |

MT Chapter 3 explicitly defines Ricci flow and generalized Ricci flow; scalar curvature evolution and Shi estimates are among the early analytic inputs.

### 6.3 Perelman theorem table

| ID              | Lean name                               | statement sketch                                                 | source            | status    | difficulty |         |   |
| --------------- | --------------------------------------- | ---------------------------------------------------------------- | ----------------- | --------- | ---------: | ------- | - |
| `LLength`       | `LLength`                               | (\mathcal L(\gamma)=\int \sqrt\tau(R+                            | X                 | ^2)d\tau) | MT Def.6.2 | missing | 4 |
| `LGeodesic`     | `LGeodesic`                             | Euler–Lagrange equation for L-geodesics                          | MT Lemma 6.4      | future    |          5 |         |   |
| `LExp`          | `LExpMap`                               | L-exponential map, cut-locus structure                           | MT §6.2–6.3       | future    |          5 |         |   |
| `ReducedLength` | `ReducedLength`                         | (l=L/(2\sqrt\tau))                                               | MT §6.5           | future    |          5 |         |   |
| `ReducedVolume` | `ReducedVolume`                         | (\tilde V=\int \tau^{-3/2}e^{-l}dvol)                            | MT §6.7           | future    |          5 |         |   |
| `RVMono`        | `reducedVolume_monotone`                | monotonicity along minimizing L-geodesics                        | MT Ch.6–8         | interface |          5 |         |   |
| `Noncollapse`   | `perelman_noncollapsing_generalized`    | reduced volume implies κ-noncollapsed                            | MT Ch.8           | interface |          5 |         |   |
| `KappaSol`      | `KappaSolution`                         | ancient, nonflat, complete, nonnegatively curved, κ-noncollapsed | MT Ch.9           | missing   |          4 |         |   |
| `AsymSoliton`   | `kappaSolution_asymptoticSoliton`       | κ-solution has asymptotic shrinking soliton                      | MT §9.2           | interface |          5 |         |   |
| `KappaCompact`  | `kappaSolution_compactness`             | compactness of based 3D κ-solutions                              | MT Theorem 9.64   | interface |          5 |         |   |
| `CanNeigh`      | `canonicalNeighborhood_from_kappaLimit` | high-curvature points modeled by κ-solutions                     | MT §9.8, Ch.10–11 | interface |          5 |         |   |

Morgan–Tian presents Perelman’s L-length/reduced volume specifically to prove non-collapsing, which is then essential for geometric limits.

### 6.4 Surgery theorem table

| ID                  | Lean name                                 | statement sketch                                                        | source                          | status                   | difficulty |
| ------------------- | ----------------------------------------- | ----------------------------------------------------------------------- | ------------------------------- | ------------------------ | ---------: |
| `EpsNeck`           | `EpsilonNeck`                             | (S^2\times(-ε^{-1},ε^{-1})) close to round cylinder                     | MT Def.2.18                     | missing                  |          4 |
| `Cap`               | `CanonicalCap`                            | cap core diffeo (B^3) or punctured (RP^3)                               | MT Def.9.72                     | missing                  |          4 |
| `StdSol`            | `standardSolution_exists_unique`          | standard metric on (\mathbb R^3), flow on ([0,1))                       | MT Ch.12                        | interface                |          5 |
| `StdCan`            | `standardSolution_canonicalNeighborhoods` | high curvature points in standard solution have canonical neighborhoods | MT Theorem 12.28                | interface                |          5 |
| `SurgerySpacetime`  | `SurgerySpaceTime`                        | singular spacetime with time slices and exposed regions                 | MT Ch.14                        | missing                  |          4 |
| `DeltaNeckSurgery`  | `surgery_on_delta_neck`                   | cut δ-neck, glue cap, preserve pinching                                 | MT Theorem 13.2                 | interface                |          5 |
| `SurgDist`          | `surgery_distance_decreasing`             | surviving map is distance-decreasing under separating surgery           | MT Prop.15.12                   | future                   |          4 |
| `ControlledSurgery` | `controlledRicciFlowWithSurgery`          | pinching + noncollapse + canonical neighborhoods                        | MT Ch.15                        | missing                  |          5 |
| `LongTime`          | `long_time_existence_with_surgery`        | all-time surgery flow with discrete surgery times                       | MT Theorem 15.9/Cor.15.10/Ch.17 | interface                |          5 |
| `NoAccum`           | `surgeryTimes_locallyFinite`              | finitely many surgeries in compact time interval                        | MT Ch.17                        | future                   |          4 |
| `SurgTop`           | `surgery_topological_effect`              | connected-sum decomposition + standard removed components               | MT Theorem 0.3, §5.5            | interface/early topology |          4 |

MT explicitly says surgery is along 2-spheres, because this produces connected-sum decomposition rather than uncontrolled topology; this is a crucial Lean design constraint. The distance-decreasing map across separating surgeries is Proposition 15.12, needed later for extinction estimates.

### 6.5 Extinction theorem table

| ID           | Lean name                                | statement sketch                                                    | source                | status        | difficulty |
| ------------ | ---------------------------------------- | ------------------------------------------------------------------- | --------------------- | ------------- | ---------: |
| `FwdDiff`    | `ForwardDifferenceQuotient`              | upper Dini/forward derivative calculus                              | MT Ch.2 §7            | missing/early |          3 |
| `PathComp`   | `PathOfComponents`                       | track component through time/surgery                                | MT Ch.18              | missing       |          4 |
| `W2`         | `W2_minArea_nontrivialPi2`               | minimal area of nontrivial (S^2) maps                               | MT Ch.18 §2           | future        |          5 |
| `W2Ineq`     | `W2_forwardDifference_inequality`        | (D^+W_2\le -4π+\frac{3}{4t+1}W_2)                                   | MT Ch.18              | interface     |          5 |
| `Pi2Gone`    | `pi2_eventually_trivial`                 | all components eventually have trivial (\pi_2)                      | MT Ch.18              | interface     |          5 |
| `Pi3Nontriv` | `pi3_nontrivial_after_pi2_zero`          | under group hypothesis remaining components have nontrivial (\pi_3) | MT Ch.18              | future        |          4 |
| `LoopWidth`  | `loopSpace_diskWidth`                    | Perelman (W(\xi)) via minimal spanning disks                        | MT Ch.18–19           | future        |          5 |
| `CurveShort` | `curveShortening_ramp_regular`           | ramp trick in (M\times S^1) avoids curve-shortening singularities   | MT Ch.19              | interface     |          5 |
| `W3Ineq`     | `loopWidth_forwardDifference_inequality` | (D^+W\le -2π+\frac{3}{4t+1}W)                                       | MT Ch.18–19           | interface     |          5 |
| `FiniteExt`  | `finite_time_extinction`                 | group hypothesis implies empty after finite time                    | MT Theorem 18.1 / 0.4 | interface     |          5 |

Morgan–Tian explains the two-step finite extinction proof: first use (W_2) to kill (\pi_2); then use a loop-space/minimal disk width invariant for (\pi_3), with forward difference inequality and lower semicontinuity through surgery. The book follows Perelman’s minimal-disk/loop-space approach instead of Colding–Minicozzi’s index-one minimax spheres because the latter technical details are described as daunting.

---

## 七、Blueprint theorem granularity

建议规模：

| 层级                         |                                                         数量建议 | 说明                                                                   |
| -------------------------- | -----------------------------------------------------------: | -------------------------------------------------------------------- |
| 顶层节点                       |                                                         8–12 | final Poincaré、MT0.1、MT0.3、MT0.4、surgery topology、endgame 等          |
| 中层节点                       |                                                       80–150 | 每章 5–15 个核心 theorem/definition                                       |
| 叶子节点                       |                                                     500–1500 | 曲率公式、ODE/PDE lemma、拓扑小引理、list induction、typeclass bridge             |
| 第一阶段 interface theorem     |                                                        30–60 | Ricci/Perelman/surgery/extinction 大定理可 pending；topology endgame 尽量真证 |
| 每个 theorem statement 最大复杂度 |                                                10–15 个显式参数以内 | 超过即 bundled structure 或拆 lemma                                       |
| 拆 lemma 标准                 |  statement 中出现多个独立数学概念、proof 超过 80 行、`simp` 超时、typeclass 推断慢 | 立即拆                                                                  |
| DAG 标注                     | `\uses{}` 表示数学依赖；Lean imports 另在 node metadata 或 README 表中列出 | 避免误把 import 当数学依赖                                                    |

一个好的节点应该像这样小：

```lean
theorem connectedSum_of_spheres_diffeomorphic_sphere
    (n : ℕ) :
    Nonempty ((connectedSum S³ S³) ≃ₘ⟮3,3⟯ S³)
```

而不是这样大：

```lean
theorem all_topological_consequences_of_surgery_and_extinction : ...
```

对于庞加莱形式化，最大风险是把 Theorem 15.9、Theorem 18.1 这类大定理作为永恒黑箱。正确做法是：早期 interface 可以存在，但必须继续展开成可替换的下层 DAG。

---

## 八、`leanblueprint` 文件模板

建议目录：

```text
blueprint/
  blueprint.tex
  src/
    content.tex
    intro.tex
    topology.tex
    riemannian.tex
    ricciflow.tex
    perelman.tex
    surgery.tex
    extinction.tex
    issues.tex
```

`blueprint.tex` 主体：

```latex
\documentclass{report}
\usepackage{amsmath, amsthm, amssymb}
\usepackage{hyperref}
\usepackage{leanblueprint}

\title{A Lean 4 Blueprint for the Poincaré Conjecture}
\author{PKU BICMR AI for Math Team}

\begin{document}
\maketitle
\tableofcontents

\input{src/intro}
\input{src/topology}
\input{src/riemannian}
\input{src/ricciflow}
\input{src/perelman}
\input{src/surgery}
\input{src/extinction}

\end{document}
```

### 样例 1：final Poincaré theorem

```latex
\begin{theorem}[Smooth three-dimensional Poincaré conjecture]
  \label{thm:poincare-three-smooth}
  \lean{SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three}
  \uses{thm:morgan-tian-classification-interface,
        thm:simply-connected-endgame}
  \leanok
  Let \(M\) be a compact smooth simply connected 3-manifold.
  Then \(M\) is diffeomorphic to \(S^3\).

  \begin{proof}
  Apply the Morgan--Tian classification theorem to \(M\).
  Since \(\pi_1(M)\) is trivial, the allowed connected-sum decomposition
  contains no nontrivial spherical space-form factor and no \(S^2\)-bundle
  over \(S^1\) factor. Thus every factor is \(S^3\), and a finite connected
  sum of copies of \(S^3\) is diffeomorphic to \(S^3\).
  \end{proof}
\end{theorem}
```

这里 `\leanok` 只能在 statement 或 proof 真正 Lean 侧 ready 时启用。早期如果 proof pending，应删除 `\leanok` 或用项目自定义 `\notready`。

### 样例 2：Morgan–Tian classification interface

```latex
\begin{theorem}[Morgan--Tian connected-sum classification]
  \label{thm:morgan-tian-classification-interface}
  \lean{Poincare.MorganTian.classification}
  \uses{thm:long-time-surgery-flow,
        thm:finite-time-extinction,
        thm:extinction-to-connected-sum-classification}
  Let \(M\) be a closed connected smooth 3-manifold whose fundamental
  group is a free product of finite groups and infinite cyclic groups.
  Then \(M\) is diffeomorphic to a connected sum of spherical space-forms,
  copies of \(S^2 \times S^1\), and copies of the non-orientable
  \(S^2\)-bundle over \(S^1\).

  \begin{proof}[Blueprint status]
  This is an interface theorem corresponding to Morgan--Tian Theorem 0.1.
  It will be replaced by the combination of long-time Ricci flow with surgery,
  finite-time extinction, and the topological analysis of surgery.
  \end{proof}
\end{theorem}
```

### 样例 3：long-time surgery flow

```latex
\begin{theorem}[Long-time Ricci flow with surgery]
  \label{thm:long-time-surgery-flow}
  \lean{Poincare.Surgery.long_time_existence_with_surgery}
  \uses{def:ricci-flow-with-surgery,
        thm:perelman-noncollapsing-with-surgery,
        thm:canonical-neighborhood-theorem,
        thm:surgery-preserves-pinching,
        thm:surgery-times-locally-finite}
  Let \((M,g_0)\) be a closed Riemannian 3-manifold with no embedded
  locally separating \(RP^2\). Then there exists a Ricci flow with surgery
  starting from \((M,g_0)\), defined for all \(t \ge 0\). Its surgery times
  are locally finite, and each surgery changes topology by a connected-sum
  decomposition and removal of standard components.

  \begin{proof}[Blueprint status]
  Interface theorem corresponding to Morgan--Tian Theorem 0.3 and
  Theorem 15.9/Corollary 15.10. The replacement proof depends on
  Chapters 13--17.
  \end{proof}
\end{theorem}
```

### 样例 4：finite-time extinction

```latex
\begin{theorem}[Finite-time extinction]
  \label{thm:finite-time-extinction}
  \lean{Poincare.Extinction.finite_time_extinction}
  \uses{thm:long-time-surgery-flow,
        thm:pi2-eventually-trivial,
        thm:loop-space-width-forward-difference}
  Let \(M\) be a closed 3-manifold whose fundamental group is a free
  product of finite groups and infinite cyclic groups. Then every Ricci flow
  with surgery starting from \(M\) becomes extinct after finite time.

  \begin{proof}[Blueprint status]
  Interface theorem corresponding to Morgan--Tian Theorem 0.4/18.1.
  The proof splits into \(W_2\)-extinction of \(\pi_2\) and Perelman's
  loop-space width argument for the remaining \(\pi_3\)-nontrivial
  components.
  \end{proof}
\end{theorem}
```

### 样例 5：topology from extinction

```latex
\begin{theorem}[Extinction implies connected-sum classification]
  \label{thm:extinction-to-connected-sum-classification}
  \lean{Poincare.Topology.extinction_to_connected_sum_classification}
  \uses{thm:surgery-topological-effect}
  Suppose a Ricci flow with surgery starting from a closed connected
  3-manifold becomes extinct after finitely many surgery/removal steps.
  If each surgery has the topological effect specified by Morgan--Tian,
  then the initial manifold is a connected sum of the standard removed
  component types.

  \begin{proof}
  Induct backward from the empty final time slice. At each step, inverse
  connected-sum decomposition and re-insertion of a removed standard
  component preserves the claimed connected-sum expression.
  \end{proof}
\end{theorem}
```

### 样例 6：simply connected endgame

```latex
\begin{theorem}[Simply connected endgame]
  \label{thm:simply-connected-endgame}
  \lean{Poincare.Topology.simplyConnected_morganTianConnectedSum_implies_sphere}
  \uses{thm:pi-one-connected-sum,
        thm:simply-connected-spherical-space-form,
        thm:s2-bundle-not-simply-connected,
        thm:connected-sum-sphere-identity}
  Let \(M\) be simply connected and diffeomorphic to a finite connected
  sum of Morgan--Tian summands. Then \(M\) is diffeomorphic to \(S^3\).

  \begin{proof}
  Use van Kampen to compute the fundamental group of a connected sum as
  a free product. Triviality of \(\pi_1(M)\) forces each summand to have
  trivial \(\pi_1\). This rules out \(S^2\)-bundles over \(S^1\), and forces
  each spherical space-form to be \(S^3\). Finally \(S^3\) is the identity for
  connected sum in dimension 3.
  \end{proof}
\end{theorem}
```

### 样例 7：reduced volume monotonicity

```latex
\begin{theorem}[Reduced volume monotonicity]
  \label{thm:reduced-volume-monotonicity}
  \lean{Poincare.Perelman.reducedVolume_monotone}
  \uses{def:L-length, def:reduced-length,
        def:reduced-volume, thm:L-jacobi-second-variation}
  For a generalized Ricci flow, the reduced volume of a domain transported
  by minimizing \(\mathcal L\)-geodesics is monotone in backward time on
  the interval where the construction is defined.

  \begin{proof}[Blueprint status]
  This is the Perelman monotonicity theorem used to prove non-collapsing.
  The formal proof requires the \(\mathcal L\)-exponential map, cut-locus
  measure-zero statements, second variation inequalities, and weak
  differentiability of reduced length.
  \end{proof}
\end{theorem}
```

### 样例 8：surgery topological effect

```latex
\begin{theorem}[Topological effect of surgery]
  \label{thm:surgery-topological-effect}
  \lean{Poincare.Topology.surgery_topological_effect}
  \uses{def:delta-neck, thm:canonical-neighborhood-topology,
        thm:sphere-surgery-connected-sum}
  Crossing a surgery time changes a time slice by finitely many ordinary
  \(S^2\)-surgeries, hence by a partial connected-sum decomposition, and
  by removal of components diffeomorphic to the standard types listed in
  Morgan--Tian Theorem 0.3.

  \begin{proof}[Blueprint status]
  This theorem is partly topological and should be developed before the
  analytic surgery estimates are fully formalized. The geometric hypotheses
  are supplied by the surgery theorem; the conclusion is a 3-manifold
  topology statement.
  \end{proof}
\end{theorem}
```

---

## 九、Lean skeleton 样例

以下代码是 **skeleton 草案**，没有在这里本地运行；需要团队用 `lake env lean`、`#check`、`#find`、LeanSearch/Moogle/mathlib docs 校验 exact API。LeanSearch 支持自然语言检索 mathlib theorem，论文也说明其目标是让用户无需熟悉命名约定也能检索相关 theorem。([leansearch.net][11]) mathlib 社区博客也建议结合 docs、search engines、`exact?` 等方式检索 theorem。([leanprover-community.github.io][12])

### 9.1 Project root

```lean
-- Poincare/Main.lean
import Mathlib.Geometry.Manifold.PoincareConjecture

import Poincare.Topology.SimplyConnectedEndgame
import Poincare.MorganTian.Interface

noncomputable section
open scoped Manifold
open Metric

namespace Poincare
```

### 9.2 Dimension and sphere notation

```lean
-- Poincare/Foundation/Dimension3.lean
import Mathlib.Geometry.Manifold.PoincareConjecture

noncomputable section
open scoped Manifold
open Metric

namespace Poincare

local notation "ℝ³" => EuclideanSpace ℝ (Fin 3)
local notation "S³" =>
  Metric.sphere (0 : EuclideanSpace ℝ (Fin 4)) 1

end Poincare
```

### 9.3 Bundled closed smooth 3-manifold

```lean
-- Poincare/Foundation/ClosedSmooth3Manifold.lean
import Mathlib.Geometry.Manifold.PoincareConjecture

noncomputable section
open scoped Manifold

namespace Poincare

/--
A bundled compact smooth 3-manifold without boundary.
This is an engineering wrapper; final theorems should still expose mathlib-style typeclass statements.
-/
structure ClosedSmooth3Manifold where
  carrier : Type u
  instTopologicalSpace : TopologicalSpace carrier
  instT2Space : T2Space carrier
  instChartedSpace : ChartedSpace (EuclideanSpace ℝ (Fin 3)) carrier
  instSmooth :
    IsManifold (𝓘(ℝ, EuclideanSpace ℝ (Fin 3))) ∞ carrier
  instCompact : CompactSpace carrier

attribute [instance] ClosedSmooth3Manifold.instTopologicalSpace
attribute [instance] ClosedSmooth3Manifold.instT2Space
attribute [instance] ClosedSmooth3Manifold.instChartedSpace
attribute [instance] ClosedSmooth3Manifold.instSmooth
attribute [instance] ClosedSmooth3Manifold.instCompact

end Poincare
```

### 9.4 Pending theorem policy

```lean
-- Poincare/Foundation/Pending.lean
import Mathlib

namespace Poincare

/--
Project convention:
A theorem ending in `_interface` may use `sorry` only on the skeleton branch.
Every such theorem must have:
* source theorem,
* blueprint node,
* owner,
* replacement plan.
CI should fail on `sorry` for the main/no-sorry branch.
-/
def PendingInterface (statement : Prop) : Prop := statement

end Poincare
```

在外部项目里，长期不要用 `axiom`。开发期可用 `by
  sorry` 或 mathlib 的 `proof_wanted` 风格；但 CI 要明确区分 skeleton 分支和 no-sorry 分支。

### 9.5 Morgan–Tian interface

```lean
-- Poincare/MorganTian/Interface.lean
import Poincare.Foundation.ClosedSmooth3Manifold

noncomputable section
open scoped Manifold

namespace Poincare.MorganTian

structure Pi1FreeProductFiniteAndInfiniteCyclic
    (M : Type u) [TopologicalSpace M] : Prop where
  -- Placeholder: exact formulation requires group-theoretic free product API.
  witness : Prop

structure IsSphericalSpaceForm
    (M : Type u) [TopologicalSpace M] : Prop where
  witness : Prop

structure IsS2BundleOverS1
    (M : Type u) [TopologicalSpace M] : Prop where
  witness : Prop

inductive AllowedSummand
    (M : Type u) [TopologicalSpace M] : Prop
| spherical : IsSphericalSpaceForm M → AllowedSummand M
| s2bundle : IsS2BundleOverS1 M → AllowedSummand M

structure IsConnectedSumOfAllowedSummands
    (M : Type u) [TopologicalSpace M] : Prop where
  witness : Prop

/--
Morgan--Tian Theorem 0.1 as a first-stage interface.
Source: Morgan--Tian, Introduction, Theorem 0.1.
Replacement plan:
  long-time surgery + finite extinction + surgery topology.
-/
theorem classification_interface
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace (EuclideanSpace ℝ (Fin 3)) M]
    [IsManifold (𝓘(ℝ, EuclideanSpace ℝ (Fin 3))) ∞ M]
    [CompactSpace M] [ConnectedSpace M]
    (hπ : Pi1FreeProductFiniteAndInfiniteCyclic M) :
    IsConnectedSumOfAllowedSummands M := by
  sorry

end Poincare.MorganTian
```

### 9.6 Topology endgame

```lean
-- Poincare/Topology/SimplyConnectedEndgame.lean
import Poincare.MorganTian.Interface
import Mathlib.Geometry.Manifold.PoincareConjecture

noncomputable section
open scoped Manifold
open Metric

namespace Poincare.Topology

local notation "ℝ³" => EuclideanSpace ℝ (Fin 3)
local notation "S³" =>
  Metric.sphere (0 : EuclideanSpace ℝ (Fin 4)) 1

theorem simplyConnected_has_MT_group_hypothesis
    {M : Type u} [TopologicalSpace M] [SimplyConnectedSpace M] :
    Poincare.MorganTian.Pi1FreeProductFiniteAndInfiniteCyclic M := by
  -- A trivial group is a free product of an empty family.
  -- Exact proof depends on chosen free product encoding.
  sorry

theorem simplyConnected_morganTianConnectedSum_implies_sphere
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace ℝ³ M]
    [IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M]
    (hMT : Poincare.MorganTian.IsConnectedSumOfAllowedSummands M) :
    Nonempty (M ≃ₘ⟮3, 3⟯ S³) := by
  -- Pure topology/smooth endgame.
  sorry

theorem poincare_from_morgan_tian
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace ℝ³ M]
    [IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M] [ConnectedSpace M] :
    Nonempty (M ≃ₘ⟮3, 3⟯ S³) := by
  have hπ : Poincare.MorganTian.Pi1FreeProductFiniteAndInfiniteCyclic M :=
    simplyConnected_has_MT_group_hypothesis
  have hMT := Poincare.MorganTian.classification_interface (M := M) hπ
  exact simplyConnected_morganTianConnectedSum_implies_sphere hMT

end Poincare.Topology
```

### 9.7 Final replacement plan

最终要么直接在 mathlib theorem 下游证明同名 theorem 不可能，因为同名已存在；项目内可证明：

```lean
theorem poincare_three_smooth_project
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace ℝ³ M]
    [IsManifold (𝓘(ℝ, ℝ³)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M] :
    Nonempty (M ≃ₘ⟮3,3⟯ S³) := ...
```

然后向 mathlib PR 时替换 `proof_wanted SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three` 的证明体。

---

## 十、项目里程碑

### 0–12 个月：可审查 skeleton + 拓扑 endgame

| 项                     | 内容                                                                                                                            |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| deliverables          | Lean project compiles；blueprint web/pdf；final theorem statement 对齐 mathlib；Morgan–Tian theorem DAG；topology endgame interface |
| no-sorry gate         | `Foundation` 和一部分 `Topology` no-sorry；Ricci/Perelman/Surgery/Extinction 允许标注 pending                                          |
| expected PRs          | mathlib doc/API 小修；fundamental group helper lemmas；sphere notation helper；connected sum abstract API                          |
| upstream candidates   | `SimplyConnectedSpace` helper、sphere diffeo helper、group free product helper                                                  |
| staffing              | 1 Lean lead，1 3-topology lead，1 geometry analyst reviewer，2–4 Lean contributors                                               |
| verification criteria | `lake build` passes；blueprint graph generated；每个 pending theorem 有 source/owner/replacement plan                              |
| failure modes         | statement 设计太虚；connected sum encoding 返工；忽略 smooth/topological bridge                                                         |

### 1–3 年：3-manifold topology infrastructure

| 项                     | 内容                                                                                                                                  |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| deliverables          | connected sum API；fundamental group of connected sum；space-form and (S^2)-bundle abstract models；extinction-to-classification proof |
| no-sorry gate         | Topology 层多数 no-sorry；Ricci theorem 仍 interface                                                                                     |
| expected PRs          | connected sum definitions, sphere connected sum identity, basic van Kampen consequences                                             |
| staffing              | 3-topologist + algebraic topologist + Lean maintainers                                                                              |
| verification criteria | 在假设 MT0.1 interface 下完整证明 smooth Poincaré target                                                                                    |
| failure modes         | van Kampen 缺失导致基础拓扑爆炸；bundled/unbundled manifold API 不稳定                                                                            |

### 3–6 年：Riemannian/Ricci/Perelman core infrastructure

| 项                     | 内容                                                                                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| deliverables          | Riemannian curvature conventions；Ricci flow definitions；maximum principle interfaces/proofs；Shi estimates statement；L-length/reduced volume definitions |
| no-sorry gate         | Riemannian basic no-sorry；major PDE theorem interface                                                                                                   |
| upstream candidates   | curvature tensors, Levi-Civita, geodesic comparison, Riemannian compactness statements                                                                  |
| staffing              | geometric analysts + PDE formalization specialists + mathlib reviewers                                                                                  |
| verification criteria | curvature evolution equations typecheck; reduced volume statement accepted by experts                                                                   |
| failure modes         | PDE framework overgeneralized；曲率符号混乱；smooth tensor notation不可维护                                                                                         |

### 6–10 年：surgery + extinction replacement

| 项                     | 内容                                                                                                  |
| --------------------- | --------------------------------------------------------------------------------------------------- |
| deliverables          | surgery spacetime；controlled surgery；long-time existence；finite extinction；移除核心 interface           |
| no-sorry gate         | 逐步对 Surgery/Extinction 开启 no-sorry 子模块                                                              |
| upstream candidates   | Dini derivative calculus, minimal surface interfaces, geometric convergence                         |
| staffing              | 10+ 长期团队较现实；需要 Ricci flow/surgery 专家持续审查                                                            |
| verification criteria | MT0.3、MT0.4、MT0.1 interface 被真实 Lean theorem 替换                                                     |
| failure modes         | standard solution/κ-solution compactness太大；minimal disk/ramp analysis 延迟；surgery spacetime model 返工 |

---

## 十一、AI-assisted formalization 工作流

建议团队建立 8 类 agent，每类输出都必须转化为 GitHub issue 或 Lean PR，不允许直接信任 LLM 文本。

| Agent                   | 输入                                 | 输出                                                                  | 验证                         |
| ----------------------- | ---------------------------------- | ------------------------------------------------------------------- | -------------------------- |
| 文献解析 agent              | Morgan–Tian PDF、Kleiner–Lott notes | theorem/source map                                                  | 几何分析专家审                    |
| theorem statement agent | source theorem + mathlib API       | Lean statement sketch                                               | `lake env lean` + reviewer |
| mathlib search agent    | informal goal                      | LeanSearch/Moogle/docs/GitHub query report                          | citations + `#check`       |
| Lean skeleton agent     | statement table                    | `.lean` files with pending theorem                                  | CI compile                 |
| proof attempt agent     | small leaf lemma                   | Lean proof attempts                                                 | no-sorry local test        |
| adversarial audit agent | blueprint node                     | “statement too strong/assumptions missing/API hallucination” report | human approval             |
| CI repair agent         | failing build logs                 | minimal edits                                                       | CI rerun                   |
| expert review loop      | PR + source map                    | mathematical approval                                               | domain expert sign-off     |

检索流程：

```text
1. mathlib docs fuzzy search
2. LeanSearch natural-language query
3. Moogle semantic search
4. GitHub code search in mathlib4
5. local:
   #check
   #find
   #synth
   exact?
   apply?
   lake env lean Poincare/...
6. if still missing: create "API gap" issue
```

Moogle 和 LeanSearch 都是面向 mathlib4 的语义检索工具；LeanSearch 论文明确说明其目标是接受 informal query 并返回 relevant theorems。([Moogle.][13])

避免 hallucination 的规则：

1. LLM 生成的 theorem name 未经 `#check` 一律标为 `unverified`.
2. LLM 生成的数学 statement 必须有 source locator。
3. LLM 生成的 proof sketch 必须说明用了哪些已有 theorem。
4. 对 Ricci flow/surgery/extinction，不允许“standard argument”作为证明节点；必须展开。
5. 每个 PR 至少一名 Lean reviewer + 一名数学 reviewer。
6. 每周自动生成 pending theorem report。

---

## 十二、质量审查清单

| 类别                               | 审查问题                                                           |
| -------------------------------- | -------------------------------------------------------------- |
| mathematical fidelity            | 是否忠实于 Morgan–Tian/Perelman 路线？有没有偷换 theorem？                   |
| source traceability              | 每个节点是否有 theorem/chapter/page/source？                           |
| Lean statement fidelity          | Lean statement 是否等价于数学 statement，还是过强/过弱？                      |
| API feasibility                  | 当前 mathlib 是否支持相关对象？缺失是否标注？                                    |
| no hidden axioms                 | 是否有 `axiom`、不受控 `unsafe`、永久 `sorry`？                           |
| topology/smoothness consistency  | homeomorphism 与 diffeomorphism 是否混用？Moise bridge 是否明确？         |
| surgery topology consistency     | surgery 是否只沿 (S^2)？removed components 是否列全？                    |
| curvature convention consistency | Riemann/Ricci/scalar curvature 符号是否统一？                         |
| PDE regularity assumptions       | compactness、bounded curvature、completeness、time interval 是否写全？ |
| compactness/completeness         | Cheeger–Gromov/Hamilton compactness 条件是否完整？                    |
| noncollapsing scale              | κ-noncollapsed 的 scale、parabolic neighborhood 是否明确？            |
| canonical neighborhoods          | ε-neck、strong ε-neck、cap、C-component、round component 是否区分？     |
| extinction Dini derivative       | surgery time 的 lower semicontinuity 是否处理？                      |
| theorem dependency correctness   | DAG 中是否有循环或缺失前提？                                               |
| CI health                        | `lake build`、blueprint build、lint、no-sorry report 是否通过？        |
| onboarding clarity               | 新成员能否从 issue 找到 source、Lean file、acceptance criteria？          |

---

## 十三、风险矩阵

|  # | risk                                 | severity | early warning sign            | mitigation                                            | owner expertise       | first test theorem                          |
| -: | ------------------------------------ | -------: | ----------------------------- | ----------------------------------------------------- | --------------------- | ------------------------------------------- |
|  1 | mathlib 缺少 connected sum             |        高 | endgame 无法表达                  | 先 abstract predicate，后构造                              | 3-topology + Lean     | `connectedSum_sphere_identity`              |
|  2 | van Kampen 不可用                       |        高 | (\pi_1) connected sum 无法证明    | 先 interface；独立 algebraic topology 子项目                 | algebraic topology    | `pi1_connectedSum`                          |
|  3 | spherical space-form quotient API 缺失 |        高 | 无法排除非trivial quotient         | 抽象 `IsSphericalSpaceForm`                             | topology              | `simplyConnected_sphericalSpaceForm`        |
|  4 | Moise theorem 缺失                     |        中 | topological/smooth theorem 混淆 | 主线只做 smooth statement                                 | 3-manifold topology   | `homeomorph_to_diffeomorph_three_interface` |
|  5 | Riemannian curvature API 缺失          |       极高 | Ricci flow statement 无法写      | 项目内最小 curvature API                                   | differential geometry | `scalarCurvature_evolution_statement`       |
|  6 | 曲率符号约定混乱                             |       极高 | evolution equation 正负号冲突      | `CurvatureConventions.lean` 强制统一                      | geometric analysis    | constant curvature sphere test              |
|  7 | Ricci flow PDE existence 过大          |       极高 | short-time existence 卡住多年     | interface theorem，先做后续依赖 skeleton                     | PDE                   | `ricciFlow_shortTimeExistence_compact`      |
|  8 | generalized Ricci flow 建模错误          |       极高 | surgery spacetime 无法连接        | 先按 MT spacetime/horizontal metric 建 structure         | Ricci flow            | `ordinary_to_generalized`                   |
|  9 | surgery spacetime quotient 太复杂       |       极高 | typeclass/quotient 不可维护       | 先 data structure + regular part；避免早期 quotient-heavy   | Lean architecture     | `SurgerySpaceTime.regularPart`              |
| 10 | κ-solution compactness 难以形式化         |       极高 | canonical neighborhoods 无法替换  | interface 分层；先 Hamilton compactness                   | geometric analysis    | `kappaSolution_compactness_statement`       |
| 11 | reduced volume 需要 weak analysis      |       极高 | cut locus/measure zero 卡住     | 分离 measure theory lemma；先 compact smooth special case | analysis              | `reducedVolume_mono_smoothDomain`           |
| 12 | minimal disk existence 缺失            |       极高 | (W_2/W_3) 无法定义                | 先 interface；研究 harmonic maps/minimal surfaces         | geometric analysis    | `W2_defined_for_pi2`                        |
| 13 | curve shortening/ramp 技术太细           |       极高 | Chapter 19 无法分解               | 保持 Perelman route；单独 ramp 子项目                         | geometric analysis    | `ramp_curveShortening_regular`              |
| 14 | Lean 性能问题                            |       中高 | imports 慢、simp 爆炸             | 小文件、局部 simp、profile                                   | Lean engineer         | `lake build` timing                         |
| 15 | Blueprint 与 Lean 漂移                  |        高 | graph 节点对应不上 theorem          | LeanArchitect/CI 检查 `\lean`                           | project architect     | `blueprint_check`                           |
| 16 | statement 过强                         |        高 | 专家指出假设缺失                      | adversarial review before coding                      | all experts           | `MT03_statement_review`                     |
| 17 | 人员结构失衡                               |        高 | Lean 人多但数学审核少                 | 每个大节点配数学 owner                                        | PI/project lead       | weekly audit                                |
| 18 | 上游 PR 难合并                            |        中 | 私有 API 越堆越多                   | 早沟通 mathlib maintainers                               | Lean maintainer       | small upstream helper PR                    |

---

## 十四、第一批 30 个 GitHub issues

|  # | title                                              | purpose                   | files                                             | source                       | prerequisites | expected names                                          | acceptance criteria             | diff | owner              |
| -: | -------------------------------------------------- | ------------------------- | ------------------------------------------------- | ---------------------------- | ------------- | ------------------------------------------------------- | ------------------------------- | ---: | ------------------ |
|  1 | Verify exact mathlib Poincaré target               | 固定最终 theorem              | `Main.lean`                                       | mathlib `PoincareConjecture` | none          | `poincare_three_smooth_project`                         | `#check` 输出记录                   |    1 | Lean               |
|  2 | Set up Lake project and CI                         | 项目可构建                     | root                                              | Lake docs                    | none          | CI workflow                                             | `lake build` passes             |    1 | Lean infra         |
|  3 | Initialize leanblueprint                           | 生成 web/pdf/DAG            | `blueprint/`                                      | leanblueprint                | issue 2       | labels                                                  | `leanblueprint web` passes      |    2 | infra              |
|  4 | Create source map for MT Introduction              | theorem 0.1–0.5 定位        | `Blueprint/src/intro.tex`                         | MT intro                     | none          | `MT0_1` etc                                             | table reviewed                  |    2 | geometry           |
|  5 | Define pending theorem policy                      | 防止黑箱失控                    | `Foundation/Pending.lean`                         | project policy               | issue 2       | `PendingInterface`                                      | CI lists pending                |    2 | Lean               |
|  6 | Bundled closed smooth 3-manifold                   | 降低 typeclass 噪音           | `Foundation/ClosedSmooth3Manifold.lean`           | mathlib manifold             | issue 1       | `ClosedSmooth3Manifold`                                 | compiles                        |    2 | Lean               |
|  7 | Sphere (S^3) notation audit                        | 避免目标不一致                   | `Foundation/Dimension3.lean`                      | mathlib sphere               | issue 1       | `S³` local notation                                     | `#check` examples               |    1 | Lean               |
|  8 | Define MT classification interface                 | 顶层桥接                      | `MorganTian/Interface.lean`                       | MT Thm 0.1                   | issue 6       | `classification_interface`                              | compiles with pending           |    2 | topology           |
|  9 | Define allowed summand predicates                  | space-form/S²-bundle 抽象   | `Topology/*.lean`                                 | MT Thm 0.1                   | issue 8       | `IsSphericalSpaceForm`, `IsS2BundleOverS1`              | reviewer accepts                |    3 | topology           |
| 10 | Define connected-sum expression API                | endgame skeleton          | `Topology/ConnectedSum.lean`                      | MT proof after 0.4           | issue 9       | `ConnectedSumExpr`                                      | compiles                        |    3 | Lean/topology      |
| 11 | Prove finite-list connected sum induction lemma    | 分类向下归纳                    | `Topology/ExtinctionToClassification.lean`        | MT Cor 0.5 proof             | issue 10      | `extinction_to_connectedSumExpr`                        | no-sorry for list part          |    3 | Lean               |
| 12 | Fundamental group hypothesis from simply connected | trivial group case        | `Topology/SimplyConnectedEndgame.lean`            | algebraic topology           | issue 8       | `simplyConnected_has_MT_group_hypothesis`               | compiles; maybe pending         |    2 | algebraic topology |
| 13 | Space-form simply connected interface              | 排除非trivial quotient       | `Topology/SphericalSpaceForm.lean`                | MT Cor 0.2                   | issue 9       | `simplyConnected_sphericalSpaceForm`                    | statement reviewed              |    3 | topology           |
| 14 | S²-bundle not simply connected interface           | 排除 bundle 因子              | `Topology/SphereBundlesOverS1.lean`               | MT Thm 0.1                   | issue 9       | `not_simplyConnected_s2Bundle`                          | statement reviewed              |    3 | topology           |
| 15 | Connected sum of spheres identity interface/proof  | endgame 最后一步              | `Topology/ConnectedSum.lean`                      | 3-topology                   | issue 10      | `connectedSum_sphere_identity`                          | statement compiles              |    3 | topology           |
| 16 | Simply connected endgame theorem                   | Ricci-free 主成果            | `Topology/SimplyConnectedEndgame.lean`            | MT Cor 0.2                   | issues 11–15  | `simplyConnected_morganTianConnectedSum_implies_sphere` | proof skeleton compiles         |    4 | topology + Lean    |
| 17 | Prove `poincare_from_morgan_tian`                  | 顶层桥接                      | `Main.lean`                                       | MT 0.1 → Cor 0.2             | issue 16      | `poincare_from_morgan_tian`                             | compiles                        |    3 | Lean               |
| 18 | Riemannian conventions document                    | 固定符号                      | `Riemannian/CurvatureConventions.lean`, blueprint | MT Ch.1                      | none          | `CurvatureConvention`                                   | expert approved                 |    2 | geometry           |
| 19 | Ricci flow structure statement                     | PDE 层入口                   | `RicciFlow/Basic.lean`                            | MT Def.3.1                   | issue 18      | `RicciFlow`                                             | compiles/pending Ricci          |    4 | geometry+Lean      |
| 20 | Generalized Ricci flow structure                   | surgery 前置                | `RicciFlow/Generalized.lean`                      | MT Def.3.34–3.36             | issue 19      | `GeneralizedRicciFlow`                                  | ordinary RF embeds              |    4 | geometry           |
| 21 | L-length definitions                               | Perelman 层入口              | `Perelman/LLength.lean`                           | MT Def.6.2                   | issue 20      | `LLength`                                               | definition compiles             |    4 | geometry           |
| 22 | Reduced volume interface                           | noncollapse 前置            | `Perelman/ReducedVolume.lean`                     | MT Ch.6–8                    | issue 21      | `reducedVolume_monotone`                                | blueprint node                  |    5 | geometry           |
| 23 | κ-solution interface                               | canonical neighborhood 前置 | `Perelman/KappaSolution.lean`                     | MT Ch.9                      | issue 19      | `KappaSolution`                                         | statement reviewed              |    4 | geometry           |
| 24 | canonical neighborhood definitions                 | surgery geometry          | `Perelman/CanonicalNeighborhood.lean`             | MT intro/Ch.9/App            | issue 23      | `EpsilonNeck`, `CanonicalCap`                           | compiles                        |    4 | geometry           |
| 25 | surgery spacetime structure                        | surgery 主对象               | `Surgery/SurgerySpaceTime.lean`                   | MT Ch.14                     | issue 20      | `SurgerySpaceTime`                                      | statement reviewed              |    5 | geometry+Lean      |
| 26 | surgery topological effect interface               | MT0.3 拓扑输出                | `Topology/SurgeryTopology.lean`                   | MT §5.5                      | issue 25      | `surgery_topological_effect`                            | statement reviewed              |    4 | topology           |
| 27 | long-time surgery theorem interface                | MT0.3/15.9                | `Surgery/LongTimeExistence.lean`                  | MT Ch.15–17                  | issues 24–26  | `long_time_existence_with_surgery`                      | source map complete             |    5 | geometry           |
| 28 | Forward difference quotient API                    | extinction calculus       | `Extinction/ForwardDifference.lean`               | MT Ch.2 §7                   | none          | `ForwardDifferenceQuotient`                             | basic comparison lemma no-sorry |    3 | analysis           |
| 29 | finite extinction interface                        | MT0.4/18.1                | `Extinction/FiniteTimeExtinction.lean`            | MT Ch.18–19                  | issue 28      | `finite_time_extinction`                                | source map complete             |    5 | geometry           |
| 30 | Weekly blueprint audit script                      | 防漂移                       | `scripts/`                                        | LeanArchitect/CI             | issues 2–3    | `check_blueprint.py`                                    | reports stale nodes             |    3 | infra              |

---

## 十五、自我审计：adversarial review

### 15.1 可能过强的 statement

1. `ClosedSmooth3Manifold` bundled structure 可能与 mathlib manifold typeclass practice 不完全一致。应只作为内部工程包装，最终 theorem 用 unbundled style。
2. `IsSphericalSpaceForm` 若定义为 smooth quotient of (S^3) by finite group action，可能过早引入 quotient manifold API。第一版应保持 abstract predicate。
3. `Pi1FreeProductFiniteAndInfiniteCyclic` 若直接用 group free product，可能需要大量 group theory/van Kampen 基建。第一版可用 source-level predicate。
4. `simplyConnected_morganTianConnectedSum_implies_sphere` 若试图一次证明所有 3-topology 细节，会过大；应拆成 summand 排除、free product triviality、sphere identity 三组。
5. `long_time_existence_with_surgery` 的 statement 若包含全部 quantitative parameters，第一版会不可读；应先有 coarse statement，再逐步 refined。

### 15.2 最可能错误的 Lean API 假设

1. `IsManifold (𝓘(ℝ, ℝ³)) ∞ M` exact notation 需要本地 `#check`。
2. `M ≃ₘ⟮3,3⟯ S³` 的 dimension parameters exact elaboration 需要本地验证。
3. `ConnectedSpace M` 是否由 `SimplyConnectedSpace M` 自动推出，需本地 typeclass 查证；mathlib docs 表明 simply connected 有 path-connected 表征，但 instance 是否自动可用需验证。([leanprover-community.github.io][7])
4. `FundamentalGroup` API 的 basepoint independence 有现成 theorem，但 connected sum/van Kampen 未确认存在。([leanprover-community.github.io][10])
5. `RiemannianMetric`、Ricci curvature、Levi-Civita connection 在 mathlib 的成熟度不能假设；当前 docs 至少显示 Riemannian manifold basic 是 Prop-valued typeclass over tangent inner products and distance，但 Ricci flow 所需 curvature stack 要专项核查。([leanprover-community.github.io][8])

### 15.3 哪些数学路线可能不适合形式化

1. Morgan–Tian 的 Perelman loop-space minimal disk/ramp route虽然比 Colding–Minicozzi 避免 index-one critical points，但 Chapter 19 技术极细，形式化仍极难。
2. 直接形式化完整 Cheeger–Gromov compactness 可能过早，应先 statement 化并证明项目所需特例。
3. 直接构造 surgery spacetime 的 singular topology 可能会导致 Lean quotient/typeclass 复杂度爆炸；先采用 regular-part + transition data 的结构化模型更稳。
4. 直接形式化 Moise theorem 不应作为主线前置条件；先做 smooth Poincaré statement。

### 15.4 哪些节点应先改成 interface

必须 interface-first：

```text
ricciFlow_shortTimeExistence_compact
hamilton_tensor_maximum_principle
hamilton_ivey_pinching
shi_derivative_estimates
cheeger_gromov_compactness_smooth
reducedVolume_monotone
perelman_noncollapsing_with_surgery
kappaSolution_compactness
canonicalNeighborhood_theorem
standardSolution_exists_unique
surgery_on_delta_neck
long_time_existence_with_surgery
W2_forwardDifference_inequality
loopWidth_forwardDifference_inequality
finite_time_extinction
```

可以 early proof：

```text
poincare_from_morgan_tian
finite-list connected-sum expression induction
trivial group satisfies free-product hypothesis
abstract simply connected endgame, assuming summand π₁ facts
ForwardDifferenceQuotient comparison lemma
basic blueprint/CI synchronization
```

### 15.5 需要哪些专家复核

| 部分                                                   | Reviewer                                             |
| ---------------------------------------------------- | ---------------------------------------------------- |
| Theorem 0.1/0.3/0.4/0.5 source map                   | Ricci flow with surgery expert                       |
| finite extinction (W_2/W_3) route                    | geometric analyst familiar with Perelman third paper |
| connected sum/spherical space-form/S²-bundle endgame | 3-manifold topologist                                |
| Moise/topological-smooth bridge                      | low-dimensional topologist                           |
| Lean target and manifold notation                    | mathlib manifold maintainer                          |
| curvature convention and tensor definitions          | differential geometer + Lean tensor API expert       |
| blueprint/CI/no-sorry workflow                       | Lean project maintainer                              |

---

## 最重要的执行建议

第一版 Blueprint 不要追求“把 Ricci flow 证明写完”，而要在 3–6 个月内做到：

```text
1. mathlib final target 精确锁定；
2. Morgan–Tian Theorem 0.1/0.3/0.4/0.5 的 source-to-DAG 完成；
3. Lean skeleton 可编译；
4. topology endgame 在 interface 假设下推出 Poincaré；
5. 所有 pending theorem 均有 source、owner、risk、replacement plan；
6. blueprint web/pdf/DAG 与 Lean 声明同步；
7. 每周专家 audit，防止 statement 漂移。
```

庞加莱猜想形式化的第一性原则是：**先让最终 theorem、数学 DAG、Lean interfaces 和专家审查机制稳定下来；再逐层替换 interface theorem。** 这条路线最有可能把项目从宏大目标变成可持续推进的长期形式化工程。

[1]: https://github.com/PatrickMassot/leanblueprint "GitHub - PatrickMassot/leanblueprint: plasTeX plugin to build formalization blueprints. · GitHub"
[2]: https://terrytao.wordpress.com/2023/11/18/formalizing-the-proof-of-pfr-in-lean4-using-blueprint-a-short-tour/ "Formalizing the proof of PFR in Lean4 using Blueprint: a short tour | What's new"
[3]: https://github.com/ImperialCollegeLondon/FLT "GitHub - ImperialCollegeLondon/FLT: Ongoing Lean formalisation of the proof of Fermat's Last Theorem · GitHub"
[4]: https://github.com/hanwenzhu/LeanArchitect "GitHub - hanwenzhu/LeanArchitect: LeanArchitect extracts a blueprint directly from Lean source. · GitHub"
[5]: https://leanprover-community.github.io/mathlib4_docs/Mathlib/Geometry/Manifold/PoincareConjecture.html "Mathlib.Geometry.Manifold.PoincareConjecture"
[6]: https://raw.githubusercontent.com/leanprover-community/mathlib4/master/Mathlib/Geometry/Manifold/PoincareConjecture.lean "raw.githubusercontent.com"
[7]: https://leanprover-community.github.io/mathlib4_docs/Mathlib/AlgebraicTopology/FundamentalGroupoid/SimplyConnected.html "Mathlib.AlgebraicTopology.FundamentalGroupoid.SimplyConnected"
[8]: https://leanprover-community.github.io/mathlib4_docs/Mathlib/Geometry/Manifold/Riemannian/Basic.html "Mathlib.Geometry.Manifold.Riemannian.Basic"
[9]: https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/ "Lake"
[10]: https://leanprover-community.github.io/mathlib4_docs/Mathlib/AlgebraicTopology/FundamentalGroupoid/FundamentalGroup.html "Mathlib.AlgebraicTopology.FundamentalGroupoid.FundamentalGroup"
[11]: https://leansearch.net/ "Mathlib4 Search"
[12]: https://leanprover-community.github.io/blog/posts/searching-for-theorems-in-mathlib/ "Searching for Theorems in Mathlib | Lean community blog"
[13]: https://www.moogle.ai/?utm_source=chatgpt.com "Moogle: Semantic search over mathlib4"
