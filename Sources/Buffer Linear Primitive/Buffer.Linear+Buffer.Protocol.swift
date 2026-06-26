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

public import Buffer_Protocol_Primitives

// MARK: - Buffer.Protocol Conformance (Heap leaf)

/// `Buffer.Linear` (heap) is a `Buffer.Protocol` capability conformer.
///
/// The sole witness needed is `count` — `Buffer.Linear+Lifecycle.swift`
/// (`header.count`); `isEmpty` is supplied by the protocol's default
/// implementation (`count == .zero`) — the deduplication payoff. No per-leaf
/// `isEmpty` declaration is required by the conformance.
///
/// Iteration is orthogonal to this capability surface (per the v2/A′ decision)
/// and is NOT part of this conformance. `Buffer.Linear` gains the generic
/// terminal suite (`forEach` / `contains` / `first` / `reduce`) by *separately*
/// conforming to `Iterable`, whose span-primitive iterator (SE-0516) lends each
/// element via the borrowing addressor `span[i]` — Copyable AND `~Copyable`,
/// vended for free by the memory→Iterable bridge over `span` (landed in the
/// SE-0516 cascade). The banked `where Element: ~Copyable` conformance is
/// preserved (no narrowing to Copyable).
extension Buffer.Linear: Buffer.`Protocol` where S: ~Copyable {
    /// The element type, forwarded from the backing store.
    public typealias Element = S.Element
}
