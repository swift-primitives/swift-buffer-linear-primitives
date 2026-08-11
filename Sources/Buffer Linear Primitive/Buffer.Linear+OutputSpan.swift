public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives
public import Storage_Primitive

extension Buffer.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<S.Element> {

    /// A lifetime-bound mutable output view over this buffer's allocated region.
    ///
    /// The span starts at the buffer's initialized frontier and may initialize or
    /// remove elements through its canonical `Swift.OutputSpan` operations. Its
    /// lifetime is bound to the exclusive borrow of this buffer; it cannot expose
    /// the backing storage or escape that borrow.
    ///
    /// When the accessor ends, `Storage.Contiguous.outputSpan` finalizes the
    /// initialized frontier into its ledger. This accessor mirrors that finalized
    /// frontier into `header.count` exactly once.
    @inlinable
    public var outputSpan: Swift.OutputSpan<S.Element> {
        @_lifetime(&self)
        _modify {
            storage.initialization = header.initialization
            defer { header.count = storage.initialization.count }
            yield &storage.outputSpan
        }
    }
}
