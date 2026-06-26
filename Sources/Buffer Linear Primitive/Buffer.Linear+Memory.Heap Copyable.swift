import Affine_Primitives_Standard_Library_Integration
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive
public import Storage_Protocol_Primitives
public import Store_Protocol_Primitives

// MARK: - Static Operations for Copyable Elements on Storage.Contiguous<Memory.Heap>

extension Buffer.Linear where S: ~Copyable, S.Element: Copyable {

    /// Copies elements from source storage to destination storage.
    ///
    /// After this call, destination contains elements at slots `0 ..< header.count`.
    ///
    /// Delegates to the generic `Storage.Protocol.copy(to:count:)` derivation,
    /// which reads each source slot via the typed `subscript` getter and fills the
    /// destination via `initialize(at:to:)`. Linear initialization is always a
    /// single contiguous `.one(0..<count)` range, so copying the leading
    /// `header.count` slots packs into `0..<count` in the destination.
    @inlinable
    public static func copy(
        header: Header,
        source: borrowing Storage<Memory.Allocator<Memory.Heap>>.Contiguous<S.Element>,
        to destination: inout Storage<Memory.Allocator<Memory.Heap>>.Contiguous<S.Element>
    ) {
        source.copy(to: &destination, count: header.count)
    }
}
