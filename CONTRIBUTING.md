# Contributing

## Contribution model

This repository is organized as a long-term formalization project. Every contribution should improve at least one of the following:

- mathematical fidelity to Morgan--Tian/Perelman;
- Lean statement accuracy;
- dependency graph quality;
- replacement of an interface theorem by a smaller theorem DAG;
- documentation, issue structure or CI.

## Pull request requirements

A PR touching mathematical statements must include:

1. source locator: book/paper/chapter/theorem/page or mathlib file path;
2. affected blueprint labels;
3. Lean declaration names changed or added;
4. list of new `sorry` occurrences, if any;
5. reviewer expertise requested.

A PR replacing `sorry` must include a note explaining whether downstream blueprint dependencies remain valid.

## Lean style

- Prefer small theorem statements over large monolithic theorems.
- Use bundled objects only to reduce engineering friction; final public statements should remain mathlib-style where possible.
- Avoid global notation unless it is project-wide and documented.
- Do not introduce `axiom` for mathematical facts.
- Keep imports as narrow as practical once the skeleton stabilizes.

## Review roles

| Area | Required reviewer |
|---|---|
| final target / manifold notation | mathlib manifold reviewer |
| Morgan--Tian source map | Ricci flow with surgery expert |
| topology endgame | 3-manifold topologist |
| curvature conventions | differential geometer |
| Ricci flow PDE | geometric analyst / PDE expert |
| blueprint/CI | Lean infrastructure maintainer |
