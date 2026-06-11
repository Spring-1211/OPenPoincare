import Poincare.Topology.SurgeryTopology
import Poincare.Topology.AllowedSummands

/-!
# From finite extinction to connected-sum classification

Once the flow becomes extinct and each surgery transition has the correct
3-topological effect, the original manifold is recovered by a finite backward
induction over the surgery/removal trace.
-/

namespace Poincare.Topology

universe u

/-- Abstract finite-extinction certificate for the topological induction. -/
structure ExtinctionCertificate where
  numberOfSurgerySteps : Nat
  deriving Repr, BEq

/-- The finite-list part of the backward induction is already no-sorry. -/
theorem backward_induction_over_surgery_steps
    {P : Nat → Prop}
    (h0 : P 0)
    (hstep : ∀ n, P n → P (n + 1)) :
    ∀ n, P n := by
  intro n
  induction n with
  | zero => exact h0
  | succ n ih => simpa [Nat.succ_eq_add_one] using hstep n ih

/-- Interface theorem: finite extinction plus surgery topology implies classification. -/
theorem extinction_to_connected_sum_classification
    {M : Type u} [TopologicalSpace M]
    (cert : ExtinctionCertificate) :
    IsMorganTianConnectedSum M := by
  sorry

end Poincare.Topology
