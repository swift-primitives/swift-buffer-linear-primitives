import Buffer_Linear_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Testing

@Suite("Buffer.Linear + split")
struct LinearSplitTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

extension LinearSplitTests.Unit {

    @Test
    func `split preserves order in independently owned parts`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30, 40])
        let split = consume buffer.split(maximum: 2)
        var prefix: [Int] = []
        var remainder: [Int] = []
        split.prefix.forEach { prefix.append($0) }
        split.remainder.forEach { remainder.append($0) }

        #expect(prefix == [10, 20])
        #expect(remainder == [30, 40])
    }
}

extension LinearSplitTests.EdgeCase {

    @Test
    func `split with zero maximum has an empty prefix`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20])
        let split = consume buffer.split(maximum: .zero)
        let prefixCount = split.prefix.count
        var remainder: [Int] = []
        split.remainder.forEach { remainder.append($0) }

        #expect(prefixCount == .zero)
        #expect(remainder == [10, 20])
    }

    @Test
    func `split beyond count has an empty remainder`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20])
        let split = consume buffer.split(maximum: 3)
        var prefix: [Int] = []
        let remainderCount = split.remainder.count
        split.prefix.forEach { prefix.append($0) }

        #expect(prefix == [10, 20])
        #expect(remainderCount == .zero)
    }
}
