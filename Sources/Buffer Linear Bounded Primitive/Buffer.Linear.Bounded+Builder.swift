import Affine_Primitives_Standard_Library_Integration
// Explicit `Buffer.Protocol` import: the @inlinable builder body below uses the
// inherited `isEmpty` default (not relied on transitively); `public` per [MOD-027].
public import Buffer_Protocol_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
import Storage_Protocol_Primitives

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

extension Buffer.Linear.Bounded where S: ~Copyable {
    /// Constructs a heap-allocated bounded linear buffer from a result-builder closure.
    ///
    /// Wraps the dynamic `Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Builder` per Round-2
    /// Option Y. Capacity is supplied at the outer init; overflow throws
    /// `Error.capacityExceeded` before any element is moved into `self`.
    ///
    /// ```swift
    /// let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded = try Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(
    ///     minimumCapacity: 8
    /// ) {
    ///     1; 2; 3
    /// }
    /// ```
    @inlinable
    public init<E: ~Copyable>(
        minimumCapacity: Index<E>.Count,
        @Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear.Builder _ builder: () -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
    ) throws(Self.Error) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
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
