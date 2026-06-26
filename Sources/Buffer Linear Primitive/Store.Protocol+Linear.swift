import Affine_Primitives_Standard_Library_Integration
public import Index_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Generic Linear Algorithm (storage-agnostic core)
//
// The single linear-buffer element algorithm, written once over any single-region
// `Memory.Tracked.`Protocol`` conformer (`__StoreProtocol` is the hoisted name per
// [API-IMPL-009]; the `Memory.Tracked.`Protocol`` typealias cannot be extended directly
// because `Storage<Element>` would need its generic parameter). Bodies touch ONLY
// the north-star typed primitives — `subscript` / `initialize(at:to:)` /
// `move(at:)` and the `Storage.Protocol+Move` / `+Deinitialize` derivations
// (`moveInitialize(from:to:count:)`, `swapAt(_:_:)`, `deinitialize(range:)`) — plus
// the `count` cursor. The legacy raw slot-address primitive is fully gone here, as
// is any whole-region unsafe-buffer / output-span construct: the generic consumer
// is migrated entirely onto the typed surface (plan §5). The bodies do NOT read or
// write `storage.initialization` and do NOT trigger copy-on-write.
//
// `storage` is `inout Self`: the north-star `initialize` / `move` / `_modify`
// witnesses take exclusive `&self` (plan §1/§3), so the storage-agnostic core
// threads the conformer mutably. The exclusive borrow is exactly what makes the
// per-slot mutation sound (it forecloses the aliasing hazard the returning-span
// model could not).
//
// The two storage-side concerns are the concrete per-leaf shell's responsibility,
// NOT the core's (R1, HANDOFF-buffer-heap-leaf-teardown.md):
//   - teardown sync: the heap backing-class `deinit` frees `storage.initialization`,
//     so the heap shell keeps `storage.initialization = header.initialization` after
//     each op. The core never touches it (the setter is not on `Memory.Tracked.`Protocol``).
//   - CoW: the Copyable heap shell triggers copy-on-write through the conformer's
//     own `initialize` / `move` CoW choke points before the core mutates.
//
// Declared in the buffer package (NOT swift-storage-primitives): this is
// buffer-domain logic that happens to be generic over storage; placing it in
// storage would invert the layer dependency ([ARCH-LAYER-001] / [PRIM-ARCH-002]).
//
// `count` is the logical element count (the buffer `Header`'s truth), passed
// `inout` and kept header-agnostic so the same core can serve future single-region
// disciplines (Ring/Gap/Slab) without rewrite.

extension __StoreProtocol where Self: ~Copyable {

    /// Writes `element` at slot `count`, then increments `count`.
    ///
    /// - Precondition: `count < capacity` (the caller grows first).
    @inlinable
    static func linearAppend(
        _ element: consuming Element,
        count: inout Index<Element>.Count,
        storage: inout Self
    ) {
        let slot = count.map(Ordinal.init)
        storage.initialize(at: slot, to: consume element)
        count = count.add.saturating(.one)
    }

    /// Removes and returns the element at slot 0, shifting the remaining `[1, count)` elements down by one slot.
    ///
    /// - Precondition: `count > 0`.
    @inlinable
    static func linearRemoveFirst(
        count: inout Index<Element>.Count,
        storage: inout Self
    ) -> Element {
        let element = storage.move(at: .zero)
        if count > .one {
            let secondSlot = Index<Element>.Count.one.map(Ordinal.init)
            let followingCount = count.subtract.saturating(.one)
            storage.moveInitialize(from: secondSlot, to: .zero, count: followingCount)
        }
        count = count.subtract.saturating(.one)
        return element
    }

    /// Removes and returns the element at `index`, shifting subsequent elements left.
    ///
    /// - Precondition: `index < count`.
    @inlinable
    static func linearRemove(
        at index: Index<Element>,
        count: inout Index<Element>.Count,
        storage: inout Self
    ) -> Element {
        precondition(index < count, "Index out of bounds")
        let element = storage.move(at: index)
        let nextSlot = index + .one
        let followingCount = count.subtract.saturating(nextSlot.map(Cardinal.init))
        if followingCount > .zero {
            storage.moveInitialize(from: nextSlot, to: index, count: followingCount)
        }
        count = count.subtract.saturating(.one)
        return element
    }

    /// Replaces the element at `index`, returning the old element.
    ///
    /// The logical count is unchanged.
    @inlinable
    static func linearReplace(
        at index: Index<Element>,
        with newElement: consuming Element,
        storage: inout Self
    ) -> Element {
        let old = storage.move(at: index)
        storage.initialize(at: index, to: consume newElement)
        return old
    }

    /// Removes and returns the last element (at the trailing slot), decrementing `count`.
    ///
    /// - Precondition: `count > 0`.
    @inlinable
    static func linearConsumeBack(
        count: inout Index<Element>.Count,
        storage: inout Self
    ) -> Element {
        let newCount = count.subtract.saturating(.one)
        let element = storage.move(at: newCount.map(Ordinal.init))
        count = newCount
        return element
    }

    /// Swaps the elements at `i` and `j` in place.
    ///
    /// The logical count is unchanged.
    @inlinable
    static func linearSwap(
        at i: Index<Element>,
        with j: Index<Element>,
        storage: inout Self
    ) {
        storage.swapAt(i, j)
    }

    /// Deinitializes all live elements `[0, count)` and resets `count` to zero.
    @inlinable
    static func linearDeinitializeAll(
        count: inout Index<Element>.Count,
        storage: inout Self
    ) {
        if count > .zero {
            let upper: Index<Element> = count.map(Ordinal.init)
            storage.deinitialize(range: .zero..<upper)
        }
        count = .zero
    }

    /// Deinitializes elements `[newCount, count)`, keeping `[0, newCount)`.
    ///
    /// No-op if `newCount >= count`.
    @inlinable
    static func linearTruncate(
        to newCount: Index<Element>.Count,
        count: inout Index<Element>.Count,
        storage: inout Self
    ) {
        guard newCount < count else { return }
        let start: Index<Element> = newCount.map(Ordinal.init)
        let upper: Index<Element> = count.map(Ordinal.init)
        storage.deinitialize(range: start..<upper)
        count = newCount
    }
}
