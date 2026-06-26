import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Static element-store operations (~Copyable elements; storage-generic)
//
// Thin Header adapters over the storage-generic core in `Store.Protocol+Linear.swift`. The element
// work is fully generic — the core touches only the inherited `Store.`Protocol`` typed primitives
// (`subscript` / `initialize(at:to:)` / `move(at:)` and the `+Move` / `+Deinitialize` derivations) —
// so these adapters are generic over any `S: Store.`Protocol``, threading the storage `inout S` (the
// buffer's own field, passed `&storage`) and the `Header.count` cursor. No `initialization` sync is
// performed: every count change flows through the seam's `initialize` / `move`, which self-maintain
// each conformer's ledger, and the storage's deinit oracle honors that ledger on teardown.

extension Buffer.Linear where S: ~Copyable {

    // MARK: Append

    /// Writes element at slot `count`, then increments count.
    ///
    /// - Precondition: `header.count < header.capacity` (not full).
    @inlinable
    public static func append(
        _ element: consuming S.Element,
        header: inout Header,
        storage: inout S
    ) {
        S.linearAppend(consume element, count: &header.count, storage: &storage)
    }

    // MARK: Remove First

    /// Removes and returns element at slot 0, shifting remaining elements left.
    ///
    /// - Precondition: `header.count > 0` (not empty).
    @inlinable
    public static func removeFirst(
        header: inout Header,
        storage: inout S
    ) -> S.Element {
        S.linearRemoveFirst(count: &header.count, storage: &storage)
    }

    // MARK: Remove At

    /// Removes and returns the element at the given index, shifting subsequent elements left.
    ///
    /// - Precondition: `index < header.count` (in bounds).
    @inlinable
    public static func remove(
        at index: Index<S.Element>,
        header: inout Header,
        storage: inout S
    ) -> S.Element {
        S.linearRemove(at: index, count: &header.count, storage: &storage)
    }

    // MARK: Replace At

    /// Replaces the element at the given index, returning the old element.
    ///
    /// Does NOT change count — the slot remains initialized.
    @inlinable
    public static func replace(
        at index: Index<S.Element>,
        with newElement: consuming S.Element,
        storage: inout S
    ) -> S.Element {
        S.linearReplace(at: index, with: consume newElement, storage: &storage)
    }

    // MARK: Consume Back

    /// Removes and returns the last element (the one at the trailing slot).
    ///
    /// - Precondition: `header.count > 0` (not empty).
    @inlinable
    public static func consumeBack(
        header: inout Header,
        storage: inout S
    ) -> S.Element {
        S.linearConsumeBack(count: &header.count, storage: &storage)
    }

    // MARK: Swap At

    /// Swaps the elements at positions `i` and `j` in-place.
    ///
    /// Does NOT change count.
    ///
    /// - Precondition: Both indices must be in bounds (`< header.count`).
    @inlinable
    public static func swap(
        at i: Index<S.Element>,
        with j: Index<S.Element>,
        storage: inout S
    ) {
        S.linearSwap(at: i, with: j, storage: &storage)
    }

    // MARK: Deinitialize All

    /// Deinitializes all elements tracked by the header.
    @inlinable
    public static func deinitializeAll(
        header: inout Header,
        storage: inout S
    ) {
        S.linearDeinitializeAll(count: &header.count, storage: &storage)
    }

    // MARK: Truncate

    /// Deinitializes elements beyond `newCount`, keeping elements `0..<newCount`.
    ///
    /// If `newCount >= header.count`, this is a no-op.
    ///
    /// - Precondition: `newCount >= 0`.
    @inlinable
    public static func truncate(
        to newCount: Index<S.Element>.Count,
        header: inout Header,
        storage: inout S
    ) {
        S.linearTruncate(to: newCount, count: &header.count, storage: &storage)
    }
}
