import Affine_Primitives_Standard_Library_Integration
import Index_Primitives
import Ordinal_Primitives_Standard_Library_Integration
import Storage_Contiguous_Primitives
import Storage_Primitive
public import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

extension Buffer where S: Store.`Protocol`, S: ~Copyable {

    /// A growable linear buffer backed by heap storage.
    ///
    /// Provides append and consume operations with automatic capacity growth.
    /// Elements are stored contiguously at slots `0 ..< count`.
    ///
    /// The storage's seam ops self-maintain its initialization ledger, so the backing's own
    /// deinit oracle handles cleanup automatically.
    @frozen
    public struct Linear: ~Copyable {

        // MARK: - Linear Fields

        @usableFromInline
        var header: Header

        @usableFromInline
        var storage: S

        @inlinable
        package init(header: Header, storage: consuming S) {
            self.header = header
            self.storage = storage
        }
    }
}

// MARK: - Conditional Conformances (Linear)

// CoW withdrawn (W2): the storage tier is unconditionally `~Copyable` (deinit oracle + explicit
// `copy()`), so a `Storage` `S` is never `Copyable` — `Buffer.Linear` is move-only. The prior
// conditional `Copyable where S: Copyable` could never fire and is removed.
/// Sendable conformance for `Buffer.Linear`.
///
/// ## Safety Invariant
///
/// `Buffer.Linear` is `~Copyable` and owns its `Store.`Protocol`` storage. Single ownership
/// enforced; cross-thread transfer is a move.
///
/// ## Intended Use
///
/// - Transferring a linear buffer to a worker thread.
///
/// ## Non-Goals
///
/// - Not a shared concurrent buffer; external synchronization required.
extension Buffer.Linear: @unsafe @unchecked Sendable where S: Store.`Protocol` & ~Copyable & Sendable {}
