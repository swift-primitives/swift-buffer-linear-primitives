import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives

extension Buffer.Linear where S: ~Copyable {

    /// Grows or shrinks the buffer's storage to exactly the specified capacity,
    /// preserving existing elements.
    ///
    /// Unlike `reserveCapacity`, which only grows, `reallocate` can also shrink
    /// storage, freeing memory when the buffer is holding more capacity than
    /// needed.
    ///
    /// - Parameter newCapacity: The desired new capacity. Must be greater than
    ///     or equal to the current `count`.
    /// - Precondition: `newCapacity >= count`
    /// - Complexity: O(`count`)
    @inlinable
    public mutating func reallocate<E: ~Copyable>(capacity newCapacity: Index<E>.Count) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        precondition(
            newCapacity >= header.count,
            "Buffer.Linear.reallocate(capacity:): capacity must be >= count"
        )
        _growTo(newCapacity)
    }
}
