import Poincare.Topology.AllowedSummands
import Poincare.Foundation.Pending

/-!
# Morgan--Tian classification interface

This module records the top-level classification theorem used to derive the
Poincaré conjecture. Its proof is replaced in stages by long-time Ricci flow with
surgery, finite-time extinction and surgery topology.
-/

noncomputable section

open scoped Manifold ContDiff

namespace Poincare.MorganTian

universe u

/--
Placeholder predicate: `π₁(M)` is a free product of finite groups and infinite
cyclic groups. The simply connected case is represented by the empty product.
-/
def Pi1FreeProductFiniteAndInfiniteCyclic
    (M : Type u) [TopologicalSpace M] : Prop := True

/--
Morgan--Tian Theorem 0.1 as a first-stage interface.

Source: Morgan--Tian, Introduction, Theorem 0.1.
Replacement plan: long-time surgery flow + finite-time extinction + topological
analysis of surgery/removal transitions.
-/
theorem classification_interface
    {M : Type u} [TopologicalSpace M] [T2Space M]
    [ChartedSpace Poincare.R3 M]
    [IsManifold (𝓘(ℝ, Poincare.R3)) ∞ M]
    [CompactSpace M] [ConnectedSpace M]
    (hπ : Pi1FreeProductFiniteAndInfiniteCyclic M) :
    Poincare.Topology.IsMorganTianConnectedSum M := by
  sorry

end Poincare.MorganTian
