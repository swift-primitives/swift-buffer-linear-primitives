extension Buffer.Linear.Bounded where S: ~Copyable {
    /// Errors that can occur during bounded linear buffer operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The number of elements exceeds the buffer's capacity.
        case capacityExceeded
    }
}
