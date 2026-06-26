import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives

extension Buffer.Linear where S: ~Copyable {
    /// Tag type for `.remove` property extensions.
    public enum Remove {}
}

extension Buffer.Linear.Remove where S: ~Copyable {
    /// A mutating, typed view that removes and returns elements through `.remove`.
    public typealias View = Property<Buffer<S>.Linear.Remove, Buffer<S>.Linear>.Inout.Typed<S.Element>
}
