import Ordinal_Primitives_Standard_Library_Integration
import Affine_Primitives_Standard_Library_Integration
public import Storage_Heap_Primitives
// MARK: - Unified Iterator for Linear buffers

extension Buffer.Linear where Element: Copyable {
    /// Iterator that provides both element-at-a-time and span-based iteration
    /// for linear storage.
    // WHY: Category D (SP-5) — pointer-backed value type; storage is
    // WHY: private/internal; the type's safe API never lets the raw pointer
    // WHY: escape, and lifetime invariants are enforced by init/deinit pairing.
    @safe
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol, @unsafe @unchecked Sendable {
        @usableFromInline
        var base: UnsafePointer<Element>

        @usableFromInline
        var remaining: Index<Element>.Count

        @inlinable
        internal init(base: UnsafePointer<Element>, count: Index<Element>.Count) {
            unsafe self.base = base
            self.remaining = count
        }

        // MARK: IteratorProtocol

        @inlinable
        public mutating func next() -> Element? {
            guard remaining > .zero else { return nil }
            let element = unsafe base.pointee
            unsafe base = base + 1
            remaining = remaining.subtract.saturating(.one)
            return element
        }

        // MARK: Sequence.Iterator.Protocol (nextSpan)

        @inlinable
        @_lifetime(&self)
        public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element> {
            let take = Index<Element>.Count.min(.init(maximumCount), remaining)
            guard take > .zero else {
                return unsafe Swift.Span(_unsafeStart: base, count: 0)
            }
            let span = unsafe Swift.Span(_unsafeStart: base, count: take)
            unsafe base = base + Int(bitPattern: take)
            remaining = remaining.subtract.saturating(take)
            return span
        }
    }
}

extension Buffer.Linear: Sequence.`Protocol`, Sequence.Borrowing.`Protocol` where Element: Copyable {
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        let base = unsafe UnsafePointer(storage.pointer(at: .zero))
        return unsafe Iterator(base: base, count: header.count)
    }
}

extension Buffer.Linear: Swift.Sequence where Element: Copyable {
    @inlinable
    public var underestimatedCount: Int { Int(bitPattern: header.count) }
}

extension Buffer.Linear.Bounded where Element: Copyable {
    /// Iterator that provides both element-at-a-time and span-based iteration
    /// for linear storage.
    // WHY: Category D (SP-5) — pointer-backed value type; storage is
    // WHY: private/internal; the type's safe API never lets the raw pointer
    // WHY: escape, and lifetime invariants are enforced by init/deinit pairing.
    @safe
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol, @unsafe @unchecked Sendable {
        @usableFromInline
        var base: UnsafePointer<Element>

        @usableFromInline
        var remaining: Index<Element>.Count

        @inlinable
        internal init(base: UnsafePointer<Element>, count: Index<Element>.Count) {
            unsafe self.base = base
            self.remaining = count
        }

        @inlinable
        public mutating func next() -> Element? {
            guard remaining > .zero else { return nil }
            let element = unsafe base.pointee
            unsafe base = base + 1
            remaining = remaining.subtract.saturating(.one)
            return element
        }

        @inlinable
        @_lifetime(&self)
        public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element> {
            let take = Index<Element>.Count.min(.init(maximumCount), remaining)
            guard take > .zero else {
                return unsafe Swift.Span(_unsafeStart: base, count: 0)
            }
            let span = unsafe Swift.Span(_unsafeStart: base, count: take)
            unsafe base = base + Int(bitPattern: take)
            remaining = remaining.subtract.saturating(take)
            return span
        }
    }
}

extension Buffer.Linear.Bounded: Sequence.`Protocol`, Sequence.Borrowing.`Protocol` where Element: Copyable {
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        let base = unsafe UnsafePointer(storage.pointer(at: .zero))
        return unsafe Iterator(base: base, count: header.count)
    }
}

extension Buffer.Linear.Bounded: Swift.Sequence where Element: Copyable {
    @inlinable
    public var underestimatedCount: Int { Int(bitPattern: header.count) }
}
