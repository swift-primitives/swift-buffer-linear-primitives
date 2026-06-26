public import Sequence_Primitives

// MARK: - Sequence.Drain.Protocol + .drain accessor
//
// Copyable-gated conformance isolated in the ops module per [MOD-004]; cold
// (iteration). Drain prepends the public CoW-safe `ensureUnique()` then delegates
// the consuming loop to the type module's `_drain` package window (refined-C).

extension Buffer.Linear.Bounded: Sequence.Drain.`Protocol` where S: ~Copyable {
    /// Consumes the buffer, applying `body` to each element in initialized order.
    @inlinable
    public mutating func drain(_ body: (consuming S.Element) -> Void) {
        _drain(body)
    }
}

// MARK: - Property.Inout (.drain)

extension Buffer.Linear.Bounded where S: ~Copyable {
    /// A mutating accessor that consumes the buffer element by element.
    @inlinable
    public var drain: Property<Sequence.Drain, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Drain, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Drain, Self>.Inout(&self)
            yield &accessor
        }
    }
}
