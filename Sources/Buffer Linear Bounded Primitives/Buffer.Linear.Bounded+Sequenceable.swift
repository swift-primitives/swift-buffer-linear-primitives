public import Sequence_Primitives
public import Span_Protocol_Primitives

// MARK: - Sequenceable (single-pass, consuming)
//
// `Buffer.Linear.Bounded` satisfies `Sequenceable` with a HAND-WRITTEN CONCRETE
// scalar iterator (`Buffer.Linear.Bounded.Scalar`), NOT the generic `Memory.Cursor`
// bridge: the generic witness demangle-crashes at runtime (Signal-6
// `swift_getAssociatedTypeWitness`; `memory-contiguous-iteration-bridge.md` OQ-2).
// The concrete per-variant iterator is IRREDUCIBLE and STAYS — do NOT dedup it via
// the dormant memory-sequence bridge. The `@_implements(Sequenceable, Iterator)`
// escape hatch binds THIS protocol's `Iterator` to `Buffer.Linear.Bounded.Scalar`.

extension Buffer.Linear.Bounded: Sequenceable where S: Span.`Protocol`, S: Copyable, S.Element: Copyable {
    /// The single-pass iterator type, a hand-written concrete scalar iterator.
    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = Buffer<S>.Linear.Bounded.Scalar

    /// Consumes the buffer and returns a single-pass scalar iterator over its elements.
    @inlinable
    public consuming func makeIterator() -> Buffer<S>.Linear.Bounded.Scalar {
        Buffer<S>.Linear.Bounded.Scalar(self)
    }
}
