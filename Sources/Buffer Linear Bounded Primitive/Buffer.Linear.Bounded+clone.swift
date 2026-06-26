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

public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives

// MARK: - clone (capacity-preserving deep copy — the `Shared` clone strategy)

extension Buffer.Linear.Bounded where S: ~Copyable {
    /// Returns an independent copy of this buffer with its own storage at the
    /// SAME observable capacity.
    ///
    /// CAPACITY-PRESERVING by contract (unlike the growable buffer's
    /// shrink-to-fit `clone()`): a bounded buffer's capacity IS its contract —
    /// a shrink-to-fit copy would make in-contract pushes overflow after a CoW
    /// detach. The clone's header pins the ORIGINAL capacity even when the
    /// fresh storage rounds up physically; the header is the bound-enforcer
    /// (extra physical slots stay unused and untracked).
    ///
    /// - Complexity: O(`count`)
    @inlinable
    public func clone<E>() -> Self
    where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>, E: Copyable {
        var newStorage = Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>.create(minimumCapacity: header.capacity)
        Buffer.Linear.copy(header: header, source: storage, to: &newStorage)
        var newHeader = Buffer.Linear.Header(capacity: header.capacity)
        newHeader.count = header.count
        newStorage.initialization = newHeader.initialization
        return Self(header: newHeader, storage: newStorage)
    }
}
