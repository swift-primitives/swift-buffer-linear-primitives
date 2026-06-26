import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
import Storage_Protocol_Primitives
public import Store_Initialization_Primitives
public import Store_Protocol_Primitives

//
//  Store.Initialization.swift
//  swift-buffer-primitives
//
//  Created by Coen ten Thije Boonkkamp on 04/02/2026.
//

// The canonical ledger is `Store.Initialization<Element>` (swift-store-primitives). This bridges a
// linear buffer `Header` to its contiguous-prefix ledger. Suppression restated per [API-NAME-010b].
extension Store.Initialization where Element: ~Copyable & ~Escapable {
    /// Derives the contiguous-prefix initialization ledger from a linear buffer's header.
    @inlinable
    public init<S: Store.`Protocol` & ~Copyable>(
        _ header: Buffer<S>.Linear.Header
    ) where S.Element == Element {
        if header.count == .zero {
            self = .empty
            return
        }
        self = .one(.zero..<header.count.map(Ordinal.init))
    }
}
