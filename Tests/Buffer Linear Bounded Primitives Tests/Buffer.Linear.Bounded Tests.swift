import Buffer_Linear_Primitives
import Buffer_Linear_Primitives_Test_Support
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Storage_Contiguous_Primitives
import Testing

@Suite("Buffer.Linear.Bounded")
struct LinearBoundedTests {
    @Suite struct Unit {}
    @Suite struct Integration {}
}

// MARK: - Unit

extension LinearBoundedTests.Unit {

    @Test
    func `init creates empty bounded buffer`() {
        let buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        #expect(buffer.isEmpty == true)
        #expect(buffer.count == .zero)
        #expect(buffer.isFull == false)
    }

    @Test
    func `clone preserves capacity exactly and detaches storage`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        _ = buffer.append(1)
        _ = buffer.append(2)
        let capacityBefore = buffer.capacity
        var copy = buffer.clone()
        #expect(copy.capacity == capacityBefore)  // capacity-preserving, exactly
        #expect(copy.count == buffer.count)
        _ = copy.append(3)  // in-contract push on the clone
        #expect(copy.count == 3)
        #expect(buffer.count == 2)  // original untouched
        #expect(buffer[1] == 2)
        #expect(copy[2] == 3)
    }

    @Test
    func `append and removeLast`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        _ = buffer.append(10)
        _ = buffer.append(20)
        _ = buffer.append(30)

        #expect(buffer.remove.last() == 30)
        #expect(buffer.remove.last() == 20)
        #expect(buffer.remove.last() == 10)
        #expect(buffer.isEmpty == true)
    }

    @Test
    func `append and removeFirst`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        _ = buffer.append(10)
        _ = buffer.append(20)
        _ = buffer.append(30)

        #expect(buffer.remove.first() == 10)
        #expect(buffer.remove.first() == 20)
        #expect(buffer.remove.first() == 30)
        #expect(buffer.isEmpty == true)
    }

    @Test
    func `removeAll clears buffer`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        _ = buffer.append(1)
        _ = buffer.append(2)
        _ = buffer.append(3)
        buffer.remove.all()
        #expect(buffer.isEmpty == true)
        #expect(buffer.count == .zero)
    }

    @Test
    func `isFull detection`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 2)
        #expect(buffer.isFull == false)

        let cap = buffer.capacity.underlying.rawValue
        var i: UInt = 0
        while i < cap {
            _ = buffer.append(Int(i))
            i += 1
        }
        #expect(buffer.isFull == true)
    }

    @Test
    func `append returns element when full`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 2)
        let cap = buffer.capacity.underlying.rawValue
        var i: UInt = 0
        while i < cap {
            let rejected = buffer.append(Int(i))
            #expect(rejected == nil)
            i += 1
        }
        #expect(buffer.isFull == true)

        let rejected = buffer.append(999)
        #expect(rejected == 999)
    }

    @Test
    func `subscript access`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        _ = buffer.append(10)
        _ = buffer.append(20)
        _ = buffer.append(30)

        #expect(buffer[Index<Int>(Ordinal(UInt(0)))] == 10)
        #expect(buffer[Index<Int>(Ordinal(UInt(1)))] == 20)
        #expect(buffer[Index<Int>(Ordinal(UInt(2)))] == 30)

        buffer[Index<Int>(Ordinal(UInt(1)))] = 999
        #expect(buffer[Index<Int>(Ordinal(UInt(1)))] == 999)
    }

    @Test
    func `peekFront and peekBack`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        _ = buffer.append(10)
        _ = buffer.append(20)
        _ = buffer.append(30)

        #expect(buffer.peek.front == 10)
        #expect(buffer.peek.back == 30)
        #expect(buffer.count == 3)
    }

    @Test
    func `drain removes all in front-to-back order`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 8)
        _ = buffer.append(10)
        _ = buffer.append(20)
        _ = buffer.append(30)

        var drained: [Int] = []
        buffer.drain { drained.append($0) }
        #expect(drained == [10, 20, 30])
        #expect(buffer.isEmpty == true)
    }

    @Test
    func `single element`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 1)
        let rejected = buffer.append(42)
        #expect(rejected == nil)
        #expect(buffer.count == 1)
        #expect(buffer.remove.last() == 42)
        #expect(buffer.isEmpty == true)
    }
}

// MARK: - Integration

extension LinearBoundedTests.Integration {

    @Test
    func `fill drain fill cycle`() {
        var buffer = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear.Bounded(minimumCapacity: 4)
        let cap = Int(buffer.capacity.underlying.rawValue)

        var i = 0
        while i < cap {
            _ = buffer.append(i * 10)
            i += 1
        }
        #expect(buffer.isFull == true)

        buffer.remove.all()
        #expect(buffer.isEmpty == true)

        i = 0
        while i < cap {
            _ = buffer.append(i * 100)
            i += 1
        }
        #expect(buffer.isFull == true)
        #expect(buffer.peek.front == 0)
    }
}
