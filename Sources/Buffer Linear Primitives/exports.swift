@_exported public import Buffer_Linear_Bounded_Primitives
// `Buffer Linear Primitives` is the base conformances module AND the [MOD-005] umbrella:
// it re-exports the base type plus every variant ops module, so `import Buffer_Linear_Primitives`
// surfaces the whole package. Consumers needing only one variant import that variant per [MOD-015].
@_exported public import Buffer_Linear_Primitive
@_exported public import Iterable
@_exported public import Memory_Iterator_Primitives
@_exported public import Sequence_Primitives
