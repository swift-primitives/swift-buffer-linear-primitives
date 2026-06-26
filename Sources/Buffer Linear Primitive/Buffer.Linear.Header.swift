import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
import Storage_Primitive
public import Store_Initialization_Primitives

//
//  Buffer.Linear.Header.swift
//  swift-buffer-primitives
//
//  Created by Coen ten Thije Boonkkamp on 04/02/2026.
//

extension Buffer.Linear where S: ~Copyable {
    // MARK: - Header

    /// Pure cursor state for a linear (contiguous) buffer.
    ///
    /// Linear buffers store elements at slots `0 ..< count`. The header tracks
    /// the current element count and total capacity.
    ///
    /// Initialization is always `.one(idx(0) ..< idx(count))` — a single
    /// contiguous range starting at zero.
    @frozen
    public struct Header: Copyable, Sendable {
        /// Number of initialized elements.
        public var count: Index<S.Element>.Count

        /// Total slot capacity.
        public let capacity: Index<S.Element>.Count

        /// Creates a header with the given capacity and zero elements.
        @inlinable
        public init(capacity: Index<S.Element>.Count) {
            self.count = .zero
            self.capacity = capacity
        }
    }
}

extension Buffer.Linear.Header where S: ~Copyable {

    /// Whether the buffer has no elements.
    @inlinable
    public var isEmpty: Bool { count == .zero }

    /// Whether the buffer is at capacity.
    @inlinable
    public var isFull: Bool { count == capacity }
}

extension Buffer.Linear.Header where S: ~Copyable {
    /// Compute the `Store.Initialization` state from linear header.
    ///
    /// Returns `.empty` or `.one` — linear storage is always contiguous.
    @inlinable
    public var initialization: Store.Initialization<S.Element> { .init(self) }
}
