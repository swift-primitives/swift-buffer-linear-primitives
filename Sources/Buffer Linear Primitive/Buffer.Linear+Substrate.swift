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

import Storage_Protocol_Primitives

extension Buffer.Linear where S: ~Copyable {

    /// A read-only borrow of the backing substrate.
    ///
    /// Lets consumers query *substrate-specific* properties through the composed buffer —
    /// e.g. `Store.Small (deferred Q2)`'s `isSpilled` via `buffer.substrate.isSpilled` — WITHOUT promoting
    /// those properties to the neutral `Storage.Protocol` seam. Spill-awareness (and any other
    /// one-substrate concern) stays where it belongs: on the substrate that has it. The value-generic
    /// same-type constraint `where S == Storage<Element>.Contiguous<Memory.Small<Element, n>>` cannot bind `n` in an extension,
    /// so this general borrow is the surface-preserving path (Cleave-3 E3; seam-free).
    @inlinable
    public var substrate: S {
        _read { yield storage }
    }
}
