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
// The buffer conforms the 4-op seam by yielding into the layer below — the reference/rich-spike
// recipe ("each layer yields into the layer below"), which specializes to zero `witness_method`
// through a concrete tower. `capacity` and the subscript are witnessed by the existing members;
// the lifecycle ops forward to the storage seam and mirror the buffer's header cursor with the
// SEAM'S OWN prefix arithmetic (the 4-op seam carries no `count`; the storage ledger applies the
// identical rule, so the two stay in lockstep by construction). First consumer: the W4 `Shared`
// column combinator, whose box drains and whose conformance carriers walk through this seam.
extension Buffer.Linear: Store.`Protocol` where S: Store.`Protocol`, S: ~Copyable {
    /// Initializes the uninitialized slot (uninit → init).
    ///
    /// The contiguous discipline appends at
    /// `slot == count` — the same unconditional contract the storage ledger applies — so the
    /// header cursor mirrors with the identical arithmetic.
    @inlinable
    public mutating func initialize(at slot: Index<S.Element>, to element: consuming S.Element) {
        storage.initialize(at: slot, to: element)
        header.count += .one
    }

    /// Moves the initialized element out (init → uninit; the discipline retracts at
    /// the trailing slot), mirroring the header cursor with the ledger's arithmetic.
    @inlinable
    public mutating func move(at slot: Index<S.Element>) -> S.Element {
        let element = storage.move(at: slot)
        header.count = header.count.subtract.saturating(.one)
        return element
    }
}
