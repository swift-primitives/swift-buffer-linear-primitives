import Affine_Primitives_Standard_Library_Integration
public import Buffer_Protocol_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
import Storage_Protocol_Primitives

extension Buffer.Linear where S: ~Copyable {
    /// A result builder for declaratively constructing growable linear buffers.
    ///
    /// Supports `~Copyable` elements via consuming append. Move-only types
    /// compose declaratively:
    ///
    /// ```swift
    /// struct FileHandle: ~Copyable { ... }
    /// let handles: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<FileHandle>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<FileHandle>>.Linear {
    ///     FileHandle()
    ///     FileHandle()
    /// }
    /// ```
    ///
    /// For `Copyable` elements:
    ///
    /// ```swift
    /// let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
    ///     1
    ///     2
    ///     if condition {
    ///         3
    ///     }
    /// }
    /// ```
    ///
    /// ## `for` Loops Not Supported
    ///
    /// The `buildArray` step of Swift's result-builder transform takes
    /// `[Component]` (`Swift.Array<Component>`), which currently requires
    /// `Component: Copyable`. Because this builder's component type is the
    /// ~Copyable `Buffer<S>.Linear`, `buildArray` is omitted and
    /// `for` loops are therefore not supported in the builder body. Use
    /// imperative construction (`var x = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(...);
    /// x.append(...)`) for loop-based building when the element type is
    /// `~Copyable`.
    @resultBuilder
    public enum Builder {

        // MARK: - Expression Building

        /// Lifts a single element into a one-element buffer component.
        @inlinable
        public static func buildExpression<E: ~Copyable>(
            _ expression: consuming E
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(minimumCapacity: .one)
            result.append(consume expression)
            return result
        }

        /// Passes an already-built buffer component through unchanged.
        @inlinable
        public static func buildExpression<E: ~Copyable>(
            _ expression: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            consume expression
        }

        /// Lifts an optional element into a buffer component, empty when `nil`.
        @inlinable
        public static func buildExpression<E: ~Copyable>(
            _ expression: consuming E?
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(minimumCapacity: .zero)
            if let value = consume expression {
                result.append(consume value)
            }
            return result
        }

        // MARK: - Partial Block Building

        /// Starts a block from its first buffer component.
        @inlinable
        public static func buildPartialBlock<E: ~Copyable>(
            first: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            consume first
        }

        /// Starts an empty block from a `Void`-returning statement.
        @inlinable
        public static func buildPartialBlock<E: ~Copyable>(
            first: Void
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(minimumCapacity: .zero)
        }

        /// Starts a block from an unreachable `Never` branch.
        @inlinable
        public static func buildPartialBlock<E: ~Copyable>(
            first: Never
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {}

        /// Appends the next component's elements onto the accumulated buffer.
        @inlinable
        public static func buildPartialBlock<E: ~Copyable>(
            accumulated: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear,
            next: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            var result = consume accumulated
            var rest = consume next
            while !rest.isEmpty {
                result.append(rest.remove.first())
            }
            return result
        }

        // MARK: - Block Building

        /// Produces an empty buffer for an empty builder body.
        @inlinable
        public static func buildBlock<E: ~Copyable>() -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(minimumCapacity: .zero)
        }

        // MARK: - Control Flow

        /// Yields the component when the `if` branch is taken, or an empty buffer otherwise.
        @inlinable
        public static func buildOptional<E: ~Copyable>(
            _ component: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear?
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            if let result = consume component {
                return consume result
            }
            return Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(minimumCapacity: .zero)
        }

        /// Selects the first branch of an `if`/`else`.
        @inlinable
        public static func buildEither<E: ~Copyable>(
            first: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            consume first
        }

        /// Selects the second branch of an `if`/`else`.
        @inlinable
        public static func buildEither<E: ~Copyable>(
            second: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            consume second
        }

        // buildArray omitted: see DocC above.

        /// Passes a limited-availability component through unchanged.
        @inlinable
        public static func buildLimitedAvailability<E: ~Copyable>(
            _ component: consuming Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
            consume component
        }
    }
}

// MARK: - Convenience Init

extension Buffer.Linear where S: ~Copyable {
    /// Constructs a growable linear buffer from a result-builder closure.
    ///
    /// ```swift
    /// let buffer: Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
    ///     1
    ///     2
    ///     3
    /// }
    /// ```
    @inlinable
    public init<E: ~Copyable>(@Buffer.Linear.Builder _ builder: () -> Self) where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E> {
        self = builder()
    }
}

// MARK: - Sequence Bulk-Add (Copyable Element only)

extension Buffer.Linear.Builder where S: ~Copyable {
    /// Bulk-add a Swift.Sequence (Range, Swift.Array, lazy chain, etc.)
    /// without per-iteration allocation.
    @inlinable
    public static func buildExpression<E, Seq: Swift.Sequence>(_ expression: Seq) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear
    where S == Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>, E: Copyable, Seq.Element == E {
        var result = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear(minimumCapacity: .zero)
        for value in expression {
            result.append(value)
        }
        return result
    }
}
