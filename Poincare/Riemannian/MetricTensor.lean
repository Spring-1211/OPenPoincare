import Poincare.Foundation.Dimension3

/-! # Riemannian metric tensor interface -/

namespace Poincare.Riemannian

universe u

/-- Placeholder structure for a smooth Riemannian metric on a manifold. -/
structure SmoothRiemannianMetric (M : Type u) [TopologicalSpace M] where
  description : String := "smooth positive definite metric tensor"
  deriving Repr

/-- Source-level interface for metric tensors on closed smooth 3-manifolds. -/
theorem ContMDiffMetric_statement
    {M : Type u} [TopologicalSpace M] :
    True := by
  sorry

end Poincare.Riemannian
