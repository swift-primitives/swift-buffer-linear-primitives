import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Allocator_Protocol_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Store_Protocol_Primitives

extension Buffer.Linear where S: ~Copyable {

    /// Consumes this buffer into independently owned leading and remaining buffers.
    ///
    /// The prefix contains `min(maximum, count)` elements. This operation relocates each
    /// element into a fresh allocation; it does not provide a zero-copy view.
    @inlinable
    public consuming func split<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>(
        maximum: Index<Element>.Count
    ) -> Split where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        var source = consume self
        let prefixCount = maximum < source.header.count ? maximum : source.header.count
        let remainderCount = source.header.count.subtract.saturating(prefixCount)
        var prefixStorage = S.create(minimumCapacity: prefixCount)
        var remainderStorage = S.create(minimumCapacity: remainderCount)

        var sourceSlot: Index<Element> = .zero
        let prefixEnd = prefixCount.map(Ordinal.init)
        while sourceSlot < prefixEnd {
            prefixStorage.initialize(at: sourceSlot, to: source.storage.move(at: sourceSlot))
            sourceSlot += .one
        }

        var remainderSlot: Index<Element> = .zero
        let sourceEnd = source.header.count.map(Ordinal.init)
        while sourceSlot < sourceEnd {
            remainderStorage.initialize(
                at: remainderSlot,
                to: source.storage.move(at: sourceSlot)
            )
            sourceSlot += .one
            remainderSlot += .one
        }

        var prefixHeader = Self.Header(capacity: prefixStorage.capacity)
        prefixHeader.count = prefixCount
        var remainderHeader = Self.Header(capacity: remainderStorage.capacity)
        remainderHeader.count = remainderCount
        return Split(
            prefix: Self(header: prefixHeader, storage: prefixStorage),
            remainder: Self(header: remainderHeader, storage: remainderStorage)
        )
    }
}
