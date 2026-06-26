# ``Buffer_Linear_Primitives``

The linear buffer discipline over `Buffer` — growable, bounded, inline, and
small-buffer-optimized contiguous storage for noncopyable elements.

## Overview

`Buffer.Linear` is contiguous, count-tracked storage with front/back element access and
append/remove operations. It comes in four capacity flavours that share one API and all support
noncopyable (`~Copyable`) element types:

- **`Buffer.Linear`** — heap-backed and growable.
- **`Buffer.Linear.Bounded`** — heap-backed with a fixed maximum capacity.
- **`Buffer.Linear.Inline<n>`** — fixed inline storage, no heap allocation.
- **`Buffer.Linear.Small<n>`** — small-buffer optimization: inline until it overflows, then spills to the heap.

Importing `Buffer_Linear_Primitives` brings in every variant. A consumer that needs only one
variant imports that variant's module directly — for example `Buffer_Linear_Small_Primitives`.

```swift
import Buffer_Linear_Primitives

var small = Buffer<Storage<Int>.Heap>.Linear.Small<4>()
for value in 1...5 { small.append(value) }   // the 5th append spills to the heap
let spilled = small.isSpilled                 // true
```

## Topics

### Scope

- <doc:Buffer-Linear-Scope>
