import Poincare.Extinction.RampSolutions
import Poincare.MorganTian.Interface

/-! # Finite-time extinction -/

namespace Poincare.Extinction

universe u

/-- Morgan--Tian finite-time extinction theorem interface. -/
theorem finite_time_extinction
    {M : Type u} [TopologicalSpace M]
    (hπ : Poincare.MorganTian.Pi1FreeProductFiniteAndInfiniteCyclic M) :
    True := by
  sorry

end Poincare.Extinction
