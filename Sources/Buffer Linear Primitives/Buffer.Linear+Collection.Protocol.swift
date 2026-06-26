// TODO(buffer-storage-dedup): restore Collection conformance once swift-collection-primitives
// is green again. It is RED from parallel-session work (Collection.Protocol+defaults.swift
// lifetime-dependence error), NOT from this value-type-storage migration — Collection requires
// Copyable so the migration plausibly interacts, but the standalone-build failure pre-exists.
// Commented out (not deleted) to decouple buffer-linear's build from the un-buildable dependency;
// the Collection Primitives product deps are likewise commented in Package.swift. See
// storage-generic-buffer-core.md § Collection deferral.
// public import Collection_Primitives
//
//// MARK: - Collection.Protocol
//
// extension Buffer.Linear: Collection.`Protocol` where Element: Copyable {
//    @inlinable
//    public var startIndex: Index_Primitives.Index<Element> { .zero }
//
//    @inlinable
//    public var endIndex: Index_Primitives.Index<Element> {
//        count.map(Ordinal.init)
//    }
//
//    @inlinable
//    public func index(after i: Index_Primitives.Index<Element>) -> Index_Primitives.Index<Element> {
//        try! i + Index_Primitives.Index<Element>.Offset(1)
//    }
// }
