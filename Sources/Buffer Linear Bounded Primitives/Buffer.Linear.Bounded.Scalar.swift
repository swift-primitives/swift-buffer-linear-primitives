import Affine_Primitives_Standard_Library_Integration
public import Iterable
import Ordinal_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Buffer.Linear.Bounded.Scalar — hand-written scalar Sequenceable iterator
//
// The single-pass (consuming) iterator for the `Sequenceable` conformance. A
// CONCRETE, LOCAL witness — deliberately NOT the generic `Memory.Cursor` bridge,
// whose generic `Sequenceable` witness demangle-crashes at runtime (Signal-6
// `swift_getAssociatedTypeWitness`; see `memory-contiguous-iteration-bridge.md`
// Outcome OQ-2 split verdict, deferred behind a `/issue-investigation`). The bulk
// `Iterable` side keeps the memory→Iterable bridge (`Iterator.Chunk`); the split
// is bound with `@_implements` in `Buffer.Linear.Bounded+Sequence.Protocol.swift`.
//
// Owns the consumed buffer (`consuming makeIterator()`), re-derives access inside
// each `next()`. `Element: Copyable & Escapable` → copy-out, NO `@_lifetime`.

extension Buffer.Linear.Bounded where S: Span.`Protocol`, S: Copyable, S.Element: Copyable {
    /// Scalar single-pass iterator over an owned bounded linear buffer.
    public struct Scalar: Iterator_Primitive.Iterator.`Protocol`, ~Copyable {
        @usableFromInline
        var base: Buffer<S>.Linear.Bounded

        @usableFromInline
        var position: Index<S.Element>

        @inlinable
        package init(_ base: consuming Buffer<S>.Linear.Bounded) {
            self.base = base
            self.position = .zero
        }
    }
}

extension Buffer.Linear.Bounded.Scalar where S: Span.`Protocol`, S: Copyable, S.Element: Copyable {
    /// The iterator's failure type; iteration never throws.
    public typealias Failure = Never

    /// Advances the iterator and returns the next element, or `nil` if exhausted.
    @inlinable
    public mutating func next() -> S.Element? {
        let end = base.count.map(Ordinal.init)
        guard position < end else { return nil }
        defer { position += .one }
        // Read via the element-store seam subscript (copy-out for Copyable elements) rather than a
        // `span`, which as a lifetime-dependent value would escape this scope.
        return base._storage[position]
    }
}
