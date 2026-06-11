import Poincare.Foundation.ProjectConventions

/-!
# Pending theorem policy

The project permits `sorry` only for explicitly tracked interface theorems on the
skeleton branch. The declaration below is not an axiom and does not prove any
mathematics; it is a marker used by documentation and scripts.
-/

namespace Poincare

/-- Marker for a proposition that is currently represented by an interface theorem. -/
def PendingInterface (statement : Prop) : Prop := statement

/-- A small helper for documenting that a completed proof discharges a pending interface. -/
theorem pendingInterface_of {p : Prop} (h : p) : PendingInterface p := h

end Poincare
