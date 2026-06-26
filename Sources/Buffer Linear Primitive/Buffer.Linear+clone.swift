import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive

extension Buffer.Linear where S: ~Copyable {

    /// Returns an independent copy of this buffer with its own storage, sized
    /// to exactly fit the current count of elements.
    ///
    /// Unlike a CoW value-semantic copy (`var new = self`), which may share
    /// storage until mutation, `clone()` always allocates new storage.
    ///
    /// - Complexity: O(`count`)
    @inlinable
    public func clone<E>() -> Self where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>, E: Copyable {
        var newStorage = Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>.create(minimumCapacity: header.count)
        Self.copy(header: header, source: storage, to: &newStorage)
        var newHeader = Self.Header(capacity: newStorage.capacity)
        newHeader.count = header.count
        newStorage.initialization = newHeader.initialization
        return Self(header: newHeader, storage: newStorage)
    }

    /// Returns an independent copy of this buffer with its own storage
    /// allocated to the specified capacity.
    ///
    /// - Parameter capacity: The desired capacity of the resulting buffer.
    ///     Must be greater than or equal to `count`.
    /// - Returns: An independent buffer of the requested capacity holding a copy of every element.
    ///
    /// - Complexity: O(`count`)
    /// - Precondition: `capacity >= count`
    @inlinable
    public func clone<E>(capacity: Index<E>.Count) -> Self where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>, E: Copyable {
        precondition(
            capacity >= header.count,
            "Buffer.Linear.clone(capacity:): capacity must be >= count"
        )
        var newStorage = Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>.create(minimumCapacity: capacity)
        Self.copy(header: header, source: storage, to: &newStorage)
        var newHeader = Self.Header(capacity: newStorage.capacity)
        newHeader.count = header.count
        newStorage.initialization = newHeader.initialization
        return Self(header: newHeader, storage: newStorage)
    }
}
