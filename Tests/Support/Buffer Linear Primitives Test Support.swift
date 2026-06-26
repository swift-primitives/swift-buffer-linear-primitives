public import Buffer_Linear_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

// MARK: - Linear

extension Buffer.Linear where S: ~Copyable {
    // Heap-pinned via the init-level same-type generic: `Self(minimumCapacity:)`
    // is the Heap-pinned creation path (the ⑤-(N) reparam). This is the
    // (minimumCapacity:)+append pattern, factored — the replacement for the dropped
    // `ExpressibleByArrayLiteral` conformance (ASK-2).
    @inlinable
    public init<E>(_ elements: [E], minimumCapacity: UInt = 0) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        let cap: Index<E>.Count = .init(Cardinal(Swift.max(UInt(elements.count), minimumCapacity)))
        var buffer = Self(minimumCapacity: cap)
        for element in elements {
            buffer.append(element)
        }
        self = buffer
    }
}
