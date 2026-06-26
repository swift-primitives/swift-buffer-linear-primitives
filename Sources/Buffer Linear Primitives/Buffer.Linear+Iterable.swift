public import Iterable
public import Memory_Iterator_Primitives
public import Span_Protocol_Primitives

// MARK: - Iterable (multipass, borrowing)
//
// `Buffer.Linear` is contiguous (single span); `Iterable` is vended FOR FREE by
// the memory→Iterable bridge (swift-memory-iterator-primitives) over the existing
// `Span.\`Protocol\`` conformance — the bridge supplies the borrowing
// `makeIterator()`, vending the bulk `Iterator.Chunk`. No hand-written Iterable
// iterator.
//
// `Iterable` and `Sequenceable` both declare `associatedtype Iterator` (Swift
// unifies them); the `@_implements(Iterable, Iterator)` escape hatch binds THIS
// protocol's `Iterator` to `Iterator.Chunk`, leaving `Sequenceable`'s binding to
// the sibling `Buffer.Linear+Sequenceable.swift`.

// RELAXED (Audit-#5, W5-1): the old `S: Copyable` storage-column bound was
// unsatisfiable over the unconditionally-~Copyable storage tier (dead conformance
// since W2), and the D4 bridge vends `Iterator.Chunk` for BOTH element kinds —
// so the element gate drops too. Every span-bearing column is Iterable now.
extension Buffer.Linear: Iterable where S: Span.`Protocol`, S: ~Copyable {
    /// The multipass iterator type, vended by the memory-to-`Iterable` bridge as a chunk iterator.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Chunk<S.Element>
}
