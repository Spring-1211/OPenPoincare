#!/usr/bin/env python3
"""Best-effort blueprint-to-Lean declaration drift check.

This does not replace `leanblueprint checkdecls`; it is a lightweight text-level
check that can run before the Lean project has been fully built.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BLUEPRINT = ROOT / "blueprint" / "src"
LEAN_ROOT = ROOT / "Poincare"
ALLOW_PREFIXES = (
    "SimplyConnectedSpace.",
    "ContinuousMap.",
)

LEAN_REF = re.compile(r"\\lean\{([^}]*)\}")
DECL = re.compile(r"^\s*(?:noncomputable\s+)?(?:theorem|lemma|def|abbrev|structure|inductive)\s+([A-Za-z0-9_'.]+)", re.MULTILINE)
NAMESPACE = re.compile(r"^\s*namespace\s+([A-Za-z0-9_'.]+)", re.MULTILINE)


def blueprint_refs() -> set[str]:
    refs: set[str] = set()
    for path in BLUEPRINT.rglob("*.tex"):
        text = path.read_text(encoding="utf-8")
        for match in LEAN_REF.finditer(text):
            for item in match.group(1).split(','):
                name = item.strip()
                if name:
                    refs.add(name)
    return refs


def lean_decls() -> set[str]:
    names: set[str] = set()
    for path in LEAN_ROOT.rglob("*.lean"):
        text = path.read_text(encoding="utf-8")
        namespaces = NAMESPACE.findall(text)
        current_ns = namespaces[-1] if namespaces else "Poincare"
        for match in DECL.finditer(text):
            local = match.group(1)
            if local.startswith("Poincare."):
                names.add(local)
            else:
                names.add(f"{current_ns}.{local}")
                names.add(local)
    return names


def main() -> int:
    refs = blueprint_refs()
    decls = lean_decls()
    missing = []
    for ref in sorted(refs):
        if ref.startswith(ALLOW_PREFIXES):
            continue
        if ref not in decls:
            missing.append(ref)
    print("Blueprint declaration audit")
    print("===========================")
    print(f"blueprint refs : {len(refs)}")
    print(f"Lean decls     : {len(decls)}")
    if missing:
        print("\nMissing project declarations:")
        for name in missing:
            print(f"  - {name}")
        return 1
    print("\nAll project-local blueprint references were found textually.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
