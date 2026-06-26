import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives
public import Storage_Contiguous_Primitives

// MARK: - Span.`Protocol` Conformance for Linear
//
// UNBOUNDED conformance (the Audit-#5 relaxation, W5-1): the protocol's one
// requirement (`span`) admits `~Copyable` elements and its witness is supplied
// unbounded in the type module (`Buffer.Linear+Span.swift`). The old
// `S.Element: Copyable` gate was an accident of bundling the conformance with
// the C-interop hatch below — root-caused in
// `container-protocol-lattice-borrowing-iteration.md` (R2); move-only-element
// columns now reach the whole span-bridged lattice.

extension Buffer.Linear: Span.`Protocol` where S: Span.`Protocol`, S: ~Copyable {}

// MARK: - C interop (the cold escape hatch — element-gated)
//
// Isolated in the ops module per [MOD-004]; reaches the storage internals
// through the type module's `package` window (`_storage`) + public
// `isEmpty`/`count` (refined-C). Stays `S.Element: Copyable`: the hatch vends
// `UnsafeBufferPointer`, whose C-side consumers copy elements out.

extension Buffer.Linear where S: Span.`Protocol`, S: ~Copyable, S.Element: Copyable {
    /// Unsafe read access for C interop with unannotated APIs.
    ///
    /// Reads through the substrate's `Span.`Protocol`` span (`_storage.span`),
    /// the (b′) generic-substrate path; `_storage.span(count:)` is Heap-only.
    @inlinable
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<S.Element>) throws(E) -> R
    ) throws(E) -> R {
        return try unsafe span.withUnsafeBufferPointer(body)
    }
}
