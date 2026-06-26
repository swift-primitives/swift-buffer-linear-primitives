import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive
import Storage_Protocol_Primitives

// MARK: - Copyable-element features for Buffer.Linear.Bounded
//
// CoW (`ensureUnique`) is withdrawn at the storage tier (W2): `Storage.Contiguous` is
// unconditionally `~Copyable` with an explicit `copy()`, so `Buffer.Linear.Bounded` is move-only and
// the former CoW-safe mutation/subscript shadows are removed (R1 — the non-CoW surface in
// `+Lifecycle` / `+Subscript` serves Copyable elements too). What remains here is genuinely
// Copyable-only and CoW-free: peek-by-value and array initialization.

// MARK: - Peek Operations (read-only, by value — requires Copyable)

extension Property.Borrow.Typed
where
    Tag == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear.Peek,
    Base == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear.Bounded,
    Element: Copyable
{
    /// Returns the first element without removing it.
    ///
    /// - Precondition: The buffer is not empty.
    @inlinable
    public var front: Element {
        base.value.storage[.zero]
    }

    /// Returns the last element without removing it.
    ///
    /// - Precondition: The buffer is not empty.
    @inlinable
    public var back: Element {
        return base.value.storage[base.value.header.count.subtract.saturating(.one).map(Ordinal.init)]
    }
}

// MARK: - Array Initialization

extension Buffer.Linear.Bounded where S: ~Copyable {

    /// Creates a bounded linear buffer populated with the given elements.
    ///
    /// - Parameters:
    ///   - elements: The elements to populate the buffer with.
    ///   - capacity: The fixed capacity for the buffer.
    /// - Throws: ``Error/capacityExceeded`` if `elements.count` exceeds `capacity`.
    @inlinable
    public init<E>(_ elements: [E], capacity: UInt) throws(Self.Error) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        guard elements.count <= Int(capacity) else { throw .capacityExceeded }
        var buffer = Self(minimumCapacity: .init(Cardinal(capacity)))
        for element in elements {
            _ = buffer.append(element)
        }
        self = buffer
    }
}
