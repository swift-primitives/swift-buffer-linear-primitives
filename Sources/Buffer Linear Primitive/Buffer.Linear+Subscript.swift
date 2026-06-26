import Affine_Primitives_Standard_Library_Integration
import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives

extension Buffer.Linear where S: ~Copyable {
    /// Accesses the element at the given index (non-CoW base accessor).
    ///
    /// - Parameter index: The index of the element to access.
    ///
    /// The CoW-safe subscript in `Buffer.Linear+Subscript Copyable.swift` (whose
    /// `_modify` calls `ensureUnique()`) serves `Copyable` elements on a sharing
    /// leaf. The two surfaces are NON-OVERLAPPING by
    /// element-copyability, so Swift specificity resolves them with NO
    /// `@_disfavoredOverload` priority hint (Cleave-5 D6).
    @inlinable
    public subscript(_ index: Index<S.Element>) -> S.Element {
        _read {
            yield storage[index]
        }
        _modify {
            yield &storage[index]
        }
    }
}
