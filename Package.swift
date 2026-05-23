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
        // MARK: - Type module (NO Sequence/Collection conformances — A10 poison isolation)
        .library(name: "Buffer Linear Primitive", targets: ["Buffer Linear Primitive"]),
        // MARK: - Ops module + satellites
        .library(name: "Buffer Linear Primitives", targets: ["Buffer Linear Primitives"]),
        .library(name: "Buffer Linear Inline Primitives", targets: ["Buffer Linear Inline Primitives"]),
        .library(name: "Buffer Linear Small Primitives", targets: ["Buffer Linear Small Primitives"]),
        .library(name: "Buffer Linear Primitives Test Support", targets: ["Buffer Linear Primitives Test Support"]),
    ],
    dependencies: [
        .package(path: "../swift-buffer-primitives"),
        .package(path: "../swift-storage-primitives"),
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-affine-primitives"),
        .package(path: "../swift-ordinal-primitives"),
        .package(path: "../swift-memory-primitives"),
        .package(path: "../swift-finite-primitives"),
        .package(path: "../swift-sequence-primitives"),
        .package(path: "../swift-collection-primitives"),
        .package(path: "../swift-cardinal-primitives"),
    ],
    targets: [

        // MARK: - Buffer Linear Primitive — type declarations only (Buffer.Linear/.Bounded/.Small/.Inline/.Header).
        // Per separate-module-conformance: keeping the ~Copyable type decls in a module
        // WITHOUT the Sequence/Collection conformances prevents the A10 implicit-Copyable leak.
        .target(
            name: "Buffer Linear Primitive",
            dependencies: [
                .product(name: "Buffer Primitive", package: "swift-buffer-primitives"),
                .product(name: "Buffer Growth Primitives", package: "swift-buffer-primitives"),
                .product(name: "Storage Heap Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Inline Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Initialization Primitives", package: "swift-storage-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
            ]
        ),

        // MARK: - Buffer Linear Primitives — operations + Sequence/Collection conformances (poison contained here).
        .target(
            name: "Buffer Linear Primitives",
            dependencies: [
                "Buffer Linear Primitive",
                .product(name: "Storage Heap Primitives", package: "swift-storage-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
            ]
        ),
        .target(
            name: "Buffer Linear Inline Primitives",
            dependencies: [
                "Buffer Linear Primitive",
                "Buffer Linear Primitives",
                .product(name: "Storage Heap Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Inline Primitives", package: "swift-storage-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
            ]
        ),
        .target(
            name: "Buffer Linear Small Primitives",
            dependencies: [
                "Buffer Linear Primitive",
                "Buffer Linear Primitives",
                "Buffer Linear Inline Primitives",
                .product(name: "Storage Heap Primitives", package: "swift-storage-primitives"),
                .product(name: "Storage Inline Primitives", package: "swift-storage-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
            ]
        ),
        // MARK: - Test Support
        .target(
            name: "Buffer Linear Primitives Test Support",
            dependencies: [
                "Buffer Linear Primitives",
                "Buffer Linear Inline Primitives",
                "Buffer Linear Small Primitives",
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
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
            name: "Buffer Linear Inline Primitives Tests",
            dependencies: ["Buffer Linear Inline Primitives", "Buffer Linear Primitives Test Support"]
        ),
        .testTarget(
            name: "Buffer Linear Small Primitives Tests",
            dependencies: ["Buffer Linear Small Primitives", "Buffer Linear Primitives Test Support"]
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
