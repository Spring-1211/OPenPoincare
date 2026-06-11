import Poincare.Foundation.ProjectConventions

/-!
# Curvature conventions

All Ricci-flow statements must explicitly reference this convention layer before
being treated as mathematically reviewed.
-/

namespace Poincare.Riemannian

/-- Human-readable curvature-sign convention record. -/
structure CurvatureConvention where
  riemannTensorSign : String
  ricciTraceConvention : String
  scalarCurvatureConvention : String
  deriving Repr, BEq

/-- Morgan--Tian style convention placeholder. -/
def morganTianConvention : CurvatureConvention where
  riemannTensorSign := "R(X,Y)Z = ∇_X∇_Y Z - ∇_Y∇_X Z - ∇_[X,Y] Z"
  ricciTraceConvention := "Ric is the trace of the Riemann curvature tensor in the first and third slots"
  scalarCurvatureConvention := "Scalar curvature is the trace of Ric"

/-- Audit theorem marking that the convention has been fixed for downstream statements. -/
theorem curvatureConvention_MT : True := by
  trivial

end Poincare.Riemannian
