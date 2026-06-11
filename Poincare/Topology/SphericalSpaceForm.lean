import Poincare.Foundation.Dimension3

/-!
# Spherical space forms

First-stage design: `IsSphericalSpaceForm` is an abstract predicate. A later
replacement should model quotients of `S³` by finite free actions and prove the
fundamental group calculation needed by the simply connected endgame.
-/

noncomputable section

open scoped Manifold ContDiff

namespace Poincare.Topology

universe u

/-- Placeholder predicate for closed 3-dimensional spherical space forms. -/
def IsSphericalSpaceForm (M : Type u) [TopologicalSpace M] : Prop := True

/--
A simply connected spherical space form is diffeomorphic to `S³`.

Source: Morgan--Tian Corollary 0.2(a), reduced to the standard fact that
`π₁(S³/Γ) ≃ Γ` for a finite free action.
-/
theorem simplyConnected_sphericalSpaceForm_diffeomorphic_sphere
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace Poincare.R3 M]
    [IsManifold (𝓘(ℝ, Poincare.R3)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M]
    (h : IsSphericalSpaceForm M) :
    Nonempty (M ≃ₘ⟮3, 3⟯ Poincare.S3) := by
  sorry

end Poincare.Topology
