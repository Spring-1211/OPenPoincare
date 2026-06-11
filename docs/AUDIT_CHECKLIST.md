# Quality audit checklist

## Mathematical fidelity

- [ ] Is the node faithful to Morgan--Tian/Perelman rather than a stronger or weaker theorem?
- [ ] Are connectedness, compactness, smoothness and boundary assumptions explicit?
- [ ] Are topological and smooth statements separated?
- [ ] Is Moise's theorem avoided as a prerequisite for the smooth main line?

## Lean statement fidelity

- [ ] Does `#check` verify every external declaration name?
- [ ] Are bundled wrappers used only internally?
- [ ] Does the final theorem expose mathlib-style typeclass assumptions?
- [ ] Are universe levels and manifold model spaces controlled?

## Ricci/surgery correctness

- [ ] Curvature signs match the convention file.
- [ ] Quantitative parameters are either explicit or deliberately abstracted.
- [ ] Surgery is along `S²`-necks only.
- [ ] Removed standard components are listed and tracked.
- [ ] Surgery times are locally finite.

## Interface governance

- [ ] Every `sorry` has a source locator.
- [ ] Every interface theorem has a replacement plan.
- [ ] No `axiom` has been introduced.
- [ ] No `unsafe` mathematical shortcut has been introduced.
- [ ] Blueprint labels and Lean declarations are synchronized.

## Review

- [ ] Lean reviewer approved statement syntax and imports.
- [ ] Domain expert approved mathematical statement.
- [ ] CI and pending-theorem scripts pass.
