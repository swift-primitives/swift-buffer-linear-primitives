public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives
public import Storage_Primitive
import Storage_Protocol_Primitives

extension Buffer.Linear where S: ~Copyable {

    /// Creates a growable linear buffer with the given initial capacity,
    /// initialized via an `OutputSpan<Element>` closure.
    ///
    /// Allocates storage for `capacity` slots. The initializer closure receives
    /// an `OutputSpan<Element>` sized to exactly `capacity` and may append up
    /// to that many elements. The buffer's final count reflects however many
    /// elements the closure appended.
    ///
    /// ## Throwing behavior
    ///
    /// If the initializer throws, elements successfully initialized before the
    /// throw are deinitialized when the partially-built `storage` is released
    /// (its committed initialization count is torn down); the buffer is not
    /// constructed. This matches stdlib's init semantics
    /// (`Swift.ContiguousArray.init(capacity:initializingWith:)`).
    @inlinable
    public init<E: ~Copyable, Failure: Swift.Error>(
        capacity: Index<E>.Count,
        initializingWith initializer: (inout Swift.OutputSpan<E>) throws(Failure) -> Void
    ) throws(Failure) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        var storage = Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>.create(minimumCapacity: capacity)
        // Whole-region OutputSpan over the fresh storage (count 0, capacity = `capacity`); the
        // storage's `outputSpan` finalizes + commits the initialized count into its ledger on both
        // the normal and throwing exit. On throw the local `storage` is released and its deinit
        // oracle deinitializes the committed elements.
        try initializer(&storage.outputSpan)
        var header = Self.Header(capacity: storage.capacity)
        header.count = storage.initialization.count
        self.init(header: header, storage: storage)
    }

    /// Invokes the closure with an `OutputSpan<Element>` covering the whole
    /// allocated region `[0 ..< capacity)`, with `initializedCount` set to the
    /// current `count`.
    ///
    /// The closure may append, remove, swap, or otherwise edit elements. On
    /// return, the buffer's count reflects the OutputSpan's final count.
    ///
    /// ## Throwing behavior
    ///
    /// If the closure throws, the OutputSpan's current state is still committed
    /// to the buffer (the storage's `outputSpan` finalizes on both success and
    /// failure paths). This matches the append-style semantics rather than
    /// init-style.
    ///
    /// This is the primitive that backs `Array.edit { }` and SE-0527's
    /// `edit` escape hatch.
    @inlinable
    public mutating func edit<E: ~Copyable, Failure: Swift.Error, R: ~Copyable>(
        _ body: (inout Swift.OutputSpan<E>) throws(Failure) -> R
    ) throws(Failure) -> R where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        // Sync storage's initialization to the buffer's authoritative count so the
        // whole-region `outputSpan`'s frontier (= storage's count) equals header.count,
        // then drive the edit through it. storage.outputSpan finalizes + writes
        // storage.initialization on both exits; the buffer mirrors its count back.
        storage.initialization = header.initialization
        defer { header.count = storage.initialization.count }
        return try body(&storage.outputSpan)
    }

    /// Grows the buffer to hold `addingCapacity` additional elements, then
    /// invokes the initializer closure with an `OutputSpan<Element>` over the
    /// uninitialized tail `[count ..< count + addingCapacity)`.
    ///
    /// ## Throwing behavior
    ///
    /// If the initializer throws, elements successfully initialized before the
    /// throw **are committed** to the buffer (they remain valid, count
    /// increases by however many were appended). The storage growth that
    /// happened before the throw is also preserved. This matches stdlib's
    /// append semantics (`Swift.ContiguousArray.append(addingCapacity:initializingWith:)`),
    /// which is distinct from init's destroy-on-throw behavior.
    @inlinable
    public mutating func append<E: ~Copyable, Failure: Swift.Error>(
        addingCapacity: Index<E>.Count,
        initializingWith initializer: (inout Swift.OutputSpan<E>) throws(Failure) -> Void
    ) throws(Failure) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        let required = header.count.add.saturating(addingCapacity)
        if required > header.capacity {
            _growTo(required)
        }
        // Sync storage's initialization to the buffer's count so the tail window starts at the
        // right frontier, then offer the closure EXACTLY the promised budget — the windowed
        // `withOutputSpan(addingCapacity:)` (span.capacity == addingCapacity; isFull at budget),
        // which finalizes + commits the appended count into the ledger on both exits.
        storage.initialization = header.initialization
        defer { header.count = storage.initialization.count }
        try storage.withOutputSpan(addingCapacity: addingCapacity, initializer)
    }
}
