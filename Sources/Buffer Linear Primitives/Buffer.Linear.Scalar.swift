import Affine_Primitives_Standard_Library_Integration
public import Iterable
public import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives
public import Storage_Contiguous_Primitives

// MARK: - Buffer.Linear.Scalar — hand-written scalar Sequenceable iterator
//
// The single-pass (consuming) iterator for the `Sequenceable` conformance. It is
// a CONCRETE, LOCAL witness — deliberately NOT the generic `Memory.Cursor`
// bridge, whose generic `Sequenceable` witness demangle-crashes at runtime
// (Signal-6 `swift_getAssociatedTypeWitness`; see
// `memory-contiguous-iteration-bridge.md` §1 / Outcome OQ-2 split verdict, and the
// deferred `/issue-investigation` of the demangle). A concrete per-variant scalar
// iterator avoids that witness entirely (proven against the buffer-slab `d6fcf5b`
// scalar-iterator precedent, which builds + runs green for a generic conformer).
//
// `Sequenceable.makeIterator()` is `consuming`, so the iterator OWNS the consumed
// buffer and re-derives access inside each `next()` (the buffer's `span` is
// `~Escapable` and cannot be stored across calls). Owning a `~Copyable`
// `Buffer.Linear` makes the iterator itself `~Copyable`; `Iterator.`Protocol``
// admits `~Copyable` iterators. `Element: Copyable & Escapable` lets `next()` copy
// the element out and return it past the iterator, so NO `@_lifetime` annotation
// is used (an Escapable result rejects `@_lifetime`).
//
// The bulk `Iterable` side keeps the memory→Iterable bridge (`Iterator.Chunk`);
// the two distinct `Iterator` associated types are bound with the
// `@_implements(Iterable, Iterator)` / `@_implements(Sequenceable, Iterator)`
// split in `Buffer.Linear+Sequence.Protocol.swift`.

extension Buffer.Linear where S: Span.`Protocol`, S: ~Copyable, S.Element: Copyable {
    /// Scalar single-pass iterator over an owned linear buffer.
    ///
    /// Vended by the `Sequenceable` `consuming makeIterator()`. Owns the consumed
    /// buffer and yields its elements one at a time, reading through the storage's
    /// `Span.`Protocol`` span (the (b′) generic-substrate path; the Heap-pinned
    /// subscript would force `S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>`).
    public struct Scalar: Iterator_Primitive.Iterator.`Protocol`, ~Copyable {
        @usableFromInline
        var base: Buffer<S>.Linear

        @usableFromInline
        var position: Index<S.Element>

        @inlinable
        package init(_ base: consuming Buffer<S>.Linear) {
            self.base = base
            self.position = .zero
        }
    }
}

extension Buffer.Linear.Scalar where S: Span.`Protocol`, S: ~Copyable, S.Element: Copyable {
    /// The iterator's failure type; iteration never throws.
    public typealias Failure = Never

    /// Advances the iterator and returns the next element, or `nil` if exhausted.
    @inlinable
    public mutating func next() -> S.Element? {
        let end = base.count.map(Ordinal.init)
        guard position < end else { return nil }
        defer { position += .one }
        // Read through the buffer's (now storage-generic) subscript and copy the
        // element out (Element: Copyable) — avoids holding the storage's ~Escapable
        // span across the return for a ~Copyable substrate (e.g. Store.Small, deferred Q2).
        return base[position]
    }
}
