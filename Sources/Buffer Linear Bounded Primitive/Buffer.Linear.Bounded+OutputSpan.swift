import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive
import Storage_Protocol_Primitives

extension Buffer.Linear.Bounded where S: ~Copyable {

    /// Creates a bounded linear buffer with the given capacity, initialized via
    /// an `OutputSpan` closure.
    ///
    /// Allocates storage for `capacity` slots. The initializer closure receives
    /// an `OutputSpan<Element>` over the entire allocated region and may append
    /// up to `capacity` elements. The resulting buffer's count reflects however
    /// many elements the closure successfully appended.
    ///
    /// ## Throwing behavior
    ///
    /// If the initializer throws, elements successfully initialized before the
    /// throw are deinitialized by the `OutputSpan`'s deinit, and the storage is
    /// released. The buffer is not constructed; the error propagates to the caller.
    /// This matches the semantics of
    /// `Swift.ContiguousArray.init(capacity:initializingWith:)`.
    ///
    /// - Parameters:
    ///   - capacity: The number of slots to allocate. Actual capacity may exceed
    ///       this value (determined by `Storage.Contiguous<Memory.Heap>.capacity`), but the
    ///       `OutputSpan` passed to the closure is sized to exactly `capacity`.
    ///   - initializer: A closure that populates the allocated region via an
    ///       `OutputSpan<Element>`. Called at most once.
    ///
    /// - Throws: Any error thrown by `initializer`, with typed-throws preservation.
    @inlinable
    public init<E: ~Copyable, Failure: Swift.Error>(
        capacity: Index<E>.Count,
        initializingWith initializer: (inout Swift.OutputSpan<E>) throws(Failure) -> Void
    ) throws(Failure) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        var storage = Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>.create(minimumCapacity: capacity)
        // Whole-region OutputSpan over the fresh storage; `outputSpan` finalizes + commits the
        // count into the ledger on both exits. On throw the local `storage` is released and its
        // deinit oracle deinitializes the committed elements; the buffer is not constructed.
        try initializer(&storage.outputSpan)
        var header = Buffer.Linear.Header(capacity: storage.capacity)
        header.count = storage.initialization.count
        self.init(header: header, storage: storage)
    }
}
