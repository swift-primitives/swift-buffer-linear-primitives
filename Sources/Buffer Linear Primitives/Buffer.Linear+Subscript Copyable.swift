import Ordinal_Primitives_Standard_Library_Integration
import Affine_Primitives_Standard_Library_Integration
public import Storage_Heap_Primitives
// MARK: - Subscript (Copyable with CoW)

extension Buffer.Linear where Element: Copyable {
    /// Accesses the element at the given index with copy-on-write semantics.
    ///
    /// - Parameter index: The index of the element to access.
    @inlinable
    public subscript(_ index: Index<Element>) -> Element {
        _read {
            yield unsafe storage.pointer(at: index).pointee
        }
        _modify {
            ensureUnique()
            yield unsafe &storage.pointer(at: index).pointee
        }
    }
}
