import Poincare.Riemannian.All

/-!
# Ricci flow basics

This is a statement layer, not a full PDE formalization.
-/

namespace Poincare.RicciFlow

universe u v

/-- Placeholder structure for a Ricci flow on a topological carrier. -/
structure RicciFlow (M : Type u) [TopologicalSpace M] where
  time : Type v
  metricAt : time → Type v

/-- Compact short-time existence interface. -/
theorem ricciFlow_shortTimeExistence_compact
    {M : Type u} [TopologicalSpace M] [CompactSpace M] :
    Nonempty (RicciFlow.{u, u} M) := by
  sorry

end Poincare.RicciFlow
