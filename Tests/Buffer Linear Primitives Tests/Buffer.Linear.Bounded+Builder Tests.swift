// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Buffer_Linear_Primitives
import Buffer_Linear_Primitives_Test_Support
import Testing

@Suite("Buffer.Linear.Bounded+Builder")
struct LinearBoundedBuilderTests {
    @Suite struct WithinCapacity {}
    @Suite struct Overflow {}
    @Suite struct NonCopyable {}
}

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

extension LinearBoundedBuilderTests.WithinCapacity {

    @Test
    func `Constructs within capacity`() throws {
        let buffer = try Buffer<Int>.Linear.Bounded(minimumCapacity: 8) {
            1
            2
            3
        }
        #expect(buffer.count == 3)
    }
}

extension LinearBoundedBuilderTests.Overflow {

    @Test
    func `Throws on overflow`() {
        do {
            _ = try Buffer<Int>.Linear.Bounded(minimumCapacity: 2) {
                1
                2
                3
            }
            Issue.record("expected throw")
        } catch let error {
            #expect(error == .capacityExceeded)
        }
    }
}

extension LinearBoundedBuilderTests.NonCopyable {

    @Test
    func `Constructs noncopyable bounded buffer`() throws {
        let buffer = try Buffer<Move>.Linear.Bounded(minimumCapacity: 4) {
            Move(1)
            Move(2)
        }
        #expect(buffer.count == 2)
    }
}
