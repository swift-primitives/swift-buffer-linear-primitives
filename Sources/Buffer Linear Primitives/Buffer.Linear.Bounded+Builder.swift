import Ordinal_Primitives_Standard_Library_Integration
import Affine_Primitives_Standard_Library_Integration
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

extension Buffer.Linear.Bounded where Element: ~Copyable {
    /// Constructs a heap-allocated bounded linear buffer from a result-builder closure.
    ///
    /// Wraps the dynamic `Buffer<Element>.Linear.Builder` per Round-2
    /// Option Y. Capacity is supplied at the outer init; overflow throws
    /// `Error.capacityExceeded` before any element is moved into `self`.
    ///
    /// ```swift
    /// let buffer: Buffer<Int>.Linear.Bounded = try Buffer<Int>.Linear.Bounded(
    ///     minimumCapacity: 8
    /// ) {
    ///     1; 2; 3
    /// }
    /// ```
    @inlinable
    public init(
        minimumCapacity: Index<Element>.Count,
        @Buffer<Element>.Linear.Builder _ builder: () -> Buffer<Element>.Linear
    ) throws(Self.Error) {
        var dynamic = builder()
        guard dynamic.count <= minimumCapacity else {
            throw .capacityExceeded
        }
        self.init(minimumCapacity: minimumCapacity)
        while !dynamic.isEmpty {
            _ = self.append(dynamic.remove.first())
        }
    }
}
