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
import Buffer_Linear_Small_Primitives
import Buffer_Linear_Primitives_Test_Support
import Testing

@Suite("Buffer.Linear.Small+Builder")
struct LinearSmallBuilderTests {
    @Suite struct Inline {}
    @Suite struct SpillToHeap {}
    @Suite struct NonCopyable {}
}

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

extension LinearSmallBuilderTests.Inline {

    @Test
    func `Within inline capacity`() {
        let buffer = Buffer<Int>.Linear.Small<8> {
            1
            2
            3
        }
        #expect(buffer.count == 3)
    }
}

extension LinearSmallBuilderTests.SpillToHeap {

    @Test
    func `Beyond inline capacity spills`() {
        let buffer = Buffer<Int>.Linear.Small<2> {
            1
            2
            3
            4
            5
        }
        // Small spills to heap, no throw
        #expect(buffer.count == 5)
    }
}

extension LinearSmallBuilderTests.NonCopyable {

    @Test
    func `Constructs noncopyable small buffer`() {
        let buffer = Buffer<Move>.Linear.Small<4> {
            Move(1)
            Move(2)
            Move(3)
        }
        #expect(buffer.count == 3)
    }
}
