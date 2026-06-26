import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Sequence_Primitives
public import Span_Protocol_Primitives
public import Storage_Contiguous_Primitives

// MARK: - removeAll()
//
// Copyable-gated concrete clearing method isolated in the ops module per
// [MOD-004]; cold. `removeAll()` is the consuming drain-and-discard
// `_drain { _ in }` — NOT `remove.all()`, which is Heap-pinned
// (`S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>`) and cannot resolve under a
// generic `S` (solution 6).

extension Buffer.Linear where S: Span.`Protocol`, S: Copyable, S.Element: Copyable {
    /// Removes every element by consuming drain-and-discard.
    @inlinable
    public mutating func removeAll() {
        _drain { _ in }
    }
}
