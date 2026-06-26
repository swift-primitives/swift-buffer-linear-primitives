import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Span_Protocol_Primitives

// MARK: - Span / MutableSpan for Linear.Bounded

extension Buffer.Linear.Bounded where S: Span.`Protocol`, S: ~Copyable {
    /// Read-only span of all buffer elements.
    ///
    /// Sourced through the substrate's `Span.`Protocol`` requirement; the seam keeps the storage's
    /// tracked prefix at exactly `0..<count`.
    public var span: Swift.Span<S.Element> {
        @_lifetime(borrow self)
        @inlinable
        borrowing get {
            storage.span
        }
    }
}

extension Buffer.Linear.Bounded where S: Span.Mutable.`Protocol`, S: ~Copyable {
    /// Mutable span of all buffer elements.
    ///
    /// Forwarded through the substrate's `Span.Mutable.`Protocol`` requirement
    /// (`storage.mutableSpan(count:)`); the seam keeps the storage's tracked prefix at `0..<count`.
    public var mutableSpan: Swift.MutableSpan<S.Element> {
        @_lifetime(&self)
        @inlinable
        mutating get {
            storage.mutableSpan(count: header.count)
        }
    }
}
