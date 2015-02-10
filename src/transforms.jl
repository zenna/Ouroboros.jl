## Transformations
## A set of type safe transformations

# a program transformation is a mapping T:P -> P
# Which applies to aprogram

## TODO
# - a function which suggests a transformation to a model
# - code to evaluate the model
#

immutable PrimitiveFunction
  name::Symbol
  input_types::Vector{DataType}
  output_types::DataType
end

# Integer Primitives
plus = PrimitiveFunction(:+,[Int, Int],Int)
minus = PrimitiveFunction(:-,[Int, Int],Int)
times = PrimitiveFunction(:*,[Int, Int], Int)

immutable TypedSExpr
  head::PrimitiveFunction
  args::Vector
  function TypedSExpr(h,args)
    @assert all([typeof(arg) == for arg in args]) #Type check
    new(h,args)
  end
end

# Convert to an Expr object then an executable lambda
function compile(t::TypedSExpr)
end

type ProgramTransformation
  ast
  compiled::Bool
  λ

  # Precompiled
  ProgramTransformation(ast, λ::Function) = new(ast,true,λ)
  ProgramTransformation(ast) = new(ast,false)
end

function call(p::ProgramTransformation, p::Program)

end

function compile!(X::ProgramTransformation)
  if !X.compiled X.λ = eval(:(@anon $(lambarise(X)))) end
  X.compiled = true
  X
end

call(X::RandVarSymbolic, ω; args...) = (compile!(X); X.λ(ω))
callnocheck(X::RandVarSymbolic, ω) = X.λ(ω)
