import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
import Storage_Contiguous_Primitives
import Storage_Primitive
import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Package window for cold ops-module conformances (refined-C, [MOD-031])
//
// The storage internals are `@usableFromInline internal` so the hot ~Copyable
// surface in this (type) module inlines cross-package to zero-witness-dispatch.
// The cold Sequence / Collection / Drain / Span.`Protocol`
// conformances live in the ops module (isolated per [MOD-004]) and reach the
// internals ONLY through the package-scoped windows below.
//
// These are deliberately:
//   - NOT public — encapsulation preserved (this is NOT Option A); and
//   - NOT @usableFromInline internal — the ops module is a *different* module
//     and could not see an `internal` symbol by source name.
// `package` is the minimal level that lets the ops module reference them.
// The conformances that use them are cold (per-consumer inline counts 2–6), so
// forgoing *their* cross-package inlining is the accepted trade-off; the hot
// surface is unaffected.

extension Buffer.Linear where S: ~Copyable {

    /// The backing storage.
    ///
    /// Package window for the cold conformances that
    /// need a base pointer (`Sequence` / `Span.\`Protocol\``).
    ///
    /// Yields a borrow via `_read` — the substrate `S` is `~Copyable`, so it cannot be
    /// returned by value from a borrowing getter (the prior class-backed storage
    /// returned a shared reference). Callers borrow it for the access scope and reach
    /// elements through the storage's typed slot accessors — the element `subscript`
    /// (plus `initialize`/`move`) and the whole-region `Span`/`MutableSpan`/`OutputSpan`
    /// surface ([IMPL-100]).
    @usableFromInline
    package var _storage: S {
        _read { yield storage }
    }

    /// Consuming drain in initialized order (O(n)).
    ///
    /// Package window for the
    /// `Sequence.Drain.Protocol` conformance in the ops module.
    ///
    /// Generic over `S: Store.`Protocol``: the drain touches only the inherited element-store
    /// `move(at:)`. Each `move` retracts the storage's own ledger, so after draining the live
    /// prefix the seam ledger is already `.empty` — no explicit `initialization` sync is needed
    /// (the seam auto-maintains it), which keeps the drain storage-generic (no Heap concreteness).
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
