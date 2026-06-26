import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
import Storage_Contiguous_Primitives
import Storage_Primitive
import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Package window for cold ops-module conformances (refined-C, [MOD-031])
//
// Mirror of `Buffer.Linear+ConformanceSupport.swift`: the storage internals are
// `@usableFromInline internal`, so the cold Sequence / Collection / Drain /
// Span.`Protocol` conformances in the ops module (isolated per
// [MOD-004]) reach them only through these `package` windows. Not public (NOT
// Option A); not `@usableFromInline internal` (the ops module could not see an
// `internal` symbol). The conformances are cold, so forgoing their
// cross-package inlining is the accepted trade-off; the hot surface is
// unaffected.

extension Buffer.Linear.Bounded where S: ~Copyable {

    @usableFromInline
    package var _storage: S {
        _read { yield storage }
    }

    /// Consuming drain in initialized order (O(n)).
    ///
    /// Each `move(at:)` retracts the storage's own
    /// ledger via the seam, so after draining the live prefix the ledger is `.empty` with no
    /// explicit sync (keeps the drain storage-generic).
    @usableFromInline
    package mutating func _drain(_ body: (consuming S.Element) -> Void) {
        var position: Index<S.Element> = .zero
        let end = header.count.map(Ordinal.init)
        while position < end {
            body(storage.move(at: position))
            position += .one
        }
        header.count = .zero
    }
}
