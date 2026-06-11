import Poincare.Foundation.All
import Poincare.Topology.All
import Poincare.MorganTian.All
import Poincare.Riemannian.All
import Poincare.RicciFlow.All
import Poincare.Perelman.All
import Poincare.Surgery.All
import Poincare.Extinction.All

/-!
# Main project theorem

This file exposes the project-level version of the smooth three-dimensional
Poincaré conjecture target. The theorem currently depends on explicit interface
statements that are tracked in the blueprint.
-/

noncomputable section

open scoped Manifold ContDiff

namespace Poincare

universe u

/--
Project-level smooth three-dimensional Poincaré statement.

This is intended to track mathlib's
`SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three` declaration.
-/
theorem poincare_three_smooth_project
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace R3 M]
    [IsManifold (𝓘(ℝ, R3)) ∞ M]
    [CompactSpace M] [SimplyConnectedSpace M] :
    Nonempty (M ≃ₘ⟮3, 3⟯ S3) := by
  exact Poincare.Topology.poincare_from_morgan_tian (M := M)

/-- A trivial marker theorem used by CI and documentation checks. -/
theorem project_skeleton_loaded : True := by
  trivial

end Poincare
