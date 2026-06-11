import Poincare.MorganTian.Interface
import Poincare.Topology.SphericalSpaceForm
import Poincare.Topology.SphereBundlesOverS1
import Poincare.Topology.ConnectedSum

/-!
# Simply connected endgame

This is the Ricci-free topological bridge from the Morgan--Tian classification
interface to the smooth Poincaré target.
-/

noncomputable section

open scoped Manifold ContDiff

namespace Poincare.Topology

universe u

/-- A simply connected space is connected. Kept as an interface until the exact mathlib instance is audited. -/
theorem simplyConnected_connectedSpace
    {M : Type u} [TopologicalSpace M] [SimplyConnectedSpace M] :
    ConnectedSpace M := by
  sorry

/-- The trivial fundamental group satisfies the Morgan--Tian group hypothesis. -/
theorem simplyConnected_has_MT_group_hypothesis
    {M : Type u} [TopologicalSpace M] [SimplyConnectedSpace M] :
    Poincare.MorganTian.Pi1FreeProductFiniteAndInfiniteCyclic M := by
  trivial

/--
If a simply connected closed smooth 3-manifold is a Morgan--Tian connected sum,
then it is diffeomorphic to `S³`.
-/
theorem simplyConnected_morganTianConnectedSum_implies_sphere
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace Poincare.R3 M]
    [IsManifold (𝓘(ℝ, Poincare.R3)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M]
    (hMT : IsMorganTianConnectedSum M) :
    Nonempty (M ≃ₘ⟮3, 3⟯ Poincare.S3) := by
  sorry

/--
Smooth 3D Poincaré from the Morgan--Tian classification interface and the
simply connected endgame.
-/
theorem poincare_from_morgan_tian
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace Poincare.R3 M]
    [IsManifold (𝓘(ℝ, Poincare.R3)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M] :
    Nonempty (M ≃ₘ⟮3, 3⟯ Poincare.S3) := by
  letI : ConnectedSpace M := simplyConnected_connectedSpace (M := M)
  have hπ : Poincare.MorganTian.Pi1FreeProductFiniteAndInfiniteCyclic M :=
    simplyConnected_has_MT_group_hypothesis (M := M)
  have hMT : IsMorganTianConnectedSum M :=
    Poincare.MorganTian.classification_interface (M := M) hπ
  exact simplyConnected_morganTianConnectedSum_implies_sphere (M := M) hMT

end Poincare.Topology
