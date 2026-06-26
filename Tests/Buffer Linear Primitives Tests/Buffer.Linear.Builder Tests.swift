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
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Testing

// MARK: - Test Suite Structure

@Suite("Buffer.Linear.Builder")
struct LinearBuilderTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite struct NonCopyable {}
    @Suite struct StaticMethods {}
}

// MARK: - Move-Only Test Fixture

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

// MARK: - Iteration Helpers (for ~Copyable comparison)

extension LinearBuilderTests {
    fileprivate static func collected(
        _ buffer: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear
    ) -> [Int] {
        var rest = consume buffer
        var result: [Int] = []
        while !rest.isEmpty {
            result.append(rest.remove.first())
        }
        return result
    }

    fileprivate static func collected(
        _ buffer: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear
    ) -> [Int] {
        var rest = consume buffer
        var result: [Int] = []
        while !rest.isEmpty {
            let m = rest.remove.first()
            result.append(m.value)
        }
        return result
    }
}

// MARK: - Unit Tests

extension LinearBuilderTests.Unit {

    @Test
    func `Single element expression`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear { 42 }
        #expect(LinearBuilderTests.collected(buffer) == [42])
    }

    @Test
    func `Multiple element expressions`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
            3
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3])
    }

    @Test
    func `Optional element - some`() {
        let value: Int? = 42
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear { value }
        #expect(LinearBuilderTests.collected(buffer) == [42])
    }

    @Test
    func `Optional element - none`() {
        let value: Int? = nil
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear { value }
        let isEmpty = buffer.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `Mixed elements and optionals`() {
        let some: Int? = 2
        let none: Int? = nil
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            some
            none
            3
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3])
    }

    @Test
    func `Empty block`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {}
        let isEmpty = buffer.isEmpty
        #expect(isEmpty)
    }
}

// MARK: - Control Flow

extension LinearBuilderTests.Unit {

    @Test
    func `Conditional include`() {
        let include = true
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            if include {
                2
            }
            3
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3])
    }

    @Test
    func `Conditional exclude`() {
        let include = false
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            if include {
                2
            }
            3
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 3])
    }

    @Test
    func `If-else first branch`() {
        let condition = true
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            if condition {
                1
            } else {
                2
            }
        }
        #expect(LinearBuilderTests.collected(buffer) == [1])
    }

    @Test
    func `If-else second branch`() {
        let condition = false
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            if condition {
                1
            } else {
                2
            }
        }
        #expect(LinearBuilderTests.collected(buffer) == [2])
    }

    @Test
    func `Limited availability passthrough`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            if #available(macOS 26, iOS 26, *) {
                2
            }
            3
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3])
    }
}

// MARK: - Edge Cases

extension LinearBuilderTests.EdgeCase {

    @Test
    func `Deeply nested conditionals`() {
        let a = true
        let b = false
        let c = true
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            0
            if a {
                1
                if b {
                    2
                } else {
                    3
                    if c {
                        4
                    }
                }
            }
            99
        }
        #expect(LinearBuilderTests.collected(buffer) == [0, 1, 3, 4, 99])
    }

    @Test
    func `Many elements`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
            3
            4
            5
            6
            7
            8
            9
            10
        }
        #expect(LinearBuilderTests.collected(buffer) == Swift.Array(1...10))
    }
}

// MARK: - Integration

extension LinearBuilderTests.Integration {

    @Test
    func `Builder result is mutable`() {
        var buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
            3
        }
        buffer.append(4)
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3, 4])
    }

    @Test
    func `Empty builder composes with append`() {
        var buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {}
        let isEmpty = buffer.isEmpty
        #expect(isEmpty)
        buffer.append(1)
        buffer.append(2)
        #expect(LinearBuilderTests.collected(buffer) == [1, 2])
    }
}

// MARK: - NonCopyable

extension LinearBuilderTests.NonCopyable {

    @Test
    func `Builder with single noncopyable element`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear {
            Move(42)
        }
        #expect(LinearBuilderTests.collected(buffer) == [42])
    }

    @Test
    func `Builder with multiple noncopyable elements`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear {
            Move(1)
            Move(2)
            Move(3)
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3])
    }

    @Test
    func `Builder with conditional noncopyable element - included`() {
        let include = true
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear {
            Move(1)
            if include {
                Move(2)
            }
            Move(3)
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 2, 3])
    }

    @Test
    func `Builder with conditional noncopyable element - excluded`() {
        let include = false
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear {
            Move(1)
            if include {
                Move(2)
            }
            Move(3)
        }
        #expect(LinearBuilderTests.collected(buffer) == [1, 3])
    }

    @Test
    func `Builder with if-else noncopyable`() {
        let condition = true
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear {
            if condition {
                Move(10)
            } else {
                Move(20)
            }
        }
        #expect(LinearBuilderTests.collected(buffer) == [10])
    }

    @Test
    func `Empty noncopyable builder`() {
        let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Move>>.Linear {}
        let isEmpty = buffer.isEmpty
        #expect(isEmpty)
    }
}

// MARK: - Static Method Tests

extension LinearBuilderTests.StaticMethods {

    @Test
    func `buildExpression single element`() {
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildExpression(42)
        #expect(LinearBuilderTests.collected(result) == [42])
    }

    @Test
    func `buildExpression existing buffer`() {
        let input: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
            3
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildExpression(input)
        #expect(LinearBuilderTests.collected(result) == [1, 2, 3])
    }

    @Test
    func `buildExpression optional - some`() {
        let value: Int? = 42
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildExpression(value)
        #expect(LinearBuilderTests.collected(result) == [42])
    }

    @Test
    func `buildExpression optional - none`() {
        let value: Int? = nil
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildExpression(value)
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildPartialBlock first`() {
        let first: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
            3
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildPartialBlock(first: first)
        #expect(LinearBuilderTests.collected(result) == [1, 2, 3])
    }

    @Test
    func `buildPartialBlock first void`() {
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildPartialBlock(first: ())
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildPartialBlock accumulated and next`() {
        let acc: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
        }
        let next: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            3
            4
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildPartialBlock(
            accumulated: acc,
            next: next
        )
        #expect(LinearBuilderTests.collected(result) == [1, 2, 3, 4])
    }

    @Test
    func `buildBlock empty`() {
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildBlock()
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildOptional some`() {
        let component: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear? = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildOptional(component)
        #expect(LinearBuilderTests.collected(result) == [1, 2])
    }

    @Test
    func `buildOptional none`() {
        let component: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear? = nil
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildOptional(component)
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildEither first`() {
        let first: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildEither(first: first)
        #expect(LinearBuilderTests.collected(result) == [1, 2])
    }

    @Test
    func `buildEither second`() {
        let second: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            3
            4
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildEither(second: second)
        #expect(LinearBuilderTests.collected(result) == [3, 4])
    }

    @Test
    func `buildLimitedAvailability passthrough`() {
        let component: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            1
            2
            3
        }
        let result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Builder.buildLimitedAvailability(component)
        #expect(LinearBuilderTests.collected(result) == [1, 2, 3])
    }
}
