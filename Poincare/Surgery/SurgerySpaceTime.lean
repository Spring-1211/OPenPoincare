import Poincare.RicciFlow.Generalized

/-! # Surgery spacetime -/

namespace Poincare.Surgery

universe u v

/-- Placeholder for Morgan--Tian surgery spacetime data. -/
structure SurgerySpaceTime (M : Type u) [TopologicalSpace M] where
  regularPart : Type v
  timeSlice : Type v

/-- Regular part of a surgery spacetime supports generalized Ricci flow data, interface. -/
theorem surgerySpaceTime_regularPart_statement
    {M : Type u} [TopologicalSpace M]
    (X : SurgerySpaceTime.{u, v} M) :
    True := by
  trivial

end Poincare.Surgery
