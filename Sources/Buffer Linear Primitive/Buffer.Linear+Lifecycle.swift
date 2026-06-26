import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Allocator_Protocol_Primitives
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive
import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Extensions for Linear (declared in Core)
//
// The element-store ops (`remove` / `replace` / `swap` / `truncate` / `removeFirst` / `removeLast`
// / `removeAll`) are storage-GENERIC over `S: Store.`Protocol`` — they ride the seam (`move(at:)` /
// `initialize(at:to:)`) and its derivations, and the seam auto-maintains each conformer's own
// initialization ledger, so no explicit ledger sync is needed. The CREATABLE / GROWABLE surface
// (`init(minimumCapacity:)` / `append`-with-grow / `reserveCapacity` / `removeAll(keepingCapacity:)`
// / `_growTo`) needs `create` + a fresh allocation. `Storage.Contiguous.create` is generic over the
// fresh-byte-construction capability `Memory.Growable` (see Storage.Contiguous.swift), so the growable
// buffer surface is pinned to the **column over ANY `Resource: Memory.Growable`** — `Memory.Heap`
// (dense heap) AND `Memory.Small<n>` (inline⊕heap spill) compose uniformly. The bodies are identical
// for every growable `Resource`: they only touch `create` / `move(at:)` / `initialize(at:to:)`, none
// of which is heap-specific. A fixed column (`Memory.Inline`) is correctly excluded — it does not
// conform `Memory.Growable`, so `create` (and this whole surface) does not exist for it. The pin is on
// the METHOD, `~Copyable` on the extension (6.3.2 mechanic #2: extensions cannot introduce free
// element parameters; methods can).

extension Buffer.Linear where S: ~Copyable {

    /// Creates a growable linear buffer with at least the given capacity (any growable column).
    ///
    /// Actual capacity comes from `storage.capacity`.
    @inlinable
    public init<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>(
        minimumCapacity: Index<Element>.Count
    ) where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        let storage = S.create(minimumCapacity: minimumCapacity)
        self.init(
            header: Self.Header(capacity: storage.capacity),
            storage: storage
        )
    }

    /// Creates an empty growable buffer over any growable column.
    @inlinable
    public init<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>()
    where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        self.init(minimumCapacity: Index<Element>.Count.zero)
    }

    /// The number of elements in the buffer.
    @inlinable
    public var count: Index<S.Element>.Count { header.count }

    /// The total slot capacity.
    @inlinable
    public var capacity: Index<S.Element>.Count { header.capacity }

    /// Whether the buffer is at capacity.
    @inlinable
    public var isFull: Bool { header.isFull }

    // MARK: - Mutations

    /// Appends an element to the back of the buffer, growing the backing when full (any growable column).
    ///
    /// For `Memory.Small<n>` the growth re-runs the inline⊕heap spill decision: it stays inline while
    /// the new capacity fits the inline budget and spills to heap once it doesn't — so appending past
    /// the inline capacity is correct (it relocates into a heap region), never a trap.
    @inlinable
    public mutating func append<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>(_ element: consuming Element)
    where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        if header.isFull {
            let newCapacity: Index<Element>.Count = header.capacity == .zero ? .one : header.capacity * 2
            _growTo(newCapacity)
        }
        Self.append(consume element, header: &header, storage: &storage)
    }

    /// Removes and returns the element at the given index, shifting subsequent elements left.
    ///
    /// - Precondition: The index must be in bounds.
    @inlinable
    public mutating func remove(at index: Index<S.Element>) -> S.Element {
        Self.remove(at: index, header: &header, storage: &storage)
    }

    /// Replaces the element at the given index, returning the old element.
    ///
    /// - Precondition: The index must be in bounds.
    @inlinable
    public mutating func replace(at index: Index<S.Element>, with newElement: consuming S.Element) -> S.Element {
        Self.replace(at: index, with: consume newElement, storage: &storage)
    }

    /// Swaps the elements at positions `i` and `j` in-place.
    ///
    /// - Precondition: Both indices must be in bounds.
    @inlinable
    public mutating func swap(at i: Index<S.Element>, with j: Index<S.Element>) {
        Self.swap(at: i, with: j, storage: &storage)
    }

    /// Removes elements beyond the specified count.
    ///
    /// If `newCount >= count`, this method has no effect.
    @inlinable
    public mutating func truncate(to newCount: Index<S.Element>.Count) {
        Self.truncate(to: newCount, header: &header, storage: &storage)
    }

    // MARK: - Direct removal (storage-generic over the seam)

    /// Removes and returns the first element, shifting the rest left.
    ///
    /// O(n).
    ///
    /// - Precondition: the buffer is not empty.
    @inlinable
    public mutating func removeFirst() -> S.Element {
        _removeFirst()
    }

    /// Removes and returns the last element.
    ///
    /// O(1).
    ///
    /// - Precondition: the buffer is not empty.
    @inlinable
    public mutating func removeLast() -> S.Element {
        _removeLast()
    }

    /// Removes all elements.
    ///
    /// O(n).
    @inlinable
    public mutating func removeAll() {
        _removeAll()
    }

    /// Removes all elements, optionally releasing the backing allocation (any growable column).
    ///
    /// `keepingCapacity: true` clears the live elements but retains the current storage;
    /// `false` additionally resets to a fresh empty allocation.
    @inlinable
    public mutating func removeAll<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>(keepingCapacity: Bool)
    where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        _removeAll()
        if !keepingCapacity {
            self = Buffer.Linear(minimumCapacity: Index<Element>.Count.zero)
        }
    }

    /// Ensures the buffer can hold at least `minimumCapacity` elements (any growable column).
    @inlinable
    public mutating func reserveCapacity<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>(_ minimumCapacity: Index<Element>.Count)
    where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        if minimumCapacity > header.capacity {
            _growTo(minimumCapacity)
        }
    }

    // MARK: - Growth (internal, any growable column)

    @inlinable
    mutating func _growTo<Element: ~Copyable, Resource: Memory.Growable & ~Copyable>(_ minimumCapacity: Index<Element>.Count)
    where S == Storage<Memory.Allocator<Resource>>.Contiguous<Element> {
        var newStorage = S.create(minimumCapacity: minimumCapacity)
        let newCapacity = newStorage.capacity
        let oldCount = header.count
        // Relocate the live prefix [0, count) into the new storage element-wise via the seam:
        // each `move(at:)` empties the old slot (retracting the old ledger), each
        // `initialize(at:to:)` fills the new slot (advancing the new ledger). After the loop the
        // OLD ledger is `.empty` (so the dropped old backing's oracle destroys nothing — no
        // double-free) and the NEW ledger is `.linear(oldCount)` — both maintained by the seam.
        // A bulk bitwise relocation is deliberately deferred ecosystem-wide
        // (Store.Protocol+Move: "a bulk … path … intentionally NOT added here").
        var slot: Index<Element> = .zero
        let end = oldCount.map(Ordinal.init)
        while slot < end {
            newStorage.initialize(at: slot, to: storage.move(at: slot))
            slot += .one
        }
        storage = newStorage
        header = Self.Header(capacity: newCapacity)
        header.count = oldCount
    }
}

