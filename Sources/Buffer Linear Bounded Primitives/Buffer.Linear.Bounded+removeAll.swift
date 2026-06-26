import Sequence_Primitives
public import Span_Protocol_Primitives

// MARK: - removeAll()
//
// Copyable-gated concrete clearing method isolated in the ops module per
// [MOD-004]; cold. `removeAll()` is the consuming drain-and-discard
// (solution 6); `remove.all()` is Heap-pinned and cannot resolve under a
// generic `S`.

extension Buffer.Linear.Bounded where S: Span.`Protocol`, S: Copyable, S.Element: Copyable {
    /// Removes every element by consuming drain-and-discard.
    @inlinable
    public mutating func removeAll() {
        _drain { _ in }
    }
}
