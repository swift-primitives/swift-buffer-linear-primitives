import Affine_Primitives_Standard_Library_Integration
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives

extension Buffer.Linear where S: ~Copyable {
    /// Tag type for `.peek` property extensions.
    public enum Peek {}
}

extension Buffer.Linear.Peek where S: ~Copyable {
    /// A borrowed, typed view onto an element accessed through `.peek` without removing it.
    public typealias View = Property<Buffer<S>.Linear.Peek, Buffer<S>.Linear>.Borrow.Typed<S.Element>
}