// MARK: - Internal Mutations (storage-generic over the seam)

extension Buffer.Linear where S: ~Copyable {

    @usableFromInline
    mutating func _removeFirst() -> S.Element {
        Self.removeFirst(header: &header, storage: &storage)
    }

    @usableFromInline
    mutating func _removeLast() -> S.Element {
        Self.consumeBack(header: &header, storage: &storage)
    }

    @usableFromInline
    mutating func _removeAll() {
        Self.deinitializeAll(header: &header, storage: &storage)
    }
}

// MARK: - Property.Inout (.peek, .remove)

extension Buffer.Linear where S: ~Copyable {
    /// Namespaced peek operations (read-only).
    ///
    /// - `buffer.peek.front` — peeks at the first element.
    /// - `buffer.peek.back` — peeks at the last element.
    @inlinable
    public var peek: Peek.View {
        _read {
            yield Peek.View(self)
        }
    }

    /// Namespaced remove operations.
    ///
    /// - `buffer.remove.first()` — removes the first element.
    /// - `buffer.remove.last()` — removes the last element.
    /// - `buffer.remove.all()` — removes all elements.
    @inlinable
    public var remove: Remove.View {
        mutating _read {
            yield.init(&self)
        }
        mutating _modify {
            var view: Remove.View = .init(&self)
            yield &view
        }
    }
}

// MARK: - Remove Operations (~Copyable)

extension Property.Inout.Typed
where
    Tag == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear.Remove,
    Base == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>>.Linear,
    Element: ~Copyable
{
    /// Removes and returns the first element, shifting remaining elements left.
    ///
    /// - Precondition: The buffer is not empty.
    /// - Complexity: O(n)
    @inlinable
    public mutating func first() -> Element {
        base.value._removeFirst()
    }

    /// Removes and returns the last element.
    ///
    /// - Precondition: The buffer is not empty.
    /// - Complexity: O(1)
    @inlinable
    public mutating func last() -> Element {
        base.value._removeLast()
    }

    /// Removes all elements from the buffer.
    ///
    /// - Complexity: O(n) where n is the number of elements.
    @inlinable
    public mutating func all() {
        base.value._removeAll()
    }
}
