import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive

// MARK: - Copyable-element features for Buffer.Linear
//
// CoW (`ensureUnique`) is withdrawn at the storage tier (W2): `Storage.Contiguous` is unconditionally
// `~Copyable` with an explicit `copy()`, so `Buffer.Linear` is move-only and the former CoW-safe
// mutation/subscript shadows are removed (R1 — the non-CoW surface serves Copyable elements too).
// What remains here is genuinely Copyable-only and CoW-free: peek-by-value.

// MARK: - Peek Operations (read-only, by value — requires Copyable)

extension Property.Borrow.Typed
where
    Tag == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear.Peek,
    Base == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear,
    Element: Copyable
{
    /// Returns the first element without removing it.
    @inlinable
    public var front: Element {
        base.value.storage[.zero]
    }

    /// Returns the last element without removing it.
    @inlinable
    public var back: Element {
        return base.value.storage[base.value.header.count.subtract.saturating(.one).map(Ordinal.init)]
    }
}
