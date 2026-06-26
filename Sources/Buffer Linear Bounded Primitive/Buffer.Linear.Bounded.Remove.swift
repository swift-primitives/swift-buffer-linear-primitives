import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives

extension Buffer.Linear.Bounded where S: ~Copyable {
    /// Tag type for `.remove` property extensions.
    public enum Remove {}
}

extension Buffer.Linear.Bounded.Remove where S: ~Copyable {
    /// A mutating, typed view that removes and returns elements through `.remove`.
    public typealias View = Property<Buffer<S>.Linear.Remove, Buffer<S>.Linear.Bounded>.Inout.Typed<S.Element>
}
