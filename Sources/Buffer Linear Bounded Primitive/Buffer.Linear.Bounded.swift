import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
import Storage_Primitive
public import Store_Protocol_Primitives

extension Buffer.Linear where S: ~Copyable {

    /// A fixed-capacity linear buffer over a `Store.`Protocol`` storage.
    ///
    /// The storage's seam ops self-maintain its initialization ledger, so its own deinit oracle
    /// handles cleanup automatically.
    @frozen
    public struct Bounded: ~Copyable {
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

// MARK: - Conditional Conformances

// CoW withdrawn (W2): the storage tier is unconditionally `~Copyable`, so `S` is never `Copyable` —
// `Buffer.Linear.Bounded` is move-only. The prior `Copyable where S: Copyable` is removed.
/// Sendable conformance for `Buffer.Linear.Bounded`.
///
/// ## Safety Invariant
///
/// Category B — ownership transfer. `Buffer.Linear.Bounded` is `~Copyable` and owns its
/// `Store.`Protocol`` storage; the conformance requires that storage to be `Sendable`. Moving the
/// buffer across an isolation boundary transfers the sole value that can reach the storage, so no
/// independently usable alias remains in the source isolation domain. `@unchecked` removes the
/// compiler's data-race prevention; it does not make shared access safe.
///
/// ## Intended Use
///
/// - Transferring a bounded linear buffer to a consumer.
///
/// ## Non-Goals
///
/// - Not a shared concurrent buffer.
extension Buffer.Linear.Bounded: @unchecked Sendable where S: Store.`Protocol` & ~Copyable & Sendable {}
