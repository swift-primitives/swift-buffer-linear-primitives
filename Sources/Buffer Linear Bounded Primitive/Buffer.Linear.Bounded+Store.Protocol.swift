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

public import Index_Primitives
public import Store_Protocol_Primitives

// MARK: - The seam, forwarded through the nesting (the ratified template shape)
//
// Mirrors `Buffer.Linear+Store.Protocol.swift`: the bounded buffer conforms the seam by
// yielding into the storage below, mirroring the header cursor with the SEAM'S OWN prefix
// arithmetic. The capacity property and the element subscript are witnessed by existing
// members. First consumer: the column-generic `Fixed<S>` ADT (the Q3-B ruling) — the
// bounded buffer IS the non-growable column.
extension Buffer.Linear.Bounded: Store.`Protocol` where S: Store.`Protocol`, S: ~Copyable {
    /// The seam's per-slot element access, forwarded to the storage below.
    ///
    /// The bounded buffer's own element subscript is pinned to the heap column; the seam witness is
    /// the generic coroutine pair.
    @inlinable
    public subscript(slot: Index<S.Element>) -> S.Element {
        _read { yield storage[slot] }
        _modify { yield &storage[slot] }
    }

    /// Initializes the uninitialized slot (uninit → init), mirroring the header cursor with
    /// the storage ledger's arithmetic.
    @inlinable
    public mutating func initialize(at slot: Index<S.Element>, to element: consuming S.Element) {
        storage.initialize(at: slot, to: element)
        header.count += .one
    }

    /// Moves the initialized element out (init → uninit), mirroring the header cursor with
    /// the ledger's arithmetic.
    @inlinable
    public mutating func move(at slot: Index<S.Element>) -> S.Element {
        let element = storage.move(at: slot)
        header.count = header.count.subtract.saturating(.one)
        return element
    }
}
