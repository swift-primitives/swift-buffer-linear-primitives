import Buffer_Linear_Primitives
import Buffer_Linear_Primitives_Test_Support
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Testing

@Suite("Buffer.Linear")
struct LinearGrowableTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
}

// MARK: - Unit

extension LinearGrowableTests.Unit {

    @Test
    func `append and removeFirst`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 4)
        buffer.append(10)
        buffer.append(20)
        buffer.append(30)

        #expect(buffer.remove.first() == 10)
        #expect(buffer.remove.first() == 20)
        #expect(buffer.remove.first() == 30)
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
    }

    @Test
    func `append and removeLast`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 4)
        buffer.append(10)
        buffer.append(20)
        buffer.append(30)

        #expect(buffer.remove.last() == 30)
        #expect(buffer.remove.last() == 20)
        #expect(buffer.remove.last() == 10)
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
    }

    @Test
    func `growth doubles capacity`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 2)
        let originalCap = buffer.capacity

        var i = 0
        let needed = Int(originalCap.underlying.rawValue) + 1
        while i < needed {
            buffer.append(i * 10)
            i += 1
        }

        #expect(buffer.capacity.underlying.rawValue > originalCap.underlying.rawValue)

        // Verify elements survived growth
        i = 0
        while i < needed {
            #expect(buffer.remove.first() == i * 10)
            i += 1
        }
    }

    @Test
    func `drain removes all in front-to-back order`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        var drained: [Int] = []
        buffer.drain { drained.append($0) }
        #expect(drained == [10, 20, 30])
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
    }

    @Test
    func `removeAll clears buffer`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([1, 2, 3])
        buffer.remove.all()
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
    }

    @Test
    func `peekFront and peekBack (Copyable)`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        #expect(buffer.peek.front == 10)
        #expect(buffer.peek.back == 30)
    }

    @Test
    func `Iterable iteration (Copyable)`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        // Dual conformer: `: Iterable` (memory→Iterable bridge, bulk `Iterator.Chunk`)
        // and `: Sequenceable` (hand-written scalar `Buffer.Linear.Scalar`). `forEach`
        // is the `Sequenceable` borrowing terminal (non-destructive).
        var collected: [Int] = []
        buffer.forEach { collected.append($0) }
        #expect(collected == [10, 20, 30])
    }

    @Test
    func `single element`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 1)
        buffer.append(42)
        #expect(buffer.count == 1)
        #expect(buffer.remove.last() == 42)
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
    }

    @Test
    func `reserveCapacity grows if needed`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 2)
        buffer.reserveCapacity(100)
        #expect(buffer.capacity.underlying.rawValue >= 100)
    }

    @Test
    func `forEach visits all elements`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        var visited: [Int] = []
        buffer.forEach { visited.append($0) }
        #expect(visited == [10, 20, 30])
    }

    @Test
    func `subscript read and write`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        #expect(buffer[0] == 10)
        #expect(buffer[1] == 20)
        #expect(buffer[2] == 30)
        buffer[1] = 999
        #expect(buffer[1] == 999)
    }

    @Test
    func `swap exchanges two elements`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        buffer.swap(at: 0, with: 2)
        #expect(buffer[0] == 30)
        #expect(buffer[2] == 10)
    }

    @Test
    func `truncate removes trailing elements`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30, 40, 50])
        buffer.truncate(to: 3)
        #expect(buffer.count == 3)
        #expect(buffer.peek.back == 30)
    }
}

// MARK: - Edge Cases

extension LinearGrowableTests.EdgeCase {

    @Test
    func `truncate to zero empties buffer`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        buffer.truncate(to: .zero)
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
    }

    @Test
    func `swap same index is no-op`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        buffer.swap(at: 1, with: 1)
        #expect(buffer[1] == 20)
    }

    @Test
    func `empty buffer properties`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(minimumCapacity: 4)
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
        #expect(buffer.count == 0)
    }
}

// MARK: - Integration

extension LinearGrowableTests.Integration {

    @Test
    func `drain then reuse`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear([10, 20, 30])
        buffer.drain { _ in }
        let bufferIsEmpty = buffer.isEmpty
        #expect(bufferIsEmpty)
        buffer.append(40)
        #expect(buffer.peek.front == 40)
    }
}
