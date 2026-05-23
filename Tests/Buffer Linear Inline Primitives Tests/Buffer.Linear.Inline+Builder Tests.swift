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

import Buffer_Linear_Inline_Primitives
import Buffer_Linear_Primitives
import Buffer_Linear_Primitives_Test_Support
import Testing

@Suite("Buffer.Linear.Inline+Builder")
struct LinearInlineBuilderTests {
    @Suite struct WithinCapacity {}
    @Suite struct Overflow {}
    @Suite struct NonCopyable {}
}

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

extension LinearInlineBuilderTests.WithinCapacity {

    @Test
    func `Constructs from builder within capacity`() throws {
        let buffer = try Buffer<Int>.Linear.Inline<8> {
            1
            2
            3
        }
        #expect(buffer.count == 3)
    }

    @Test
    func `Empty builder constructs empty inline buffer`() throws {
        let buffer = try Buffer<Int>.Linear.Inline<4> {
            let x: Int? = nil
            x  // optional none
        }
        let isEmpty = buffer.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `Full capacity within bounds`() throws {
        let buffer = try Buffer<Int>.Linear.Inline<3> {
            1
            2
            3
        }
        #expect(buffer.count == 3)
    }
}

extension LinearInlineBuilderTests.Overflow {

    @Test
    func `Throws on capacity exceeded`() {
        do {
            _ = try Buffer<Int>.Linear.Inline<2> {
                1
                2
                3  // overflow
            }
            Issue.record("expected throw")
        } catch let error {
            #expect(error == .capacityExceeded)
        }
    }
}

extension LinearInlineBuilderTests.NonCopyable {

    @Test
    func `Constructs noncopyable inline buffer`() throws {
        let buffer = try Buffer<Move>.Linear.Inline<4> {
            Move(1)
            Move(2)
            Move(3)
        }
        #expect(buffer.count == 3)
    }
}
