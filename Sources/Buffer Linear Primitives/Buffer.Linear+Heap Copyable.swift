public import Storage_Primitive
import Ordinal_Primitives_Standard_Library_Integration
import Affine_Primitives_Standard_Library_Integration
public import Storage_Heap_Primitives
// MARK: - Static Operations for Copyable Elements on Storage.Heap

extension Buffer.Linear where Element: Copyable {

    /// Copies elements from source storage to destination storage.
    ///
    /// After this call, destination contains elements at slots `0 ..< header.count`.
    @inlinable
    public static func copy(
        header: Header,
        source: Storage<Element>.Heap,
        to destination: Storage<Element>.Heap
    ) {
        header.initialization.forEach { range in
            source.copy(range: range, to: destination)
        }
    }
}
