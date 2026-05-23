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

extension Buffer.Linear where Element: ~Copyable {
    /// A result builder for declaratively constructing growable linear buffers.
    ///
    /// Supports `~Copyable` elements via consuming append. Move-only types
    /// compose declaratively:
    ///
    /// ```swift
    /// struct FileHandle: ~Copyable { ... }
    /// let handles: Buffer<FileHandle>.Linear = Buffer<FileHandle>.Linear {
    ///     FileHandle()
    ///     FileHandle()
    /// }
    /// ```
    ///
    /// For `Copyable` elements:
    ///
    /// ```swift
    /// let buffer: Buffer<Int>.Linear = Buffer<Int>.Linear {
    ///     1
    ///     2
    ///     if condition {
    ///         3
    ///     }
    /// }
    /// ```
    ///
    /// ## `for` Loops Not Supported
    ///
    /// The `buildArray` step of Swift's result-builder transform takes
    /// `[Component]` (`Swift.Array<Component>`), which currently requires
    /// `Component: Copyable`. Because this builder's component type is the
    /// ~Copyable `Buffer<Element>.Linear`, `buildArray` is omitted and
    /// `for` loops are therefore not supported in the builder body. Use
    /// imperative construction (`var x = Buffer<E>.Linear(...);
    /// x.append(...)`) for loop-based building when the element type is
    /// `~Copyable`.
    @resultBuilder
    public enum Builder {

        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(
            _ expression: consuming Element
        ) -> Buffer<Element>.Linear {
            var result = Buffer<Element>.Linear(minimumCapacity: .one)
            result.append(consume expression)
            return result
        }

        @inlinable
        public static func buildExpression(
            _ expression: consuming Buffer<Element>.Linear
        ) -> Buffer<Element>.Linear {
            consume expression
        }

        @inlinable
        public static func buildExpression(
            _ expression: consuming Element?
        ) -> Buffer<Element>.Linear {
            var result = Buffer<Element>.Linear(minimumCapacity: .zero)
            if let value = consume expression {
                result.append(consume value)
            }
            return result
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(
            first: consuming Buffer<Element>.Linear
        ) -> Buffer<Element>.Linear {
            consume first
        }

        @inlinable
        public static func buildPartialBlock(
            first: Void
        ) -> Buffer<Element>.Linear {
            Buffer<Element>.Linear(minimumCapacity: .zero)
        }

        @inlinable
        public static func buildPartialBlock(
            first: Never
        ) -> Buffer<Element>.Linear {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming Buffer<Element>.Linear,
            next: consuming Buffer<Element>.Linear
        ) -> Buffer<Element>.Linear {
            var result = consume accumulated
            var rest = consume next
            while !rest.isEmpty {
                result.append(rest.remove.first())
            }
            return result
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> Buffer<Element>.Linear {
            Buffer<Element>.Linear(minimumCapacity: .zero)
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(
            _ component: consuming Buffer<Element>.Linear?
        ) -> Buffer<Element>.Linear {
            if let result = consume component {
                return consume result
            }
            return Buffer<Element>.Linear(minimumCapacity: .zero)
        }

        @inlinable
        public static func buildEither(
            first: consuming Buffer<Element>.Linear
        ) -> Buffer<Element>.Linear {
            consume first
        }

        @inlinable
        public static func buildEither(
            second: consuming Buffer<Element>.Linear
        ) -> Buffer<Element>.Linear {
            consume second
        }

        // buildArray omitted: see DocC above.

        @inlinable
        public static func buildLimitedAvailability(
            _ component: consuming Buffer<Element>.Linear
        ) -> Buffer<Element>.Linear {
            consume component
        }
    }
}

// MARK: - Convenience Init

extension Buffer.Linear where Element: ~Copyable {
    /// Constructs a growable linear buffer from a result-builder closure.
    ///
    /// ```swift
    /// let buffer: Buffer<Int>.Linear = Buffer<Int>.Linear {
    ///     1
    ///     2
    ///     3
    /// }
    /// ```
    @inlinable
    public init(@Buffer.Linear.Builder _ builder: () -> Self) {
        self = builder()
    }
}

// MARK: - Sequence Bulk-Add (Copyable Element only)

extension Buffer.Linear.Builder where Element: Copyable {
    /// Bulk-add a Swift.Sequence (Range, Swift.Array, lazy chain, etc.)
    /// without per-iteration allocation.
    @inlinable
    public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> Buffer<Element>.Linear
    where S.Element == Element {
        var result = Buffer<Element>.Linear(minimumCapacity: .zero)
        for value in expression {
            result.append(value)
        }
        return result
    }
}
