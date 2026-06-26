import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives

extension Buffer.Linear.Bounded where S: ~Copyable {
    /// Accesses the element at the given index.
    ///
    /// - Parameter index: The index of the element to access.
    @inlinable
    public subscript<E: ~Copyable>(index: Index<E>) -> E where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        _read {
            yield storage[index]
        }
        _modify {
            yield &storage[index]
        }
    }
}
