// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-buffer-linear-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Type modules (lean ~Copyable types; Copyable-requiring conformances live in the ops modules per [MOD-004])
        .library(name: "Buffer Linear Primitive", targets: ["Buffer Linear Primitive"]),
        .library(name: "Buffer Linear Bounded Primitive", targets: ["Buffer Linear Bounded Primitive"]),
        // MARK: - Ops modules (one per variant); `Buffer Linear Primitives` doubles as the [MOD-005] umbrella
        .library(name: "Buffer Linear Primitives", targets: ["Buffer Linear Primitives"]),
        .library(name: "Buffer Linear Bounded Primitives", targets: ["Buffer Linear Bounded Primitives"]),
        .library(name: "Buffer Linear Primitives Test Support", targets: ["Buffer Linear Primitives Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-buffer-primitives.git", branch: "main"),
        // W3 tower: the dense column is `Storage<Memory.Allocator<Memory.Heap>.System>.Contiguous<E>`,
        // over the 4-op `Store.`Protocol`` seam. Storage + Store + the heap allocation all enter here.
        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-allocation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-heap-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-affine-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ordinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-span-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-finite-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
        // Iteration bridges. `: Iterable` (multipass) uses the memory→Iterable witness over the
        // existing Span.`Protocol` conformance. `: Sequenceable` (single-pass) is a hand-written
        // scalar iterator (the generic Memory.Cursor bridge demangle-crashes — OQ-2), so the
        // swift-memory-sequence-primitives dep is intentionally absent.
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-iterator-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Type modules — lean ~Copyable types + @usableFromInline internal ops co-located with storage ([MOD-036])
        .target(
            name: "Buffer Linear Primitive",
            dependencies: [
                .product(name: "Buffer Primitive", package: "swift-buffer-primitives"),
                .product(name: "Buffer Protocol Primitives", package: "swift-buffer-primitives"),
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Store Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Store Initialization Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Allocator Protocol Primitives", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
            ]
        ),
        .target(
            name: "Buffer Linear Bounded Primitive",
            dependencies: [
                "Buffer Linear Primitive",
                .product(name: "Buffer Primitive", package: "swift-buffer-primitives"),
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Store Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Store Initialization Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
            ]
        ),

        // MARK: - Ops modules — Copyable-requiring conformances isolated per [MOD-004].
        //         `Buffer Linear Primitives` (the base conformances module) doubles as the
        //         [MOD-005] umbrella: it re-exports every variant module.
        .target(
            name: "Buffer Linear Primitives",
            dependencies: [
                "Buffer Linear Primitive",
                "Buffer Linear Bounded Primitives",
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Memory Iterator Primitives", package: "swift-memory-iterator-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
            ]
        ),
        .target(
            name: "Buffer Linear Bounded Primitives",
            dependencies: [
                "Buffer Linear Bounded Primitive",
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Memory Iterator Primitives", package: "swift-memory-iterator-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
            ]
        ),
        // MARK: - SIL Probe (cross-module consumer for the witness_method specialization check)
        .executableTarget(
            name: "Buffer Protocol SIL Probe",
            dependencies: [
                "Buffer Linear Primitive",
                .product(name: "Buffer Protocol Primitives", package: "swift-buffer-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Buffer Linear Primitives Test Support",
            dependencies: [
                "Buffer Linear Primitives",
                "Buffer Linear Bounded Primitives",
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Memory Allocator Primitive", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Heap Primitives", package: "swift-memory-heap-primitives"),
                .product(name: "Memory Primitives Test Support", package: "swift-memory-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Buffer Linear Primitives Tests",
            dependencies: ["Buffer Linear Primitives", "Buffer Linear Primitives Test Support"]
        ),
        .testTarget(
            name: "Buffer Linear Bounded Primitives Tests",
            dependencies: ["Buffer Linear Bounded Primitives", "Buffer Linear Primitives Test Support"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("BuiltinModule"),
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
