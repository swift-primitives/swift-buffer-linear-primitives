// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Buffer.Linear.Inline where Element: ~Copyable {
    /// Constructs a fixed-capacity inline linear buffer from a result-builder closure.
    ///
    /// Wraps the dynamic `Buffer<Element>.Linear.Builder` per Round-2
    /// Option Y: the dynamic top-level builder produces the body's
    /// elements; this convenience init drains them into the inline
    /// variant. Capacity is checked up front; overflow throws
    /// `Error.capacityExceeded` before any element is moved into `self`.
    ///
    /// ```swift
    /// let buffer: Buffer<Int>.Linear.Inline<8> = try Buffer<Int>.Linear.Inline {
    ///     1; 2; 3
    /// }
    /// ```
    @inlinable
    public init(
        @Buffer<Element>.Linear.Builder _ builder: () -> Buffer<Element>.Linear
    ) throws(Self.Error) {
        var dynamic = builder()
        let cap = Index<Element>.Count(UInt(capacity))
        guard dynamic.count <= cap else {
            throw .capacityExceeded
        }
        self.init()
        while !dynamic.isEmpty {
            // Pre-check guaranteed capacity; append returns nil.
            _ = self.append(dynamic.remove.first())
        }
    }
}
