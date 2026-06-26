import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives
public import Storage_Contiguous_Primitives

// MARK: - Span.`Protocol` Conformance for Linear.Bounded
//
// UNBOUNDED conformance (the Audit-#5 relaxation, W5-1) — the Linear twin's
// shape: the `span` witness is supplied unbounded in the type module
// (`Buffer.Linear.Bounded+Span.swift`); the old element gate was an accident
// of bundling with the C-interop hatch below (R2 root cause).

extension Buffer.Linear.Bounded: Span.`Protocol` where S: Span.`Protocol`, S: ~Copyable {}

// MARK: - C interop (the cold escape hatch — element-gated)

extension Buffer.Linear.Bounded where S: Span.`Protocol`, S: ~Copyable, S.Element: Copyable {
    /// Unsafe read access for C interop with unannotated APIs.
    @inlinable
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<S.Element>) throws(E) -> R
    ) throws(E) -> R {
        return try unsafe span.withUnsafeBufferPointer(body)
    }
}
