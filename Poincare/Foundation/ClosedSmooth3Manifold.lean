import Poincare.Foundation.Dimension3

/-!
# Bundled closed smooth 3-manifolds

This wrapper is an engineering convenience for internal APIs. Public theorems
should prefer mathlib's usual unbundled typeclass style whenever possible.
-/

noncomputable section

open scoped Manifold ContDiff

namespace Poincare

universe u

/-- A compact smooth 3-manifold without boundary, bundled as a single object. -/
structure ClosedSmooth3Manifold where
  carrier : Type u
  [topologicalSpace : TopologicalSpace carrier]
  [t2Space : T2Space carrier]
  [chartedSpace : ChartedSpace R3 carrier]
  [smooth : IsManifold (𝓘(ℝ, R3)) ∞ carrier]
  [compactSpace : CompactSpace carrier]

attribute [instance] ClosedSmooth3Manifold.topologicalSpace
attribute [instance] ClosedSmooth3Manifold.t2Space
attribute [instance] ClosedSmooth3Manifold.chartedSpace
attribute [instance] ClosedSmooth3Manifold.smooth
attribute [instance] ClosedSmooth3Manifold.compactSpace

end Poincare
