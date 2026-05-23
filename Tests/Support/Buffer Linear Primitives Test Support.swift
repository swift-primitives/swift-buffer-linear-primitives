public import Buffer_Linear_Primitives
public import Index_Primitives
public import Cardinal_Primitives

// MARK: - Linear

extension Buffer.Linear {
    @inlinable
    public init(_ elements: [Element], minimumCapacity: UInt = 0) {
        let cap: Index<Element>.Count = .init(Cardinal(Swift.max(UInt(elements.count), minimumCapacity)))
        var buffer = Self(minimumCapacity: cap)
        for element in elements {
            buffer.append(element)
        }
        self = buffer
    }
}

extension Buffer.Linear.Small {
    @inlinable
    public init(_ elements: [Element]) {
        var buffer = Self()
        for element in elements {
            buffer.append(element)
        }
        self = buffer
    }
}
