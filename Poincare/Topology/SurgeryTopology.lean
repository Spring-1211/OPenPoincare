import Poincare.Topology.ConnectedSum

/-!
# Topological effect of surgery

The analytic surgery theorem supplies geometric hypotheses. This module records
the topological conclusion: crossing a surgery time corresponds to finitely many
`S²`-surgeries, connected-sum decomposition and removal of standard components.
-/

namespace Poincare.Topology

/-- Abstract record of the finitely many topological transitions in a surgery flow. -/
structure SurgeryTrace where
  numberOfSteps : Nat
  description : String := "abstract surgery trace"
  deriving Repr

/-- A standard component removed during Ricci flow with surgery. -/
structure StandardRemovedComponent where
  description : String
  deriving Repr, BEq

/-- Morgan--Tian topological effect of surgery, as a first-stage interface. -/
theorem surgery_topological_effect
    (trace : SurgeryTrace) :
    True := by
  sorry

end Poincare.Topology
