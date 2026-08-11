import Buffer_Linear_Primitives
import Buffer_Linear_Primitives_Test_Support
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Testing

@Suite("Buffer.Linear + OutputSpan")
struct LinearOutputSpanTests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

private struct MoveOnly: ~Copyable {
    let value: Int
}

private func append(_ value: Int, to output: inout Swift.OutputSpan<Int>) {
    output.append(value)
}

extension LinearOutputSpanTests.Unit {

    @Test
    func `output span commits the initialized frontier to the header`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 4)

        buffer.outputSpan.append(10)
        buffer.outputSpan.append(20)

        #expect(buffer.count == 2)
        #expect(buffer[0] == 10)
        #expect(buffer[1] == 20)
    }

    @Test
    func `output span is lifetime bound to its mutating accessor`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 2)

        append(10, to: &buffer.outputSpan)

        #expect(buffer.count == 1)
        #expect(buffer[0] == 10)
    }
}

extension LinearOutputSpanTests.`Edge Case` {

    @Test
    func `output span removal synchronizes the finalized frontier once`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 4)
        buffer.append(10)
        buffer.append(20)
        _ = buffer.outputSpan.removeLast()

        buffer.append(30)

        #expect(buffer.count == 2)
        #expect(buffer[0] == 10)
        #expect(buffer[1] == 30)
    }
}

extension LinearOutputSpanTests.Integration {

    @Test
    func `output span preserves move-only initialization`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<MoveOnly>>.Linear(minimumCapacity: 2)

        buffer.outputSpan.append(MoveOnly(value: 10))
        buffer.outputSpan.append(MoveOnly(value: 20))

        #expect(buffer.count == 2)
    }
}
