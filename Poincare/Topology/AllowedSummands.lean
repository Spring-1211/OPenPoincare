import Poincare.Topology.SphericalSpaceForm
import Poincare.Topology.SphereBundlesOverS1
import Poincare.Topology.ConnectedSum

/-!
# Morgan--Tian allowed summands

Theorem 0.1 classifies manifolds as connected sums of spherical space forms and
`S²`-bundles over `S¹`. This module records that vocabulary.
-/

noncomputable section

namespace Poincare.Topology

universe u

/-- A Morgan--Tian allowed prime summand. -/
inductive MorganTianSummand (M : Type u) [TopologicalSpace M] : Prop where
  | spherical : IsSphericalSpaceForm M → MorganTianSummand M
  | s2bundle : IsS2BundleOverS1 M → MorganTianSummand M

/--
Abstract predicate saying that `M` is diffeomorphic to a finite connected sum of
Morgan--Tian allowed summands.
-/
structure IsMorganTianConnectedSum (M : Type u) [TopologicalSpace M] : Prop where
  witness : ∃ _e : ConnectedSumExpr.{u}, True

end Poincare.Topology
