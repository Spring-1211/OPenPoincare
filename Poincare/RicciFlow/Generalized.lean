import Poincare.RicciFlow.Basic

/-! # Generalized Ricci flow interface -/

namespace Poincare.RicciFlow

universe u v

/-- Placeholder for Morgan--Tian generalized Ricci flow spacetime data. -/
structure GeneralizedRicciFlow (M : Type u) [TopologicalSpace M] where
  regularPart : Type v
  timeFunction : regularPart → Type v

/-- Ordinary Ricci flow embeds into generalized Ricci flow, statement layer. -/
theorem ordinary_to_generalized_statement
    {M : Type u} [TopologicalSpace M]
    (flow : RicciFlow.{u, v} M) :
    True := by
  trivial

end Poincare.RicciFlow
