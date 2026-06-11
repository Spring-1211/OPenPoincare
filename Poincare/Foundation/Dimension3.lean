import Mathlib.Geometry.Manifold.PoincareConjecture

/-!
# Dimension-three conventions

This file centralizes the model space and sphere notation used by the project.
The final public theorem should continue to be audited against mathlib's own
notation in `Mathlib.Geometry.Manifold.PoincareConjecture`.
-/

noncomputable section

open scoped Manifold ContDiff
open Metric

namespace Poincare

/-- The Euclidean model space for smooth 3-manifolds. -/
abbrev R3 : Type := EuclideanSpace ℝ (Fin 3)

/-- The unit 3-sphere, represented as the metric sphere in `ℝ^4`. -/
abbrev S3 : Type := Metric.sphere (0 : EuclideanSpace ℝ (Fin 4)) (1 : ℝ)

scoped notation "ℝ³" => R3
scoped notation "S³" => S3

end Poincare
