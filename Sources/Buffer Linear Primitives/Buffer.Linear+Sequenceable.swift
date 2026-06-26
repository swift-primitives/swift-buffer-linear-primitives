public import Sequence_Primitives
public import Span_Protocol_Primitives

// MARK: - Sequenceable (single-pass, consuming)
//
// `Buffer.Linear` satisfies `Sequenceable` with a HAND-WRITTEN CONCRETE scalar
// iterator (`Buffer.Linear.Scalar`), NOT the generic `Memory.Cursor` bridge: the
// generic `Memory.Cursor`/Sequenceable witness demangle-crashes at runtime
// (Signal-6 `swift_getAssociatedTypeWitness`; `memory-contiguous-iteration-bridge.md`
// OQ-2). The concrete per-variant iterator is IRREDUCIBLE and STAYS — do NOT dedup
// it via the dormant memory-sequence bridge. The `@_implements(Sequenceable, Iterator)`
// escape hatch binds THIS protocol's `Iterator` to `Buffer.Linear.Scalar`.

extension Buffer.Linear: Sequenceable where S: Span.`Protocol`, S: ~Copyable, S.Element: Copyable {
    /// The single-pass iterator type, a hand-written concrete scalar iterator.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = Buffer<S>.Linear.Scalar

    /// Consumes the buffer and returns a single-pass scalar iterator over its elements.
    @inlinable
    public consuming func makeIterator() -> Buffer<S>.Linear.Scalar {
        Buffer<S>.Linear.Scalar(self)
    }
}
