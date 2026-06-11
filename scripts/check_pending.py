#!/usr/bin/env python3
"""Report pending proof markers in the Lean project.

This script scans Lean code while ignoring ordinary line comments and block
comments/docstrings. It reports `sorry`, `axiom`, `unsafe` and `proof_wanted`
occurrences. Use `--fail-on-sorry` for a no-sorry branch.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEAN_DIRS = [ROOT / "Poincare", ROOT / "examples"]
PATTERNS = {
    "sorry": re.compile(r"\bsorry\b"),
    "axiom": re.compile(r"\baxiom\b"),
    "unsafe": re.compile(r"\bunsafe\b"),
    "proof_wanted": re.compile(r"\bproof_wanted\b"),
}


def uncommented_lines(text: str):
    """Yield `(line_number, code_without_comments)` for Lean-ish source text."""
    depth = 0
    for lineno, raw in enumerate(text.splitlines(), start=1):
        i = 0
        out: list[str] = []
        while i < len(raw):
            if depth == 0 and raw.startswith("--", i):
                break
            if raw.startswith("/-", i):
                depth += 1
                i += 2
                continue
            if depth > 0:
                if raw.startswith("-/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
                continue
            out.append(raw[i])
            i += 1
        yield lineno, "".join(out)


def scan_file(path: Path):
    text = path.read_text(encoding="utf-8")
    original_lines = text.splitlines()
    for lineno, code in uncommented_lines(text):
        if not code.strip():
            continue
        for kind, pattern in PATTERNS.items():
            if pattern.search(code):
                yield kind, lineno, original_lines[lineno - 1].strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fail-on-sorry", action="store_true")
    args = parser.parse_args()

    counts = {kind: 0 for kind in PATTERNS}
    records = []
    for directory in LEAN_DIRS:
        if not directory.exists():
            continue
        for path in sorted(directory.rglob("*.lean")):
            for kind, lineno, line in scan_file(path):
                counts[kind] += 1
                records.append((kind, path.relative_to(ROOT), lineno, line))

    print("Pending theorem audit")
    print("=====================")
    for kind, count in counts.items():
        print(f"{kind:12s}: {count}")
    print()

    for kind, rel, lineno, line in records:
        print(f"{kind:12s} {rel}:{lineno}: {line}")

    if counts["axiom"] or counts["unsafe"] or counts["proof_wanted"]:
        print("\nERROR: axiom/unsafe/proof_wanted markers are not allowed in project source.")
        return 2
    if args.fail_on_sorry and counts["sorry"]:
        print("\nERROR: --fail-on-sorry requested and sorry markers were found.")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
