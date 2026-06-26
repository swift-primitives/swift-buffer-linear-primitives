import Affine_Primitives_Standard_Library_Integration
public import Finite_Primitives
import Ordinal_Primitives_Standard_Library_Integration
import Storage_Contiguous_Primitives
public import Store_Protocol_Primitives

// MARK: - ~Copyable forEach for Linear

extension Buffer.Linear where S: ~Copyable {
    /// Calls `body` with a borrow of each element in order.
    @inlinable
    public func forEach<E: Swift.Error>(_ body: (borrowing S.Element) throws(E) -> Void) throws(E) {
        var slot: Index<S.Element> = .zero
        let end = header.count.map(Ordinal.init)
        while slot < end {
            try body(storage[slot])
            slot += .one
        }
    }
}
