import Mathlib

/-!
# Project conventions

These declarations are intentionally lightweight. They are metadata carriers for
project governance and should not be used as mathematical shortcuts.
-/

namespace Poincare

/-- Human-readable identifier of a blueprint node. -/
abbrev BlueprintLabel := String

/-- Human-readable locator for a theorem, definition, chapter, page or mathlib file. -/
structure SourceLocator where
  source : String
  pointer : String
  deriving Repr, BEq

/-- Risk level used in issue triage and interface theorem records. -/
inductive RiskLevel where
  | low
  | medium
  | high
  | extreme
  deriving Repr, BEq

/-- Metadata required for an interface theorem that temporarily contains `sorry`. -/
structure PendingTheoremRecord where
  leanName : String
  blueprintLabel : BlueprintLabel
  source : SourceLocator
  ownerExpertise : String
  risk : RiskLevel
  replacementPlan : String
  deriving Repr

end Poincare
