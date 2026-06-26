# Buffer Linear Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The **linear buffer discipline** over the `Buffer` namespace: contiguous, count-tracked heap storage with front/back access and append/remove, in two forms — a growable buffer and a fixed-capacity bounded buffer — both supporting noncopyable (`~Copyable`) elements.

---

## Quick Start

`Buffer.Linear` is a move-only (`~Copyable`) buffer that keeps its elements contiguous at slots `0 ..< count` and grows its heap backing automatically as you append. It is generic over its storage, so the element type appears inside the storage spelling — alias it once to keep call sites readable.

```swift
import Buffer_Linear_Primitives

// A growable, heap-backed buffer of Int. Alias the storage spelling once.
typealias IntBuffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear

var log = IntBuffer(minimumCapacity: 4)
log.append(1)
log.append(2)
log.append(3)
print(log.count)                  // 3

let head = log.peek.front         // 1 — read the front without removing
let tail = log.peek.back          // 3 — read the back without removing
_ = log.remove.last()             // 3 — remove and return the last element
print(log.count)                  // 2
```

Buffers can also be built declaratively with a result builder, which threads each element through a consuming append (so `~Copyable` elements compose too):

```swift
let evens = IntBuffer {
    2
    4
    6
}
```

The **bounded** variant fixes a maximum capacity. Appending to a full bounded buffer never traps and never grows — it hands the element back unappended, so the caller decides what to do:

```swift
var bounded = IntBuffer.Bounded(minimumCapacity: 2)
_ = bounded.append(1)             // nil — accepted
_ = bounded.append(2)             // nil — accepted
let rejected = bounded.append(3)  // 3 — at capacity, returned unappended
```

Both forms expose `count` / `capacity` / `isFull`, namespaced `peek` (`.front` / `.back`) and `remove` (`.first()` / `.last()` / `.all()`) accessors, in-place `replace` / `swap` / `truncate`, and a consuming `drain`. Copyable element buffers additionally conform to `Iterable` (multipass) and `Sequenceable` (single-pass), and the growable form offers `clone()` for an independent copy.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-buffer-linear-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        // The umbrella — the whole package.
        .product(name: "Buffer Linear Primitives", package: "swift-buffer-linear-primitives"),
        // …or depend on just the variant you use, e.g. the bounded form:
        // .product(name: "Buffer Linear Bounded Primitives", package: "swift-buffer-linear-primitives"),
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux toolchain).

---

## Architecture

Each variant ships as **two products**: a lean type module (the move-only value type plus the operations that touch its storage) and a conformances module (the `Iterable` / `Sequenceable` / drain conformances, kept separate so they never constrain noncopyable use). Importing `Buffer Linear Primitives` — the umbrella — brings in the whole package; importing a single variant module brings in just that variant.

| Product | Target | Purpose |
|---------|--------|---------|
| `Buffer Linear Primitive` | `Sources/Buffer Linear Primitive/` | The growable `Buffer.Linear` value type: heap-backed, auto-growing, with append/remove/replace/swap/truncate, peek, the result builder, and `clone()`. |
| `Buffer Linear Bounded Primitive` | `Sources/Buffer Linear Bounded Primitive/` | The fixed-capacity `Buffer.Linear.Bounded` value type: a hard capacity ceiling whose `append` returns the element when full. |
| `Buffer Linear Primitives` | `Sources/Buffer Linear Primitives/` | The umbrella: the growable conformances (`Iterable`, `Sequenceable`, drain) plus a re-export of every variant module. |
| `Buffer Linear Bounded Primitives` | `Sources/Buffer Linear Bounded Primitives/` | The bounded conformances (`Iterable`, `Sequenceable`, drain). |
| `Buffer Linear Primitives Test Support` | `Tests/Support/` | Re-exports the package for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
