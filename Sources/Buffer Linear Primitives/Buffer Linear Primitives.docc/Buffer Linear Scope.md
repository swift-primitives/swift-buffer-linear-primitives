# Buffer Linear Primitives — Scope

What this package is, and what it deliberately leaves to its siblings.

## Overview

`swift-buffer-linear-primitives` provides the **linear buffer discipline** over the `Buffer`
namespace: contiguous, count-tracked storage with front/back element access and append/remove
operations. It defines ``Buffer/Linear`` and its capacity variants:

- ``Buffer/Linear`` — heap-backed and growable.
- `Buffer.Linear.Bounded` — heap-backed with a fixed maximum capacity.
- `Buffer.Linear.Inline` — fixed inline storage, no heap allocation.
- `Buffer.Linear.Small` — small-buffer optimization: inline storage that spills to the heap on overflow.

It is one specialized buffer discipline among siblings — ring, slab, linked, slots, arena,
aligned, unbounded — each its own package. Every variant supports noncopyable (`~Copyable`)
element types.

## Module shape

Each variant ships as **two modules**:

- A **type module** (`Buffer Linear …​ Primitive`, singular) — the lean `~Copyable` value type
  together with the operations that touch its storage internals. Those operations are
  `@usableFromInline internal` and live next to the storage so they remain inlinable across
  package boundaries.
- A **conformances module** (`Buffer Linear …​ Primitives`, plural) — the `Copyable`-requiring
  protocol conformances (`Sequence`, `Collection`, `Sequence.Drain`, `Span.Protocol`),
  kept in their own module so they never constrain the type's noncopyable support.

`Buffer Linear Primitives` is both the base conformances module and the package umbrella:
`import Buffer_Linear_Primitives` brings in the whole package, while a consumer who needs only
one variant imports that variant's module directly.

> This two-module shape is a structural choice — co-locating internal operations with their
> storage is a standard-library-grade technique for keeping a public type lean while its
> operations stay inlinable. It is not a workaround for any compiler defect.

## Core targets

| Module | Form | Holds |
|--------|------|-------|
| `Buffer Linear Primitive` | type | `Buffer.Linear`, `Buffer.Linear.Inline`, `.Header`, `.Builder`, internal ops |
| `Buffer Linear Bounded Primitive` | type | `Buffer.Linear.Bounded`, internal ops |
| `Buffer Linear Small Primitive` | type | `Buffer.Linear.Small`, internal ops |
| `Buffer Linear Primitives` | conformances + umbrella | base conformances; re-exports every variant |
| `Buffer Linear Bounded Primitives` | conformances | `Bounded` conformances |
| `Buffer Linear Inline Primitives` | conformances | `Inline` conformances |
| `Buffer Linear Small Primitives` | conformances | `Small` conformances |

## Out of scope

| Capability | Belongs in |
|------------|------------|
| Other buffer disciplines (ring, slab, linked, slots, arena) | `swift-buffer-{ring,slab,linked,slots,arena}-primitives` |
| Aligned and unbounded buffer forms | `swift-buffer-aligned-primitives`, `swift-buffer-unbounded-primitives` |
| The `Buffer` namespace and capacity-growth vocabulary | `swift-buffer-primitives` |
| Raw heap and inline storage substrate | `swift-storage-primitives` |
| Indices, offsets, and counts | `swift-index-primitives` |

## Evaluation rule

Additions are evaluated against this scope. A buffer form that is not the *linear* discipline
extracts to its own sibling package rather than growing this one. A new operation belongs here
only if it operates *on* a linear buffer; storage, growth, and indexing concerns delegate to the
packages above.
