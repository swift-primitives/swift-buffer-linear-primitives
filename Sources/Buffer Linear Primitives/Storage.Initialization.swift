import Ordinal_Primitives_Standard_Library_Integration
import Affine_Primitives_Standard_Library_Integration
public import Storage_Heap_Primitives
//
//  Storage.Initialization.swift
//  swift-buffer-primitives
//
//  Created by Coen ten Thije Boonkkamp on 04/02/2026.
//


extension Storage.Initialization where Element: ~Copyable {
    @inlinable
    public init(
        _ header: Buffer<Element>.Linear.Header
    ) {
        if header.count == .zero {
            self = .empty
            return
        }
        self = .one(.zero..<header.count.map(Ordinal.init))
    }
}
