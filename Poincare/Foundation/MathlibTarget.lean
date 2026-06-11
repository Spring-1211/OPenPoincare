import Poincare.Foundation.Dimension3

/-!
# mathlib target audit

This file deliberately contains `#check` commands. Its purpose is to fail fast if
mathlib renames the upstream target or changes the expected manifold notation.
-/

noncomputable section

open scoped Manifold ContDiff

#check SimplyConnectedSpace.nonempty_homeomorph_sphere_three
#check SimplyConnectedSpace.nonempty_sdiffeomorph_sphere_three
