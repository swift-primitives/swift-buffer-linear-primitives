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

// MARK: - Buffer.Protocol Conformance (bounded leaf)

/// `Buffer.Linear.Bounded` is a `Buffer.Protocol` capability conformer.
///
/// The sole witness needed is `count` (`Buffer.Linear.Bounded+Lifecycle.swift`,
/// `header.count`); `isEmpty` is supplied by the protocol default. Mirrors
/// `Buffer.Linear+Buffer.Protocol.swift`.
extension Buffer.Linear.Bounded: Buffer.`Protocol` where S: ~Copyable {
    /// The element type, forwarded from the backing store.
    public typealias Element = S.Element
}
