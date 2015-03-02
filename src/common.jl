# Value typeof a value is just its value but for a func its its return type
valuetype(x) = typeof(x)
typecheck(T1::DataType, T2::DataType) = (T1 == Any) || (T2 == Any) || (T1 == T2)

## Common Types
## ===========

# A primitive function
immutable PrimFunc
  name::Symbol
  argtypes::Vector{DataType}
  rettype::DataType
end
