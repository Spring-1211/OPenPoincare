import Poincare.Foundation.Dimension3

/-!
# `S²`-bundles over `S¹`

Morgan--Tian's classification permits the orientable and non-orientable
`S²`-bundles over `S¹`. The simply connected endgame must exclude both.
-/

noncomputable section

open scoped Manifold ContDiff

namespace Poincare.Topology

universe u

/-- The two diffeomorphism types of `S²`-bundles over `S¹`. -/
inductive S2BundleType where
  | orientable
  | nonorientable
  deriving Repr, BEq

/-- Placeholder predicate for being an `S²`-bundle over `S¹`. -/
def IsS2BundleOverS1 (M : Type u) [TopologicalSpace M] : Prop := True

/-- No `S²`-bundle over `S¹` is simply connected. -/
theorem not_simplyConnected_s2BundleOverS1
    {M : Type u} [TopologicalSpace M]
    [SimplyConnectedSpace M]
    (h : IsS2BundleOverS1 M) :
    False := by
  sorry

end Poincare.Topology
