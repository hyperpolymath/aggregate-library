<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

A **methods** repository: demonstrating how to specify, test, and
stress-test a tiny “overlap” library across wildly different systems —
without implying that any one ecosystem should replace its standard
library.

<div id="toc">

</div>

# Status

Experimental / research / demonstration.

# What this repo is

This repository is a **stress-test and methods lab** for aLib.

It exists to demonstrate:

- How to identify a minimal overlap (“common”) between systems with very
  different constraints.

- How to express that overlap as:

  - a stable spec surface,

  - semantics notes,

  - and a conformance test suite.

- How “reversibility” and “safe iteration” can be enforced through
  disciplined boundaries and test vectors.

This repo is intentionally allowed to be “weird” and “extreme” because
its job is to break ideas early.

> [!NOTE]
> The “overlap” demonstrated here is intentionally chosen for
> stress-testing across **very different** designs. It is an
> illustrative demo of method under extreme diversity — not a claim that
> any ecosystem should adopt this overlap as its standard library.

# What this repo is NOT

To avoid confusion:

- Not a replacement for any ecosystem’s standard library.

- Not a proposal that “all languages should share one stdlib.”

- Not a claim that the overlap shown here is the “correct” overlap for
  all projects.

- Not a dependency that downstream implementations must import.

This repo demonstrates a method. Implementations may borrow the method,
not the code.

# Two meanings of “Common”

In the aLib universe there are two different “common” ideas:

<div>

<div class="title">

Overlap Common (this repo)

</div>

A demonstration overlap chosen to be stress-tested against extreme
diversity.

</div>

<div>

<div class="title">

Ecosystem Common (implementation repos)

</div>

A practical shared layer for a specific ecosystem (example: AffineScript +
Melange + optional runtime validation).

</div>

This repo covers only the first meaning.

# Reference implementations and optional consumers

Some projects may serve as **reference points** for semantics,
verification approaches, or ecosystem-specific implementations.

These relationships are **optional** and **non-binding**:

- `proven` — a reference implementation that can inform semantics intent
  and verification style (not required).

- `alib-for-affinescript` — an ecosystem implementation proving ground
  (AffineScript/Melange) that applies the aLib method (not required).

- Implementation support repos (optional): conformance runners,
  codemods, interop pattern cookbooks.

This repo should not become a “dependency magnet”; implementation repos
should be able to adopt the method without importing code from here.

# AffineScript faces — the extension layer

aLib also serves as the **extension layer** over the AffineScript face
family. AffineScript is one canonical cube presented through six faces
(RattleScript, JaffaScript, PseudoScript, LucidScript, CafeScripto, and
the canonical face); implementing an aLib operation **once** in
canonical AffineScript conforms it for all six faces at the library
level, because the faces are surface sugar that lower to that one
definition. This pairs the **library** same-cube guarantee (aLib
conformance vectors) with the **syntax** same-cube guarantee (the
`invariant-path` `faces` profile) — the same canonical artefact,
grounded on two axes.

- Conformer:
  [`src/affinescript/ALib.affine`](src/affinescript/ALib.affine) — all
  29 operations, with an affine-typed collection group that makes
  AffineScript a **stronger** conformer than a GC’d reference.

- The argument + a faces gallery (one operation across all six faces):
  [`docs/EXTENSION-LAYER.adoc`](docs/EXTENSION-LAYER.adoc).

# Design principles

- Minimal surfaces, explicit semantics.

- Conformance tests as the safety net.

- Reversibility: changes must be easy to evaluate and to undo.

- Ecosystem neutrality: no “blessed” implementation.

# Composition Guide

This repository demonstrates the extraction of universal patterns from
the intersection of multiple language stlibs (Phronesis, Rust, Haskell),
choosing the best implementation for each pattern.

See <a href="COMPOSITION-GUIDE.md" class="md">COMPOSITION-GUIDE</a> for
the complete methodology:

    aggregate-library = (common elements of phronesis stdlib ∩ Rust stdlib ∩ Haskell stdlib)
                      ∪ (compiler utilities)

This creates a **leaner library** with **no duplication** - a single
source of truth for universal patterns.

## stdlib-merger Tool

An automated tool for extracting common patterns from multiple stlibs is
available in `tools/stdlib-merger/`.

```bash
cd tools/stdlib-merger
julia cli.jl merge \
  --stdlib phronesis:/path/to/phronesis/stdlib \
  --stdlib rust:/path/to/rust/std \
  --stdlib haskell:/path/to/haskell/base \
  --output ../../lib/aggregate_library
```

See [stdlib-merger README](tools/stdlib-merger/README.md) and
[ARCHITECTURE](tools/stdlib-merger/ARCHITECTURE.md) for details.

# Contents

Current implementation demonstrates:

- `lib/aggregate_library/` — Universal stdlib patterns (Result,
  Collections, FileIO, Stream, Time)

- `lib/a_lib/` — Compiler utilities (Token, Position, Error,
  AST.Traversal, StringUtils, ColorOutput)

- `specs/` — Specifications (arithmetic, comparison, logical,
  collection, string operations)

- `scripts/` — Validation tools (Deno)

- `COMPOSITION-GUIDE.md` — Detailed methodology and integration examples

# How to use this repo

- Read the spec and the design notes.

- Use conformance vectors to validate an implementation in your
  ecosystem.

- Borrow the method for building your own proving-ground library.

# Contributing

Contributions should optimize for:

- clarity of the overlap definition,

- stronger tests,

- stronger reversibility discipline,

- and reduced ambiguity.

If you are proposing new surface area, you must also propose:

- semantics notes, and

- tests that make regressions obvious.

# License

PLMP-1.0.0-or-later
