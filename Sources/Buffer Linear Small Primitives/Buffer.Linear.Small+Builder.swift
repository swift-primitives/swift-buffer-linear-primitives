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

extension Buffer.Linear.Small where Element: ~Copyable {
    /// Constructs a SmallVec linear buffer from a result-builder closure.
    ///
    /// Wraps the dynamic `Buffer<Element>.Linear.Builder` per Round-2
    /// Option Y. Non-throwing because Small spills inline capacity to
    /// the heap rather than failing on overflow.
    ///
    /// ```swift
    /// let buffer: Buffer<Int>.Linear.Small<4> = Buffer<Int>.Linear.Small {
    ///     1; 2; 3; 4; 5  // first 4 inline, 5th spills to heap
    /// }
    /// ```
    @inlinable
    public init(
        @Buffer<Element>.Linear.Builder _ builder: () -> Buffer<Element>.Linear
    ) {
        var dynamic = builder()
        self.init()
        while !dynamic.isEmpty {
            self.append(dynamic.remove.first())
        }
    }
}
